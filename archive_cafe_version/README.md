# SQL로 만드는 나만의 데이터베이스 — 카페 주문 관리

## 주제
카페 주문 관리 시스템. 카테고리 → 메뉴, 고객 → 주문, 주문 → 주문상세, 메뉴 → 주문상세로
이어지는 4개의 1:N 관계를 가진 5개 테이블로 구성했다.

## 개발 환경
- DB: SQLite3 (`sqlite3 --version` 3.51.0)
- 클라이언트: sqlite3 CLI (DBeaver 등 GUI 툴에서 `cafe.db`를 열어도 동일하게 확인 가능)

## ERD
```
category (1) ──< menu (N)
customer (1) ──< orders (N) ──< order_item (N) >── menu (1)
```
- 자세한 다이어그램은 `erd.dbml`을 https://dbdiagram.io 에 붙여넣어 이미지로 확인 가능 (선택 제출물).

## 파일 구성
| 파일 | 설명 |
|---|---|
| `01_schema.sql` | 스키마 생성 (CREATE TABLE, PK/FK/제약조건) |
| `02_seed.sql` | 샘플 데이터 (테이블당 10행 이상) |
| `03_queries.sql` | 핵심 쿼리 17개 (기본조회4/조인4/집계3/서브쿼리1/수정삭제2/인덱스2/보너스1) |
| `04_bonus.sql` | 보너스 과제 (JOIN vs 서브쿼리 비교, FK 위반 테스트, 미니 리포트) |
| `results/query_results.txt` | `03_queries.sql` 전체 실행 결과 캡처 (텍스트) |
| `results/bonus_results.txt` | `04_bonus.sql` 실행 결과 캡처 (텍스트) |
| `cafe.db` | 위 스크립트를 실행해 만들어진 실제 SQLite DB 파일 |
| `erd.dbml` | (선택) ERD 다이어그램 소스 |
| `_run_and_capture.sql`, `_run_bonus_capture.sql` | 결과 캡처용 실행 스크립트 (제출 대상 아님, sqlite3 dot-command 포함) |

## 실행 방법
```bash
rm -f cafe.db
sqlite3 cafe.db < 01_schema.sql
sqlite3 cafe.db < 02_seed.sql
sqlite3 cafe.db < 03_queries.sql      # 쿼리만 실행 (결과는 터미널에 텍스트로만 출력됨)
```
결과를 보기 좋게(테이블 박스 형태) 캡처하려면:
```bash
sqlite3 cafe.db < _run_and_capture.sql > results/query_results.txt
```

## 테이블 요약 (행 수)
| 테이블 | 행 수 | PK | FK |
|---|---|---|---|
| category | 10 | id | - |
| menu | 15 | id | category_id → category.id |
| customer | 12 | id | - |
| orders | 16 (삭제 후 14) | id | customer_id → customer.id |
| order_item | 25 (삭제 후 23) | id | order_id → orders.id, menu_id → menu.id |

`orders`/`order_item`은 `03_queries.sql`의 Q14(CANCELED 주문 삭제)를 실행한 뒤의 최종 행 수다.

## 제약조건
- NOT NULL: `menu.name`, `menu.price`, `customer.name`, `customer.email`, `orders.customer_id` 등
- UNIQUE: `category.name`, `menu.name`, `customer.email`
- FK 무결성: `PRAGMA foreign_keys = ON` 상태에서 존재하지 않는 부모 키 참조/자식이 남은 부모 삭제 시
  `FOREIGN KEY constraint failed` 에러로 차단됨을 `04_bonus.sql` 보너스2에서 실제 확인함.

## 인덱스
- `idx_orders_customer_id ON orders(customer_id)` — 고객별 주문 조회(JOIN/GROUP BY)가 빈번해 FK 컬럼에 인덱스 적용.
- `idx_order_item_menu_id ON order_item(menu_id)` — 메뉴별 판매 집계 쿼리 최적화.

## 학습 목표 자가 점검
- 엑셀과 DB의 차이: 엑셀은 하나의 평면 시트에 데이터를 중복 저장하지만, DB는 category/menu/customer/orders/order_item처럼
  테이블을 분리하고 FK로 "관계"를 명시해 중복 없이 연결한다.
- PK/FK와 1:N: 부모 테이블의 PK를 자식 테이블이 FK로 참조하면 "부모 1개에 자식 여러 개"가 자연스럽게 표현된다
  (예: 고객 1명이 주문을 여러 번 함).
- SELECT/INSERT/UPDATE/DELETE: 조회는 SELECT, 최초 데이터 적재는 INSERT, 기존 값 변경(Q13 가격 인상)은 UPDATE,
  더 이상 필요 없는 행 제거(Q14 취소 주문 삭제)는 DELETE.
- JOIN/GROUP BY: 여러 테이블에 흩어진 정보를 한 번에 묶어서(JOIN) 원하는 단위로 집계(GROUP BY)할 수 있다(Q9~Q11).
- 인덱스: FK나 WHERE/JOIN에 자주 쓰이는 컬럼에 인덱스를 걸면 풀스캔 없이 빠르게 탐색할 수 있다.
