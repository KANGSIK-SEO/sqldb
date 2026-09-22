#!/usr/bin/env python3
"""
한글 자연어 질문 -> SQL 자동 생성 및 실행 (crime_org.db 전용, OFAC TCO 제재 데이터)

- 모델은 solar-pro3 하나만 쓴다. 다른 모델은 과금되므로 하드코딩해서 바꿀 수 없게 막는다.
- solar-pro3 무료 제공이 2027-04부터 유료로 전환되므로, 그 시점 이후에는
  자동으로 모델 호출을 막는다(코드에 하드코딩된 기준일이며 .env로도 못 바꾼다).
- API 키는 환경변수 UPSTAGE_API_KEY 또는 이 프로젝트 폴더의 로컬 .env(커밋되지 않음)에서 읽는다.
- 안전을 위해 SELECT 조회 쿼리는 바로 실행하고,
  INSERT/UPDATE/DELETE/DROP 등 데이터를 바꾸는 쿼리는 생성된 SQL을 보여준 뒤
  사람이 y를 눌러 확인해야만 실행한다(잘못 생성된 SQL로 데이터가 날아가는 것을 막기 위함).
"""

import sys
import os
import sqlite3
import datetime
import json
import urllib.request
import urllib.error

# --- 하드코딩된 안전장치: env로도 못 바꾼다 ---------------------------------
CHAT_MODEL = "solar-pro3"
MODEL_FREE_UNTIL = datetime.datetime(2027, 4, 1, tzinfo=datetime.timezone.utc)
UPSTAGE_ENDPOINT = "https://api.upstage.ai/v1/chat/completions"

HERE = os.path.dirname(os.path.abspath(__file__))
LOCAL_ENV_PATH = os.path.join(HERE, ".env")  # .gitignore에 등록되어 커밋되지 않음
sys.path.insert(0, HERE)
from schema import DB_PATH, SCHEMA_SQL  # noqa: E402


