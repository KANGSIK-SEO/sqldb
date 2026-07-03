-- =========================================================
-- 보너스 과제 (뉴욕 메트로폴리탄미술관 소장품 DB)
-- =========================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------
-- [보너스 1] 같은 요구를 JOIN과 서브쿼리 두 방식으로 풀기
-- 요구: "소장품이 한 점도 없는 부서 찾기"
-- ---------------------------------------------------------

-- 방식 A. 서브쿼리 (NOT IN)
SELECT name
FROM department
WHERE id NOT IN (SELECT DISTINCT department_id FROM artwork);

-- 방식 B. LEFT JOIN + IS NULL
SELECT d.name
FROM department d
LEFT JOIN artwork aw ON d.id = aw.department_id
WHERE aw.id IS NULL;

-- 비교 메모:
-- - 두 쿼리는 동일한 결과를 반환한다 (본 데이터셋에서는 결과가 0건 — 10개 부서
--   모두 최소 1점 이상의 소장품을 갖고 있기 때문).
-- - artwork.department_id는 NOT NULL 제약이 있어 NOT IN의 NULL 함정은
--   발생하지 않지만, 일반적으로는 LEFT JOIN + IS NULL 방식이 NULL 안전성과
--   대용량 데이터에서의 인덱스 활용 측면에서 더 안정적이다.

-- ---------------------------------------------------------
-- [보너스 2] 데이터 정합성 깨뜨려 보기 (FK 위반 시도)
-- ---------------------------------------------------------

-- 시도 1: 존재하지 않는 department_id(9999)로 소장품 등록 시도
-- INSERT INTO artwork (met_object_id, title, department_id, artist_id, classification_id)
-- VALUES (999999, 'Fake Artwork', 9999, 1, 1);
--
-- 실행 결과:
--   Runtime error: FOREIGN KEY constraint failed
--
-- 원인: artwork.department_id는 department.id를 참조하는 FK인데, id=9999인
--       부서가 department 테이블에 존재하지 않아 참조 무결성이 깨지므로
--       INSERT가 거부된다. (PRAGMA foreign_keys = ON 상태에서만 이렇게 막힌다)
--
-- 해결 방법: 9999가 아닌 실제 존재하는 department.id 값을 사용하거나,
--            먼저 department 테이블에 새 부서를 INSERT한 뒤 소장품을 등록한다.

-- 시도 2: 소장품이 남아있는 부서(European Paintings, id=5)를 직접 삭제 시도
-- DELETE FROM department WHERE name = 'European Paintings';
--
-- 실행 결과:
--   Runtime error: FOREIGN KEY constraint failed
--
-- 원인: 해당 department.id를 참조하는 artwork 행이 19건 남아있는 상태에서
--       부모 행을 먼저 지우면 자식 행(artwork)이 존재하지 않는 부서를
--       참조하게 되어 무결성이 깨지므로 삭제가 거부된다.
--
-- 해결 방법: 해당 부서를 참조하는 artwork 행을 먼저 다른 부서로 옮기거나
--            삭제한 뒤 department를 삭제한다.

-- ---------------------------------------------------------
-- [보너스 3] 미니 리포트 - 핵심 지표 3개
-- ---------------------------------------------------------

-- 지표 1. 시대별(세기별) 소장품 분포 - object_date에서 연도를 파싱하기 어려운
--        텍스트가 많아, 대신 "부서 x 분류" 교차 집계로 대체한 소장품 구성 현황
SELECT d.name AS department_name, c.name AS classification_name, COUNT(*) AS cnt
FROM artwork aw
INNER JOIN department d ON aw.department_id = d.id
INNER JOIN classification c ON aw.classification_id = c.id
GROUP BY d.id, d.name, c.id, c.name
ORDER BY cnt DESC;

-- 지표 2. 작품을 가장 많이 보유한 작가 TOP 5 (미상 제외)
SELECT ar.name AS artist_name, COUNT(aw.id) AS artwork_count
FROM artist ar
INNER JOIN artwork aw ON ar.id = aw.artist_id
WHERE ar.name != '미상'
GROUP BY ar.id, ar.name
ORDER BY artwork_count DESC
LIMIT 5;

-- 지표 3. 작가 미상(anonymous) 소장품 비율이 가장 높은 부서
SELECT d.name AS department_name,
       COUNT(*) AS total,
       SUM(CASE WHEN ar.name = '미상' THEN 1 ELSE 0 END) AS anonymous_count,
       ROUND(100.0 * SUM(CASE WHEN ar.name = '미상' THEN 1 ELSE 0 END) / COUNT(*), 1) AS anonymous_percent
FROM artwork aw
INNER JOIN department d ON aw.department_id = d.id
INNER JOIN artist ar ON aw.artist_id = ar.id
GROUP BY d.id, d.name
ORDER BY anonymous_percent DESC;
