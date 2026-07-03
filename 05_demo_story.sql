-- =========================================================
-- 05_demo_story.sql — 동료평가 라이브 데모 (10장면)
-- 스토리: "미술품 진위검증 서비스(이볼라르)의 하루"
--   한 컬렉터가 소장품 50점의 검증을 의뢰했다.
--   접수 → 분석 → 리스크 발견 → 리포트 납품까지를
--   met.db 쿼리 10개로 재연한다.
-- 실행: sqlite3 met.db < 05_demo_story.sql
-- (전제: 01_schema → 02_seed → 03_queries 실행 후 상태)
-- =========================================================
.headers on
.mode box

-- ─────────────────────────────────────────────
-- 장면 1. [접수] 컬렉션이 도착했다 — 자산 규모부터 파악
-- "몇 점이고, 관련 명단은 얼마나 되는가"
-- ─────────────────────────────────────────────
SELECT '소장품(artwork)' AS 장부, COUNT(*) AS 행수 FROM artwork
UNION ALL SELECT '작가(artist)',        COUNT(*) FROM artist
UNION ALL SELECT '부서(department)',    COUNT(*) FROM department
UNION ALL SELECT '분류(classification)',COUNT(*) FROM classification;

-- ─────────────────────────────────────────────
-- 장면 2. [지형도] 이 컬렉션의 무게중심은 어디인가
-- GROUP BY: 유럽회화와 이집트 유물, 두 축이 보인다
-- ─────────────────────────────────────────────
SELECT d.name AS 부서, COUNT(*) AS 작품수
FROM artwork w JOIN department d ON d.id = w.department_id
GROUP BY d.name ORDER BY 작품수 DESC;

-- ─────────────────────────────────────────────
-- 장면 3. [스타 확인] 이름값 있는 작가부터 — 검증 1순위
-- JOIN: 마네, 세잔, 렘브란트가 이 컬렉션에 있다
-- ─────────────────────────────────────────────
SELECT a.name AS 작가, w.title AS 작품, w.object_date AS 제작연도
FROM artwork w JOIN artist a ON a.id = w.artist_id
WHERE a.name IN ('Edouard Manet', 'Paul Cézanne', 'Rembrandt (Rembrandt van Rijn)')
ORDER BY a.name;

-- ─────────────────────────────────────────────
-- 장면 4. [리스크 발견] 작가를 모르는 작품이 몇 점인가
-- 진위검증 수요는 바로 여기서 나온다: 48%
-- ─────────────────────────────────────────────
SELECT COUNT(*) AS 작가미상_작품수,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM artwork), 1) AS 비율
FROM artwork w JOIN artist a ON a.id = w.artist_id
WHERE a.name = '미상';

-- ─────────────────────────────────────────────
-- 장면 5. [리스크 해부] 미상 24점은 어디에 몰려 있나
-- 이집트 유물 18점 — 고대유물은 원래 작가가 없다.
-- 즉 '미상'의 성격이 부서마다 다르다 → 검증 전략도 달라진다
-- ─────────────────────────────────────────────
SELECT d.name AS 부서, COUNT(*) AS 미상작품수
FROM artwork w
JOIN artist a     ON a.id = w.artist_id
JOIN department d ON d.id = w.department_id
WHERE a.name = '미상'
GROUP BY d.name ORDER BY 미상작품수 DESC;

-- ─────────────────────────────────────────────
-- 장면 6. [출처 조사] provenance — 어떤 경로로 들어온 물건인가
-- 진위검증의 절반은 소장 이력이다. credit_line이 그 기록.
-- (Q13 UPDATE로 미상 작품에 표기를 정비해 둔 상태)
-- ─────────────────────────────────────────────
SELECT w.title AS 작품, w.credit_line AS 입수경로
FROM artwork w JOIN artist a ON a.id = w.artist_id
WHERE a.name = '미상'
ORDER BY w.id LIMIT 5;

-- ─────────────────────────────────────────────
-- 장면 7. [실물 대조] 감정 리포트의 물리 데이터
-- 매체와 실측 치수 — 위작은 여기서 먼저 어긋난다
-- ─────────────────────────────────────────────
SELECT a.name AS 작가, w.title AS 작품, w.medium AS 매체, w.dimensions AS 치수
FROM artwork w JOIN artist a ON a.id = w.artist_id
WHERE a.name LIKE '%Rembrandt%';

-- ─────────────────────────────────────────────
-- 장면 8. [보험 우선순위] 대표 소장품 비율
-- 100%가 나온다 — 버그가 아니라 수집 조건(isHighlight=true) 때문.
-- 데이터의 한계를 아는 것도 분석의 일부다.
-- ─────────────────────────────────────────────
SELECT COUNT(*) AS 전체, SUM(is_highlight) AS 하이라이트,
       ROUND(100.0 * SUM(is_highlight) / COUNT(*), 1) AS 비율
FROM artwork;

-- ─────────────────────────────────────────────
-- 장면 9. [속도] 24시간 핫라인은 풀스캔으로 못 버틴다
-- EXPLAIN QUERY PLAN: 인덱스로 SEARCH — 장부를 다 뒤지지 않는다
-- ─────────────────────────────────────────────
EXPLAIN QUERY PLAN
SELECT w.title FROM artwork w WHERE w.artist_id = 3;

-- ─────────────────────────────────────────────
-- 장면 10. [납품] 원페이지 인벤토리 리포트
-- 부서별 작품수 × 미상수 × 미상비율 — 고객에게 건네는 최종 산출물
-- ─────────────────────────────────────────────
SELECT d.name AS 부서,
       COUNT(*) AS 작품수,
       SUM(a.name = '미상') AS 작가미상,
       ROUND(100.0 * SUM(a.name = '미상') / COUNT(*), 1) AS 미상비율
FROM artwork w
JOIN artist a     ON a.id = w.artist_id
JOIN department d ON d.id = w.department_id
GROUP BY d.name
ORDER BY 작품수 DESC;
