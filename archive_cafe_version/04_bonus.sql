-- =========================================================
-- 보너스 과제
-- =========================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------
-- [보너스 1] 같은 요구를 JOIN과 서브쿼리 두 방식으로 풀기
-- 요구: "한 번도 주문한 적 없는 고객 찾기"
-- ---------------------------------------------------------

-- 방식 A. 서브쿼리 (NOT IN)
SELECT name, email
FROM customer
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- 방식 B. LEFT JOIN + IS NULL
SELECT c.name, c.email
FROM customer c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;

-- 비교 메모:
-- - 두 쿼리는 동일한 결과를 반환한다.
-- - 서브쿼리(NOT IN) 방식은 읽기 직관적이지만, orders.customer_id에 NULL이
--   존재하면 NOT IN 전체가 빈 결과를 반환하는 함정이 있다(NULL 비교는 UNKNOWN).
-- - LEFT JOIN + IS NULL 방식은 NULL 함정이 없고, 옵티마이저가 인덱스를
--   활용하기 더 쉬워 테이블이 커질수록 일반적으로 더 안정적/효율적이다.

-- ---------------------------------------------------------
-- [보너스 2] 데이터 정합성 깨뜨려 보기 (FK 위반 시도)
-- ---------------------------------------------------------

-- 시도 1: 존재하지 않는 customer_id(9999)로 주문 생성 시도
-- INSERT INTO orders (customer_id, order_date, status)
-- VALUES (9999, '2026-07-01 10:00:00', 'COMPLETED');
--
-- 실행 결과:
--   Runtime error: FOREIGN KEY constraint failed
--
-- 원인: orders.customer_id는 customer.id를 참조하는 FK인데, id=9999인
--       고객이 customer 테이블에 존재하지 않기 때문에 참조 무결성이 깨져
--       INSERT가 거부된다. (PRAGMA foreign_keys = ON 상태에서만 이렇게 막힌다)
--
-- 해결 방법: 9999가 아니라 실제 존재하는 customer.id 값을 사용하거나,
--            먼저 customer 테이블에 해당 고객을 INSERT한 뒤 주문을 생성한다.

-- 시도 2: 존재하는 주문을 참조하는 부모 행(customer)을 직접 삭제 시도
-- DELETE FROM customer WHERE id = 1;
--
-- 실행 결과:
--   Runtime error: FOREIGN KEY constraint failed
--
-- 원인: customer.id = 1을 참조하는 행이 orders 테이블에 남아있는 상태에서
--       부모 행을 먼저 지우면 자식 행(orders)이 존재하지 않는 고객을
--       참조하게 되어 무결성이 깨지므로 삭제가 거부된다.
--
-- 해결 방법: 자식 테이블(order_item -> orders)을 먼저 삭제한 뒤 customer를
--            삭제하거나, 애초에 고객을 삭제하는 대신 비활성 처리(soft delete)한다.

-- ---------------------------------------------------------
-- [보너스 3] 미니 리포트 - 핵심 지표 3개
-- ---------------------------------------------------------

-- 지표 1. 일별 주문 건수 추이 (취소 제외)
SELECT DATE(order_date) AS order_day, COUNT(*) AS order_count
FROM orders
WHERE status = 'COMPLETED'
GROUP BY order_day
ORDER BY order_day;

-- 지표 2. 가장 인기 있는 메뉴 TOP 5 (판매 수량 기준)
SELECT m.name AS menu_name, SUM(oi.quantity) AS total_qty
FROM order_item oi
INNER JOIN orders o ON oi.order_id = o.id
INNER JOIN menu m ON oi.menu_id = m.id
WHERE o.status = 'COMPLETED'
GROUP BY m.id, m.name
ORDER BY total_qty DESC
LIMIT 5;

-- 지표 3. 최근 30일(2026-06-30 기준) 내 주문 이력이 없는 휴면 고객
SELECT c.name, c.email, MAX(o.order_date) AS last_order_date
FROM customer c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'COMPLETED'
GROUP BY c.id, c.name, c.email
HAVING last_order_date IS NULL
   OR last_order_date < DATE('2026-06-30', '-30 days');
