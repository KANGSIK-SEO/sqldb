-- 결과 캡처 전용 스크립트 (제출용 파일 아님, results/query_results.txt 생성용)
.headers on
.mode box

PRAGMA foreign_keys = ON;

.print '========================================================='
.print 'Q1. 가격 5,500원 이상 판매중 메뉴 (WHERE)'
.print '========================================================='
SELECT name, price FROM menu WHERE price >= 5500 AND is_available = 1;

.print ''
.print '========================================================='
.print 'Q2. 메뉴 가격 내림차순 정렬 (ORDER BY)'
.print '========================================================='
SELECT name, price FROM menu ORDER BY price DESC;

.print ''
.print '========================================================='
.print 'Q3. 최근 주문 5건 (ORDER BY + LIMIT)'
.print '========================================================='
SELECT id, customer_id, order_date, status FROM orders ORDER BY order_date DESC LIMIT 5;

.print ''
.print '========================================================='
.print 'Q4. 커피 카테고리 메뉴 (WHERE)'
.print '========================================================='
SELECT name, price FROM menu WHERE category_id = 1;

.print ''
.print '========================================================='
.print 'Q5. 주문 상세: 고객명+메뉴명+수량 (INNER JOIN x3)'
.print '========================================================='
SELECT o.id AS order_id, c.name AS customer_name, m.name AS menu_name,
       oi.quantity, oi.unit_price
FROM order_item oi
INNER JOIN orders o ON oi.order_id = o.id
INNER JOIN customer c ON o.customer_id = c.id
INNER JOIN menu m ON oi.menu_id = m.id
ORDER BY o.id;

.print ''
.print '========================================================='
.print 'Q6. 메뉴별 카테고리명 (INNER JOIN)'
.print '========================================================='
SELECT m.name AS menu_name, cat.name AS category_name, m.price
FROM menu m INNER JOIN category cat ON m.category_id = cat.id
ORDER BY cat.name;

.print ''
.print '========================================================='
.print 'Q7. 고객별 주문 횟수, 주문 없는 고객 포함 (LEFT JOIN)'
.print '========================================================='
SELECT c.name AS customer_name, COUNT(o.id) AS order_count
FROM customer c LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name ORDER BY order_count DESC;

.print ''
.print '========================================================='
.print 'Q8. 메뉴별 총 판매 수량, 미판매 메뉴 포함 (LEFT JOIN)'
.print '========================================================='
SELECT m.name AS menu_name, COALESCE(SUM(oi.quantity), 0) AS total_qty
FROM menu m LEFT JOIN order_item oi ON m.id = oi.menu_id
GROUP BY m.id, m.name ORDER BY total_qty DESC;

.print ''
.print '========================================================='
.print 'Q9. 카테고리별 메뉴 개수 (COUNT + GROUP BY)'
.print '========================================================='
SELECT cat.name AS category_name, COUNT(m.id) AS menu_count
FROM category cat LEFT JOIN menu m ON cat.id = m.category_id
GROUP BY cat.id, cat.name ORDER BY menu_count DESC;

.print ''
.print '========================================================='
.print 'Q10. 고객별 총 결제 금액, 취소주문 제외 (SUM + GROUP BY)'
.print '========================================================='
SELECT c.name AS customer_name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customer c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_item oi ON o.id = oi.order_id
WHERE o.status = 'COMPLETED'
GROUP BY c.id, c.name ORDER BY total_spent DESC;

.print ''
.print '========================================================='
.print 'Q11. 메뉴별 평균 주문 수량 (AVG + GROUP BY)'
.print '========================================================='
SELECT m.name AS menu_name, ROUND(AVG(oi.quantity), 2) AS avg_qty
FROM menu m INNER JOIN order_item oi ON m.id = oi.menu_id
GROUP BY m.id, m.name ORDER BY avg_qty DESC;

.print ''
.print '========================================================='
.print 'Q12. 주문 이력이 없는 고객 (서브쿼리 NOT IN)'
.print '========================================================='
SELECT name, email FROM customer
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);

.print ''
.print '========================================================='
.print 'Q13. 아메리카노 가격 인상 4500 -> 4800 (UPDATE)'
.print '========================================================='
UPDATE menu SET price = 4800 WHERE name = '아메리카노';
.print '-- 변경 확인 --'
SELECT name, price FROM menu WHERE name = '아메리카노';

.print ''
.print '========================================================='
.print 'Q14. 취소된 주문/주문상세 삭제 (DELETE)'
.print '========================================================='
DELETE FROM order_item WHERE order_id IN (SELECT id FROM orders WHERE status = 'CANCELED');
DELETE FROM orders WHERE status = 'CANCELED';
.print '-- 삭제 확인: 남은 취소주문 수 --'
SELECT COUNT(*) AS remaining_canceled_orders FROM orders WHERE status = 'CANCELED';

.print ''
.print '========================================================='
.print 'Q15/Q16. 인덱스 생성 (customer_id, menu_id)'
.print '========================================================='
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_item_menu_id ON order_item(menu_id);
.print '-- 생성된 인덱스 목록 확인 --'
SELECT name, tbl_name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%';

.print ''
.print '========================================================='
.print 'Q17(보너스). 매출 TOP 3 메뉴'
.print '========================================================='
SELECT m.name AS menu_name, SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_item oi
INNER JOIN menu m ON oi.menu_id = m.id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'COMPLETED'
GROUP BY m.id, m.name ORDER BY revenue DESC LIMIT 3;
