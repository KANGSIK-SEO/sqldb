#!/usr/bin/env python3
"""
국제범죄조직(TCO) 제재 데이터베이스 - 핵심 쿼리 모음 (과제 제출용)

실행:
    python3 schema.py     # DB 생성(최초 1회 또는 초기화하고 싶을 때)
    python3 queries.py    # 아래 쿼리를 전부 실행하고 결과를 화면에 출력
"""

import os
import sqlite3

from schema import DB_PATH

# (이름, 설명, SQL) - SQL은 여러 문장을 세미콜론으로 이어써도 된다
QUERIES = [
    # --- 기본 조회 ---
    ("Q1_일본야쿠자조직", "'일본 야쿠자' 유형 조직을 이름순으로 5개까지 조회",
     "SELECT org_name, description FROM organization WHERE org_type = '일본 야쿠자' ORDER BY org_name LIMIT 5;"),
    ("Q2_조지아국적조직원", "조지아(Georgia) 국적 조직원 조회",
     "SELECT full_name, dob FROM member WHERE country_id = (SELECT country_id FROM country WHERE country_name = 'Georgia');"),
    ("Q3_젊은조직원TOP5", "출생년도가 가장 늦은(젊은) 조직원 5명",
     "SELECT full_name, dob FROM member WHERE dob IS NOT NULL ORDER BY dob DESC LIMIT 5;"),
    ("Q4_최상위조직", "상위 조직이 없는(최상위) 조직 조회",
     "SELECT org_name, org_type FROM organization WHERE parent_org_id IS NULL;"),

    # --- 조인 ---
    ("Q5_조직원소속조직_INNERJOIN", "조직원별 소속 조직명 조회",
     "SELECT m.full_name, o.org_name FROM member m INNER JOIN organization o ON m.org_id = o.org_id ORDER BY o.org_name, m.full_name;"),
    ("Q6_조직원국적_INNERJOIN", "조직원별 국적 조회",
     "SELECT m.full_name, c.country_name FROM member m INNER JOIN country c ON m.country_id = c.country_id ORDER BY c.country_name, m.full_name;"),
    ("Q7_상하위조직_SELFJOIN", "하위 조직과 상위 조직명을 함께 조회 (자기조인)",
     "SELECT child.org_name AS sub_org, parent.org_name AS parent_org FROM organization child INNER JOIN organization parent ON child.parent_org_id = parent.org_id ORDER BY parent.org_name;"),
    ("Q8_조직원별별칭_LEFTJOIN", "별칭이 없는 조직원도 포함해서 조직원별 별칭 조회",
     "SELECT m.full_name, a.alias_name FROM member m LEFT JOIN alias a ON m.member_id = a.member_id ORDER BY m.full_name;"),

    # --- 집계 ---
    ("Q9_조직별조직원수", "조직별 조직원 수 집계",
     "SELECT o.org_name, COUNT(m.member_id) AS member_count FROM organization o LEFT JOIN member m ON o.org_id = m.org_id GROUP BY o.org_id ORDER BY member_count DESC;"),
    ("Q10_국가별조직원수", "국가별 조직원 수 집계",
     "SELECT c.country_name, COUNT(m.member_id) AS member_count FROM country c LEFT JOIN member m ON c.country_id = m.country_id GROUP BY c.country_id ORDER BY member_count DESC;"),
    ("Q11_조직유형별조직수", "조직 유형(org_type)별 조직 개수 집계",
     "SELECT org_type, COUNT(*) AS org_count FROM organization GROUP BY org_type ORDER BY org_count DESC;"),

    # --- 서브쿼리 ---
    ("Q12_조직원5명이상조직", "조직원이 5명 이상인 조직 조회 (서브쿼리)",
     "SELECT org_name FROM organization WHERE org_id IN (SELECT org_id FROM member GROUP BY org_id HAVING COUNT(*) >= 5);"),
    ("Q13_별칭없는조직원", "별칭이 하나도 등록되지 않은 조직원 찾기 (서브쿼리)",
     "SELECT full_name FROM member WHERE member_id NOT IN (SELECT DISTINCT member_id FROM alias);"),

    # --- 수정/삭제 ---
    ("Q14_UPDATE_FUKUDA국적보정", "FUKUDA, Hareaki의 국적을 Japan으로 보정",
     "UPDATE member SET country_id = (SELECT country_id FROM country WHERE country_name = 'Japan') WHERE full_name = 'FUKUDA, Hareaki';"),
    ("Q15_UPDATE_TAKEUCHI_note보강", "TAKEUCHI, Teruaki의 note를 보강",
     "UPDATE member SET note = 'KODO-KAI 조직원, YAMAGUCHI-GUMI 및 TAKAYAMA Kiyoshi와도 연계됨(OFAC 원자료 기준)' WHERE full_name = 'TAKEUCHI, Teruaki';"),
    ("Q16_DELETE_CLANCY삭제", "예시 조직원(CLANCY)을 자식 테이블부터 순서대로 삭제",
     "DELETE FROM alias WHERE member_id = (SELECT member_id FROM member WHERE full_name = 'CLANCY, Bernard Patrick'); "
     "DELETE FROM member WHERE full_name = 'CLANCY, Bernard Patrick';"),

    # --- 인덱스 ---
    ("Q17_인덱스_member_org_id", "member.org_id 에 인덱스 생성 (조직별 조회가 잦아서)",
     "CREATE INDEX IF NOT EXISTS idx_member_org_id ON member(org_id); "
     "SELECT name, tbl_name FROM sqlite_master WHERE type='index' AND name='idx_member_org_id';"),

    # --- 보너스 1: JOIN vs 서브쿼리 ---
    ("보너스1A_JOIN방식_ThievesInLaw", "THIEVES-IN-LAW 소속 조직원 (JOIN 방식)",
     "SELECT m.full_name FROM member m INNER JOIN organization o ON m.org_id = o.org_id WHERE o.org_name = 'THIEVES-IN-LAW' ORDER BY m.full_name;"),
    ("보너스1B_서브쿼리방식_ThievesInLaw", "THIEVES-IN-LAW 소속 조직원 (서브쿼리 방식)",
     "SELECT full_name FROM member WHERE org_id = (SELECT org_id FROM organization WHERE org_name = 'THIEVES-IN-LAW') ORDER BY full_name;"),

    # --- 보너스 3: 미니 리포트 ---
    ("보너스3_지표1_조직유형별조직원수", "조직 유형별 조직원 수 합계",
     "SELECT o.org_type, COUNT(m.member_id) AS member_count FROM organization o LEFT JOIN member m ON o.org_id = m.org_id GROUP BY o.org_type ORDER BY member_count DESC;"),
    ("보너스3_지표2_조직원많은조직TOP3", "조직원이 가장 많은 조직 TOP 3",
     "SELECT o.org_name, COUNT(m.member_id) AS member_count FROM organization o INNER JOIN member m ON o.org_id = m.org_id GROUP BY o.org_id ORDER BY member_count DESC LIMIT 3;"),
    ("보너스3_지표3_야마구치구미계열총합", "야마구치구미 계열(자기 자신 + 하위 조직) 조직원 총합",
     "SELECT COUNT(*) AS yamaguchi_family_member_count FROM member WHERE org_id IN ("
     "SELECT org_id FROM organization WHERE org_name = 'YAMAGUCHI-GUMI' "
     "UNION SELECT org_id FROM organization WHERE parent_org_id = (SELECT org_id FROM organization WHERE org_name = 'YAMAGUCHI-GUMI'));"),
]

