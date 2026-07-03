-- 결과 캡처 전용 스크립트 (제출용 파일 아님, results/query_results.txt 생성용)
.headers on
.mode box

PRAGMA foreign_keys = ON;

.print '========================================================='
.print 'Q1. 하이라이트(대표) 소장품 조회 (WHERE)'
.print '========================================================='
SELECT title, object_date FROM artwork WHERE is_highlight = 1;

.print ''
.print '========================================================='
.print 'Q2. 제작연도 오름차순 정렬 (ORDER BY)'
.print '========================================================='
SELECT title, object_date FROM artwork ORDER BY object_date;

.print ''
.print '========================================================='
.print 'Q3. 최근 등록 소장품 5건 (ORDER BY + LIMIT)'
.print '========================================================='
SELECT id, title, object_date FROM artwork ORDER BY id DESC LIMIT 5;

.print ''
.print '========================================================='
.print 'Q4. 유화(medium LIKE Oil) 작품 조회 (WHERE + LIKE)'
.print '========================================================='
SELECT title, medium FROM artwork WHERE medium LIKE '%Oil%';

.print ''
.print '========================================================='
.print 'Q5. 소장품+작가+부서+분류 (INNER JOIN x3)'
.print '========================================================='
SELECT aw.title, ar.name AS artist_name, d.name AS department_name, c.name AS classification_name
FROM artwork aw
INNER JOIN artist ar ON aw.artist_id = ar.id
INNER JOIN department d ON aw.department_id = d.id
INNER JOIN classification c ON aw.classification_id = c.id
ORDER BY aw.id;

.print ''
.print '========================================================='
.print 'Q6. 프랑스 국적 작가의 작품 (INNER JOIN)'
.print '========================================================='
SELECT aw.title, ar.name AS artist_name, ar.nationality
FROM artwork aw INNER JOIN artist ar ON aw.artist_id = ar.id
WHERE ar.nationality = 'French';

.print ''
.print '========================================================='
.print 'Q7. 부서별 소장품 수, 0건 부서 포함 (LEFT JOIN)'
.print '========================================================='
SELECT d.name AS department_name, COUNT(aw.id) AS artwork_count
FROM department d LEFT JOIN artwork aw ON d.id = aw.department_id
GROUP BY d.id, d.name ORDER BY artwork_count DESC;

.print ''
.print '========================================================='
.print 'Q8. 분류별 소장품 수, 0건 분류 포함 (LEFT JOIN)'
.print '========================================================='
SELECT c.name AS classification_name, COUNT(aw.id) AS artwork_count
FROM classification c LEFT JOIN artwork aw ON c.id = aw.classification_id
GROUP BY c.id, c.name ORDER BY artwork_count DESC;

.print ''
.print '========================================================='
.print 'Q9. 부서별 소장품 개수 (COUNT + GROUP BY)'
.print '========================================================='
SELECT d.name AS department_name, COUNT(aw.id) AS artwork_count
FROM department d INNER JOIN artwork aw ON d.id = aw.department_id
GROUP BY d.id, d.name ORDER BY artwork_count DESC;

.print ''
.print '========================================================='
.print 'Q10. 작품 2점 이상 보유 작가 (COUNT + GROUP BY + HAVING)'
.print '========================================================='
SELECT ar.name AS artist_name, COUNT(aw.id) AS artwork_count
FROM artist ar INNER JOIN artwork aw ON ar.id = aw.artist_id
GROUP BY ar.id, ar.name HAVING COUNT(aw.id) >= 2 ORDER BY artwork_count DESC;

.print ''
.print '========================================================='
.print 'Q11. 하이라이트 소장품 비율 (SUM/AVG)'
.print '========================================================='
SELECT COUNT(*) AS total_artworks, SUM(is_highlight) AS highlight_count,
       ROUND(AVG(is_highlight) * 100, 1) AS highlight_percent
FROM artwork;

.print ''
.print '========================================================='
.print 'Q12. 소장품이 없는 부서 (서브쿼리 NOT IN)'
.print '========================================================='
SELECT name FROM department WHERE id NOT IN (SELECT DISTINCT department_id FROM artwork);

.print ''
.print '========================================================='
.print 'Q13. 작가 미상 소장품 크레딧 라인에 표기 추가 (UPDATE)'
.print '========================================================='
UPDATE artwork SET credit_line = credit_line || ' (작가 미상 소장품)'
WHERE artist_id = (SELECT id FROM artist WHERE name = '미상')
  AND credit_line IS NOT NULL AND credit_line NOT LIKE '%(작가 미상 소장품)%';
.print '-- 변경 확인 --'
SELECT COUNT(*) AS updated_count FROM artwork WHERE credit_line LIKE '%(작가 미상 소장품)%';

.print ''
.print '========================================================='
.print 'Q14. 미사용(0건) 분류 삭제 (DELETE)'
.print '========================================================='
DELETE FROM classification WHERE id NOT IN (SELECT DISTINCT classification_id FROM artwork);
.print '-- 삭제 확인: 남은 분류 개수 --'
SELECT COUNT(*) AS remaining_classifications FROM classification;

.print ''
.print '========================================================='
.print 'Q15/Q16. 인덱스 생성 (artist_id, department_id)'
.print '========================================================='
CREATE INDEX idx_artwork_artist_id ON artwork(artist_id);
CREATE INDEX idx_artwork_department_id ON artwork(department_id);
.print '-- 생성된 인덱스 목록 확인 --'
SELECT name, tbl_name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%';

.print ''
.print '========================================================='
.print 'Q17(보너스). 부서별 하이라이트 비율 TOP 3'
.print '========================================================='
SELECT d.name AS department_name, COUNT(aw.id) AS total,
       SUM(aw.is_highlight) AS highlight_count, ROUND(AVG(aw.is_highlight) * 100, 1) AS highlight_percent
FROM department d INNER JOIN artwork aw ON d.id = aw.department_id
GROUP BY d.id, d.name HAVING COUNT(aw.id) >= 2 ORDER BY highlight_percent DESC LIMIT 3;
