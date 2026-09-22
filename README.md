# 국제범죄조직(TCO) 제재 데이터베이스

미국 재무부 OFAC(해외자산통제국) 제재리스트(SDN List) 중 **"TCO"(Transnational Criminal
Organization, 초국가범죄조직)** 프로그램 태그가 붙은 항목만 추려서 만든 SQLite 데이터베이스입니다.
전부 미국 정부가 공개한 실제 제재 데이터입니다(야쿠자/야마구치구미, 카모라, 티브스인로 등).

- 원본 데이터: https://www.treasury.gov/ofac/downloads/sdn.csv , https://www.treasury.gov/ofac/downloads/alt.csv
- DB: SQLite 3
- 파일 구성: Python 스크립트 3개로만 구성 (SQL/셸 스크립트 없음)

## 파일 구성

| 파일 | 역할 |
|---|---|
| `schema.py` | 테이블 정의(DDL) + 시드 데이터(DML)를 담고 있고, 실행하면 `crime_org.db`를 새로 생성/초기화 |
| `queries.py` | 과제 요구사항(기본조회/조인/집계/서브쿼리/UPDATE·DELETE/인덱스 + 보너스) 총 22개 쿼리를 실행하고 결과를 출력 |
| `nl_query.py` | 한글 자연어 질문을 solar-pro3 모델로 SQL로 변환해서 즉시 실행하는 CLI |
| `crime_org.db` | 실제 SQLite 데이터베이스 파일 |

## 스키마

- `organization` — 제재 대상 조직 (자기참조 FK로 상하 조직 계열 표현: 예 YAKUZA → YAMAGUCHI-GUMI → KODO-KAI)
- `country` — 조직원의 국적/출생 국가
- `member` — 제재 대상 개인 (`organization`, `country`에 FK)
- `alias` — 조직원 별칭 (`member`에 FK)

## 사용법

```bash
python3 schema.py            # DB 생성/초기화 (최초 1회 또는 리셋 시)
python3 queries.py           # 과제용 쿼리 전체 실행
python3 nl_query.py "질문"    # 한글 질문 -> SQL 자동 생성/실행
```

`nl_query.py`는 [Upstage Solar](https://console.upstage.ai) API 키가 필요합니다.

```bash
cp .env.example .env
# .env 파일을 열어 UPSTAGE_API_KEY=발급받은키 로 채운다
```

또는 환경변수로:

```bash
export UPSTAGE_API_KEY=발급받은키
```

`.env`는 `.gitignore`에 등록되어 있어 저장소에는 올라가지 않습니다.

### 안전장치

- 모델은 `solar-pro3`로 코드에 고정되어 있고 바꿀 수 없습니다(다른 모델은 과금).
- 2027-04-01 이후에는 모델 호출 자체가 자동으로 비활성화됩니다(무료 제공 종료 대비, 하드코딩).
- SELECT류 조회는 바로 실행되고, INSERT/UPDATE/DELETE 등 데이터를 바꾸는 쿼리는 생성된 SQL을
  먼저 보여준 뒤 사람이 확인(`y`)해야만 실행됩니다.
