-- =========================================================
-- 핵심 쿼리 모음 (01_schema.sql, 02_seed.sql 실행 후 실행)
-- 주제: 뉴욕 메트로폴리탄미술관(The Met) 소장품 데이터베이스
-- 각 쿼리 위에 "무엇을 확인하는 쿼리인지" 한 줄 설명 포함
-- =========================================================

PRAGMA foreign_keys = ON;

-- =====================================================
-- [기본 조회] WHERE / ORDER BY / LIMIT (4개)
-- =====================================================

-- Q1. 미술관 대표 소장품(하이라이트)만 조회 (WHERE)
SELECT title, object_date
FROM artwork
WHERE is_highlight = 1;

-- Q2. 소장품을 제작연도(object_date) 문자열 기준 오름차순 정렬 (ORDER BY)
SELECT title, object_date
FROM artwork
ORDER BY object_date;

-- Q3. 가장 최근에 DB에 등록된(=id가 큰) 소장품 5건 (ORDER BY + LIMIT)
SELECT id, title, object_date
FROM artwork
ORDER BY id DESC
LIMIT 5;

-- Q4. 유화(medium에 'Oil'을 포함) 작품만 조회 (WHERE + LIKE)
SELECT title, medium
FROM artwork
WHERE medium LIKE '%Oil%';

-- =====================================================
-- [조인] INNER JOIN 2개 이상 + LEFT JOIN 1개 이상 (4개)
-- =====================================================

-- Q5. 소장품 + 작가명 + 부서명 + 분류명 한 번에 조회 (INNER JOIN 3개 테이블)
SELECT aw.title, ar.name AS artist_name, d.name AS department_name, c.name AS classification_name
FROM artwork aw
INNER JOIN artist ar ON aw.artist_id = ar.id
INNER JOIN department d ON aw.department_id = d.id
INNER JOIN classification c ON aw.classification_id = c.id
ORDER BY aw.id;

-- Q6. 프랑스 국적 작가의 작품 조회 (INNER JOIN)
SELECT aw.title, ar.name AS artist_name, ar.nationality
FROM artwork aw
INNER JOIN artist ar ON aw.artist_id = ar.id
WHERE ar.nationality = 'French';

-- Q7. 모든 부서와 소장품 수 (소장품이 0건인 부서도 포함, LEFT JOIN)
SELECT d.name AS department_name, COUNT(aw.id) AS artwork_count
FROM department d
LEFT JOIN artwork aw ON d.id = aw.department_id
GROUP BY d.id, d.name
ORDER BY artwork_count DESC;

-- Q8. 모든 분류(classification)와 소장품 수 (0건 분류도 포함, LEFT JOIN)
SELECT c.name AS classification_name, COUNT(aw.id) AS artwork_count
FROM classification c
LEFT JOIN artwork aw ON c.id = aw.classification_id
GROUP BY c.id, c.name
ORDER BY artwork_count DESC;

-- =====================================================
-- [집계] COUNT / SUM / AVG + GROUP BY (3개)
-- =====================================================

-- Q9. 부서별 소장품 개수 (COUNT + GROUP BY)
SELECT d.name AS department_name, COUNT(aw.id) AS artwork_count
FROM department d
INNER JOIN artwork aw ON d.id = aw.department_id
GROUP BY d.id, d.name
ORDER BY artwork_count DESC;

-- Q10. 작가별 등록된 작품 수, 2점 이상인 작가만 (COUNT + GROUP BY + HAVING)
SELECT ar.name AS artist_name, COUNT(aw.id) AS artwork_count
FROM artist ar
INNER JOIN artwork aw ON ar.id = aw.artist_id
GROUP BY ar.id, ar.name
HAVING COUNT(aw.id) >= 2
ORDER BY artwork_count DESC;

-- Q11. 하이라이트 소장품 비율 (전체 대비 SUM/AVG 활용)
SELECT
    COUNT(*) AS total_artworks,
    SUM(is_highlight) AS highlight_count,
    ROUND(AVG(is_highlight) * 100, 1) AS highlight_percent
FROM artwork;

-- =====================================================
-- [서브쿼리] (1개 이상)
-- =====================================================

-- Q12. 소장품이 한 점도 등록되지 않은 부서 찾기 (서브쿼리 NOT IN)
SELECT name
FROM department
WHERE id NOT IN (SELECT DISTINCT department_id FROM artwork);

-- =====================================================
-- [데이터 수정 / 삭제] UPDATE, DELETE (2개)
-- =====================================================

-- Q13. 작가 미상(artist.name = '미상') 소장품의 크레딧 라인 뒤에 표기 추가 (UPDATE)
UPDATE artwork
SET credit_line = credit_line || ' (작가 미상 소장품)'
WHERE artist_id = (SELECT id FROM artist WHERE name = '미상')
  AND credit_line IS NOT NULL
  AND credit_line NOT LIKE '%(작가 미상 소장품)%';

-- Q13-확인. 변경된 소장품 수 확인
SELECT COUNT(*) AS updated_count
FROM artwork
WHERE credit_line LIKE '%(작가 미상 소장품)%';

-- Q14. 아직 한 번도 사용되지 않은(0건) 분류(classification) 삭제 (DELETE)
DELETE FROM classification
WHERE id NOT IN (SELECT DISTINCT classification_id FROM artwork);

-- Q14-확인. 남은 분류 개수 확인
SELECT COUNT(*) AS remaining_classifications FROM classification;

-- =====================================================
-- [인덱스] (1개 이상)
-- =====================================================

-- Q15. artwork.artist_id에 인덱스 생성
-- 적용 이유: 작가별 작품 조회(Q6, Q10처럼 artist_id로 JOIN/GROUP BY 하는 쿼리)가
--           빈번하므로 FK 컬럼에 인덱스를 걸어 조회 성능을 높인다.
CREATE INDEX idx_artwork_artist_id ON artwork(artist_id);

-- Q16. artwork.department_id에도 인덱스 생성 (부서별 집계 쿼리 최적화)
CREATE INDEX idx_artwork_department_id ON artwork(department_id);

-- =====================================================
-- [보너스] 부서별 하이라이트 작품 비율 TOP 3 (위 15개 외 추가 확인용)
-- =====================================================

-- Q17. 소장품 2점 이상 보유한 부서 중 하이라이트 비율 TOP 3
SELECT d.name AS department_name,
       COUNT(aw.id) AS total,
       SUM(aw.is_highlight) AS highlight_count,
       ROUND(AVG(aw.is_highlight) * 100, 1) AS highlight_percent
FROM department d
INNER JOIN artwork aw ON d.id = aw.department_id
GROUP BY d.id, d.name
HAVING COUNT(aw.id) >= 2
ORDER BY highlight_percent DESC
LIMIT 3;