def load_api_key() -> str:
    key = os.environ.get("UPSTAGE_API_KEY")
    if key:
        return key.strip()
    if os.path.exists(LOCAL_ENV_PATH):
        with open(LOCAL_ENV_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("UPSTAGE_API_KEY="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    print(
        "[오류] UPSTAGE_API_KEY를 찾지 못했습니다.\n"
        "  방법 1) export UPSTAGE_API_KEY=발급받은키\n"
        f"  방법 2) {LOCAL_ENV_PATH} 파일을 만들고 UPSTAGE_API_KEY=발급받은키 한 줄 작성\n"
        "  (.env.example 참고, .env는 .gitignore에 있어 저장소에 올라가지 않습니다)"
    )
    sys.exit(1)


def check_model_allowed():
    now = datetime.datetime.now(datetime.timezone.utc)
    if now >= MODEL_FREE_UNTIL:
        print(
            f"[중단] {CHAT_MODEL} 무료 제공 기간(2027-04 이전)이 종료되어 "
            "모델 호출을 비활성화했습니다. 과금을 막기 위한 하드코딩된 정책이며, "
            "직접 SQL을 작성해서 실행해야 합니다."
        )
        sys.exit(1)


def load_reference_values() -> str:
    """org_name/country_name은 영문 원본(OFAC 표기)으로 저장돼 있어서,
    한글 질문을 정확한 문자열에 매칭시키려면 실제 값 목록을 힌트로 줘야 한다."""
    conn = sqlite3.connect(DB_PATH)
    try:
        orgs = [r[0] for r in conn.execute(
            "SELECT org_name FROM organization ORDER BY org_name"
        )]
        countries = [r[0] for r in conn.execute(
            "SELECT country_name FROM country ORDER BY country_name"
        )]
    finally:
        conn.close()
    return (
        f"organization.org_name에 실제로 존재하는 값: {', '.join(orgs)}\n"
        f"country.country_name에 실제로 존재하는 값: {', '.join(countries)}"
    )


def build_system_prompt(schema_text: str, reference_values: str) -> str:
    return f"""너는 지구최강 SQL 엔지니어다. 아래 SQLite 스키마에 대해서만 SQL을 생성한다.

[스키마]
{schema_text}

[실제 데이터 값 힌트]
{reference_values}

규칙:
- 반드시 위 스키마의 테이블/컬럼만 사용한다. 존재하지 않는 테이블/컬럼을 지어내지 않는다.
- org_name/country_name은 영문 원본 표기로 저장되어 있다. 사용자가 한글로 조직명/국가명을
  말해도(예: "야마구치구미", "일본"), 위 힌트에서 가장 가까운 실제 값(예: 'YAMAGUCHI-GUMI', 'Japan')으로
  매칭해서 조건을 만든다. 완전히 확신할 수 없으면 LIKE와 대소문자 무시 비교를 사용한다.
- SQLite 문법을 따른다.
- JOIN이 들어간 쿼리에서는 SELECT/GROUP BY/ORDER BY의 모든 컬럼에 테이블명(별칭)을 붙여
  "ambiguous column name" 오류가 나지 않게 한다.
- 출력은 오직 실행 가능한 SQL 한 문장(또는 세미콜론으로 구분된 여러 문장)만 출력한다.
- 설명, 마크다운 코드블록(```), 주석을 붙이지 않는다. SQL 텍스트만 출력한다.
- 사용자의 한국어 질문 의도를 SELECT/INSERT/UPDATE/DELETE 중 알맞은 것으로 정확히 표현한다.
"""


def call_solar(api_key: str, schema_text: str, reference_values: str, question: str) -> str:
    payload = {
        "model": CHAT_MODEL,
        "messages": [
            {"role": "system", "content": build_system_prompt(schema_text, reference_values)},
            {"role": "user", "content": question},
        ],
        "temperature": 0.0,
    }
    req = urllib.request.Request(
        UPSTAGE_ENDPOINT,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="ignore")
        print(f"[오류] Upstage API 호출 실패: {e.code} {body}")
        sys.exit(1)
    content = data["choices"][0]["message"]["content"]
    return clean_sql(content)


def clean_sql(text: str) -> str:
    text = text.strip()
    if text.startswith("```"):
        lines = text.splitlines()
        lines = [ln for ln in lines if not ln.strip().startswith("```")]
        text = "\n".join(lines).strip()
    return text


def is_read_only(sql: str) -> bool:
    first_word = sql.strip().split(None, 1)[0].upper() if sql.strip() else ""
    return first_word in ("SELECT", "WITH", "EXPLAIN", "PRAGMA")


def run_sql(sql: str):
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    cur = conn.cursor()
    try:
        try:
            cur.executescript(sql) if ";" in sql.strip().rstrip(";") else cur.execute(sql)
        except sqlite3.Error as e:
            print(f"[SQL 실행 오류] {e}")
            print("질문을 조금 더 구체적으로 바꿔서 다시 시도해보세요.")
            return
        if cur.description:
            cols = [d[0] for d in cur.description]
            print(" | ".join(cols))
            print("-" * 60)
            for row in cur.fetchall():
                print(" | ".join(str(v) for v in row))
        else:
            conn.commit()
            print(f"[완료] 영향받은 행 수: {cur.rowcount}")
    finally:
        conn.close()


def main():
    if len(sys.argv) < 2:
        print('사용법: python3 nl_query.py "한글 질문"')
        sys.exit(1)
    question = " ".join(sys.argv[1:])

    check_model_allowed()
    api_key = load_api_key()
    schema_text = SCHEMA_SQL
    reference_values = load_reference_values()

    print(f"[모델] {CHAT_MODEL} (다른 모델로 전환 불가 / .env로도 변경 불가)")
    sql = call_solar(api_key, schema_text, reference_values, question)

    print("\n[생성된 SQL]")
    print(sql)
    print()

    if is_read_only(sql):
        run_sql(sql)
    else:
        answer = input("조회가 아닌 쿼리입니다(데이터 변경). 실행할까요? [y/N] ").strip().lower()
        if answer == "y":
            run_sql(sql)
        else:
            print("실행을 취소했습니다.")


if __name__ == "__main__":
    main()