# 보너스 2: 데이터 정합성 깨뜨려 보기 (일부러 실패해야 정상)
FK_VIOLATION_DEMO_SQL = "INSERT INTO member (full_name, org_id, ofac_ent_num) VALUES ('없는조직원', 999, 99999);"


def run_query(conn: sqlite3.Connection, sql: str):
    cur = conn.cursor()
    cur.executescript(sql) if ";" in sql.strip().rstrip(";") else cur.execute(sql)
    if cur.description:
        cols = [d[0] for d in cur.description]
        rows = cur.fetchall()
        print(" | ".join(cols))
        print("-" * 60)
        for row in rows:
            print(" | ".join(str(v) for v in row))
    else:
        conn.commit()
        print(f"[완료] 영향받은 행 수: {cur.rowcount}")


def run_all():
    if not os.path.exists(DB_PATH):
        print("[오류] DB가 없습니다. 먼저 `python3 schema.py`를 실행하세요.")
        return

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")

    for name, desc, sql in QUERIES:
        print(f"\n===== {name} : {desc} =====")
        print(sql)
        print()
        run_query(conn, sql)

    print("\n===== 보너스2_FK위반재현 : 존재하지 않는 org_id(999)를 참조해서 일부러 실패시키기 =====")
    print(FK_VIOLATION_DEMO_SQL)
    print()
    try:
        conn.execute(FK_VIOLATION_DEMO_SQL)
        conn.commit()
        print("[예상과 다름] 삽입이 성공했습니다 (FK가 꺼져있는지 확인 필요)")
    except sqlite3.IntegrityError as e:
        print(f"[의도된 실패] {e}")

    conn.close()


if __name__ == "__main__":
    run_all()
