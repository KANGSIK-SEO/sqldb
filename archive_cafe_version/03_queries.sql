-- =========================================================
-- 핵심 쿼리 모음 (01_schema.sql, 02_seed.sql 실행 후 실행)
-- 각 쿼리 위에 "무엇을 확인하는 쿼리인지" 한 줄 설명 포함
-- =========================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- [기본 조회] WHERE / ORDER BY / LIMIT (4개)
-- =====================================================

-- Q1. 가격이 5,500원 이상인 판매중인 메뉴 조회 (WHERE)
SELECT name, price
FROM menu
WHERE price >= 5500 AND is_available = 1;

-- Q2. 메뉴를 가격 내림차순으로 정렬 (ORDER BY)
SELECT name, price
FROM menu
ORDER BY price DESC;

-- Q3. 가장 최근 주문 5건 조회 (ORDER BY + LIMIT)
SELECT id, customer_id, order_date, status
FROM orders
ORDER BY order_date DESC
LIMIT 5;

-- Q4. '커피' 카테고리(category_id = 1) 메뉴만 조회 (WHERE)
SELECT name, price
FROM menu
WHERE category_id = 1;

-- =====================================================
-- [조인] INNER JOIN 2개 이상 + LEFT JOIN 1개 이상 (4개)
-- =====================================================

-- Q5. 주문 상세 내역: 고객명 + 메뉴명 + 수량 (INNER JOIN 3개 테이블)
SELECT o.id AS order_id, c.name AS customer_name, m.name AS menu_name,
       oi.quantity, oi.unit_price
FROM order_item oi
INNER JOIN orders o ON oi.order_id = o.id
INNER JOIN customer c ON o.customer_id = c.id
INNER JOIN menu m ON oi.menu_id = m.id
ORDER BY o.id;

-- Q6. 메뉴별 카테고리명 함께 조회 (INNER JOIN)
SELECT m.name AS menu_name, cat.name AS category_name, m.price
FROM menu m
INNER JOIN category cat ON m.category_id = cat.id
ORDER BY cat.name;

-- Q7. 모든 고객과 주문 횟수 (주문이 없는 고객도 0으로 포함, LEFT JOIN)
SELECT c.name AS customer_name, COUNT(o.id) AS order_count
FROM customer c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY order_count DESC;

-- Q8. 모든 메뉴와 주문된 총 수량 (한 번도 안 팔린 메뉴도 포함, LEFT JOIN)
SELECT m.name AS menu_name, COALESCE(SUM(oi.quantity), 0) AS total_qty
FROM menu m
LEFT JOIN order_item oi ON m.id = oi.menu_id
GROUP BY m.id, m.name
ORDER BY total_qty DESC;

-- =====================================================
-- [집계] COUNT / SUM / AVG + GROUP BY (3개)
-- =====================================================

-- Q9. 카테고리별 등록된 메뉴 개수 (COUNT + GROUP BY)
SELECT cat.name AS category_name, COUNT(m.id) AS menu_count
FROM category cat
LEFT JOIN menu m ON cat.id = m.category_id
GROUP BY cat.id, cat.name
ORDER BY menu_count DESC;

-- Q10. 고객별 총 결제 금액 (SUM + GROUP BY, 취소 주문 제외)
SELECT c.name AS customer_name,
       SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customer c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_item oi ON o.id = oi.order_id
WHERE o.status = 'COMPLETED'
GROUP BY c.id, c.name
ORDER BY total_spent DESC;

-- Q11. 메뉴별 평균 주문 수량 (AVG + GROUP BY)
SELECT m.name AS menu_name, ROUND(AVG(oi.quantity), 2) AS avg_qty
FROM menu m
INNER JOIN order_item oi ON m.id = oi.menu_id
GROUP BY m.id, m.name
ORDER BY avg_qty DESC;

-- =====================================================
-- [서브쿼리] (1개 이상)
-- =====================================================

-- Q12. 한 번도 주문한 적 없는 고객 찾기 (서브쿼리 NOT IN)
SELECT name, email
FROM customer
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- =====================================================
-- [데이터 수정 / 삭제] UPDATE, DELETE (2개)
-- =====================================================

-- Q13. '아메리카노' 가격을 4,500원 -> 4,800원으로 인상 (UPDATE)
UPDATE menu
SET price = 4800
WHERE name = '아메리카노';

-- Q13-확인. 변경된 가격 확인
SELECT name, price FROM menu WHERE name = '아메리카노';

-- Q14. 취소(CANCELED) 상태인 주문의 주문상세(order_item)부터 삭제 후 주문 삭제 (DELETE)
DELETE FROM order_item
WHERE order_id IN (SELECT id FROM orders WHERE status = 'CANCELED');

DELETE FROM orders
WHERE status = 'CANCELED';

-- Q14-확인. 취소 주문이 모두 삭제되었는지 확인
SELECT COUNT(*) AS remaining_canceled_orders
FROM orders WHERE status = 'CANCELED';

-- =====================================================
-- [인덱스] (1개 이상)
-- =====================================================

-- Q15. orders.customer_id에 인덱스 생성
-- 적용 이유: 고객별 주문 조회(Q7, Q10처럼 customer_id로 JOIN/GROUP BY 하는 쿼리)가
--           빈번하므로 FK 컬럼에 인덱스를 걸어 조회 성능을 높인다.
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Q16. order_item.menu_id에도 인덱스 생성 (메뉴별 판매 집계 쿼리 최적화)
CREATE INDEX idx_order_item_menu_id ON order_item(menu_id);

-- =====================================================
-- [보너스] 매출 TOP 3 메뉴 (집계 + 정렬 + LIMIT, 위 15개 외 추가 확인용)
-- =====================================================

-- Q17. 매출 상위 3개 메뉴
SELECT m.name AS menu_name,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_item oi
INNER JOIN menu m ON oi.menu_id = m.id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'COMPLETED'
GROUP BY m.id, m.name
ORDER BY revenue DESC
LIMIT 3;
