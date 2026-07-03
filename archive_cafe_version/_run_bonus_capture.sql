.headers on
.mode box
PRAGMA foreign_keys = ON;

.print '=== 보너스1-A. 주문 없는 고객 (서브쿼리 NOT IN) ==='
SELECT name, email FROM customer WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);

.print ''
.print '=== 보너스1-B. 주문 없는 고객 (LEFT JOIN + IS NULL) ==='
SELECT c.name, c.email FROM customer c LEFT JOIN orders o ON c.id = o.customer_id WHERE o.id IS NULL;

.print ''
.print '=== 보너스3-지표1. 일별 주문 건수 추이 ==='
SELECT DATE(order_date) AS order_day, COUNT(*) AS order_count
FROM orders WHERE status = 'COMPLETED' GROUP BY order_day ORDER BY order_day;

.print ''
.print '=== 보너스3-지표2. 인기 메뉴 TOP 5 (판매수량) ==='
SELECT m.name AS menu_name, SUM(oi.quantity) AS total_qty
FROM order_item oi
INNER JOIN orders o ON oi.order_id = o.id
INNER JOIN menu m ON oi.menu_id = m.id
WHERE o.status = 'COMPLETED'
GROUP BY m.id, m.name ORDER BY total_qty DESC LIMIT 5;

.print ''
.print '=== 보너스3-지표3. 30일 이상 휴면 고객 (2026-06-30 기준) ==='
SELECT c.name, c.email, MAX(o.order_date) AS last_order_date
FROM customer c
LEFT JOIN orders o ON c.id = o.customer_id AND o.status = 'COMPLETED'
GROUP BY c.id, c.name, c.email
HAVING last_order_date IS NULL OR last_order_date < DATE('2026-06-30', '-30 days');
