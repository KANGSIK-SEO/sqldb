.headers on
.mode box
PRAGMA foreign_keys = ON;

.print '=== 보너스1-A. 소장품 없는 부서 (서브쿼리 NOT IN) ==='
SELECT name FROM department WHERE id NOT IN (SELECT DISTINCT department_id FROM artwork);

.print ''
.print '=== 보너스1-B. 소장품 없는 부서 (LEFT JOIN + IS NULL) ==='
SELECT d.name FROM department d LEFT JOIN artwork aw ON d.id = aw.department_id WHERE aw.id IS NULL;

.print ''
.print '=== 보너스3-지표1. 부서 x 분류 교차 집계 ==='
SELECT d.name AS department_name, c.name AS classification_name, COUNT(*) AS cnt
FROM artwork aw
INNER JOIN department d ON aw.department_id = d.id
INNER JOIN classification c ON aw.classification_id = c.id
GROUP BY d.id, d.name, c.id, c.name
ORDER BY cnt DESC;

.print ''
.print '=== 보너스3-지표2. 작품 최다 보유 작가 TOP 5 (미상 제외) ==='
SELECT ar.name AS artist_name, COUNT(aw.id) AS artwork_count
FROM artist ar INNER JOIN artwork aw ON ar.id = aw.artist_id
WHERE ar.name != '미상'
GROUP BY ar.id, ar.name ORDER BY artwork_count DESC LIMIT 5;

.print ''
.print '=== 보너스3-지표3. 작가미상 비율 높은 부서 ==='
SELECT d.name AS department_name, COUNT(*) AS total,
       SUM(CASE WHEN ar.name = '미상' THEN 1 ELSE 0 END) AS anonymous_count,
       ROUND(100.0 * SUM(CASE WHEN ar.name = '미상' THEN 1 ELSE 0 END) / COUNT(*), 1) AS anonymous_percent
FROM artwork aw
INNER JOIN department d ON aw.department_id = d.id
INNER JOIN artist ar ON aw.artist_id = ar.id
GROUP BY d.id, d.name ORDER BY anonymous_percent DESC;
