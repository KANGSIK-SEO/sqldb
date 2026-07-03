# SQL로 만드는 나만의 데이터베이스 — 뉴욕 메트로폴리탄미술관(The Met) 소장품 DB

## 주제
뉴욕 메트로폴리탄미술관(The Metropolitan Museum of Art)의 **실제 공공 소장품 데이터** 50점을
[The Met Collection API](https://metmuseum.github.io/) (Open Access, CC0 퍼블릭 도메인)에서 받아
department(부서) → artwork(소장품) ← artist(작가) / classification(분류) 구조로 설계했다.

- 데이터: 하이라이트(대표 소장품) 중 `isPublicDomain = true` 이고 이미지가 있는 작품만 선별
- 이미지: 각 작품의 `primaryImageSmall`을 `images/` 폴더에 실제로 다운로드 (총 4.6MB, 50장)
- 원본 메타데이터: `met_raw/objects_raw.json` (수집 스크립트: `met_raw/fetch_met.py`)

## 개발 환경
- DB: SQLite3 (`sqlite3 --version` 3.51.0)
- 클라이언트: sqlite3 CLI / DBeaver (독에 설치되어 있음, `met.db` 파일을 SQLite 연결로 열면 됨)

## ERD
```
department (1) ──< artwork (N) >── artist (1)
                        │
                        └──< classification (1)
```
- 자세한 다이어그램은 `erd.dbml`을 https://dbdiagram.io 에 붙여넣어 이미지로 확인 가능 (선택 제출물).

## 파일 구성
| 파일 | 설명 |
|---|---|
| `01_schema.sql` | 스키마 생성 (CREATE TABLE, PK/FK/제약조건) |
| `02_seed.sql` | 샘플 데이터 (Met API 실데이터 기반, `met_raw/gen_seed.py`로 생성) |
| `03_queries.sql` | 핵심 쿼리 17개 (기본조회4/조인4/집계3/서브쿼리1/수정삭제2/인덱스2/보너스1) |
| `04_bonus.sql` | 보너스 과제 (JOIN vs 서브쿼리 비교, FK 위반 테스트, 미니 리포트) |
| `results/query_results.txt` | `03_queries.sql` 전체 실행 결과 캡처 (텍스트) |
| `results/bonus_results.txt` | `04_bonus.sql` 실행 결과 캡처 (텍스트) |
| `met.db` | 위 스크립트로 생성된 실제 SQLite DB 파일 |
| `images/` | 소장품 이미지 50장 (파일명 = met_object_id) |
| `met_raw/` | Met API 원본 수집 스크립트 및 raw JSON (제출 대상 아님, 데이터 출처 확인용) |
| `erd.dbml` | (선택) ERD 다이어그램 소스 |
| `archive_cafe_version/` | 이전 버전(카페 주문 도메인) 백업, 제출 대상 아님 |

## 실행 방법
```bash
rm -f met.db
sqlite3 met.db < 01_schema.sql
sqlite3 met.db < 02_seed.sql
sqlite3 met.db < 03_queries.sql      # 쿼리만 실행
```
결과를 보기 좋게(테이블 박스 형태) 캡처하려면:
```bash
sqlite3 met.db < _run_and_capture.sql > results/query_results.txt
```

## 테이블 요약 (행 수)
| 테이블 | 행 수 | PK | FK |
|---|---|---|---|
| department | 10 | id | - |
| artist | 25 (작가 미상 1행 포함) | id | - |
| classification | 12 → 삭제 후 8 | id | - |
| artwork | 50 | id | department_id, artist_id, classification_id |

`classification`은 실제 사용된 8종(Paintings, Sculpture, Drawings, Codices, Swords, Woodwork,
Woodwork-Furniture, 미분류) + 미사용 표준분류 4종(Prints, Photographs, Ceramics, Textiles)으로
12행에서 시작하지만, `03_queries.sql`의 Q14(미사용 분류 삭제)를 실행한 뒤에는 8행만 남는다.

## 제약조건
- NOT NULL: `artwork.title`, `artwork.met_object_id`, `department.name`, `classification.name` 등
- UNIQUE: `department.name`, `classification.name`, `artwork.met_object_id`
- FK 무결성: `PRAGMA foreign_keys = ON` 상태에서 존재하지 않는 부모 키 참조/자식이 남은 부모 삭제 시
  `FOREIGN KEY constraint failed` 에러로 차단됨을 `04_bonus.sql` 보너스2에서 실제 확인함.

## 인덱스
- `idx_artwork_artist_id ON artwork(artist_id)` — 작가별 작품 조회(JOIN/GROUP BY)가 빈번해 FK 컬럼에 인덱스 적용.
- `idx_artwork_department_id ON artwork(department_id)` — 부서별 집계 쿼리 최적화.

## 데이터 특성 관련 참고
- 검색 조건을 `isHighlight=true`로 제한해 수집했기 때문에 50점 전부 `is_highlight = 1`이다.
  Q11/Q17의 "하이라이트 비율"이 100%로 나오는 것은 버그가 아니라 수집 방식에 따른 자연스러운 결과다.
- Met 소장품 중 상당수(특히 이집트 유물)는 작가가 알려져 있지 않아 `artist.name = '미상'`으로
  통일했고, `classification`이 비어 있는 경우 `'미분류'`로 통일했다. 실제 미술관 데이터베이스에서
  흔히 발생하는 "결측치 처리" 사례로 볼 수 있다.

## 학습 목표 자가 점검
- 엑셀과 DB의 차이: 엑셀은 작가명/부서명을 매 행마다 반복 저장하지만, DB는 artist/department를
  별도 테이블로 분리하고 artwork가 FK로 참조해 중복 없이 연결한다.
- PK/FK와 1:N: department 1개(예: European Paintings)에 artwork 여러 개(19점)가 FK로 연결된다.
- SELECT/INSERT/UPDATE/DELETE: 조회는 SELECT, 최초 적재는 INSERT, 기존 값 변경(Q13 크레딧 라인
  표기 추가)은 UPDATE, 불필요한 행 제거(Q14 미사용 분류 삭제)는 DELETE.
- JOIN/GROUP BY: 흩어진 department/artist/classification 정보를 artwork와 묶어(JOIN) 부서별·
  작가별 단위로 집계(GROUP BY)할 수 있다(Q9~Q11).
- 인덱스: FK나 WHERE/JOIN에 자주 쓰이는 컬럼(artist_id, department_id)에 인덱스를 걸면
  풀스캔 없이 빠르게 탐색할 수 있다.
