-- =========================================================
-- 06_gallery.sql — 피날레: SQL로 이미지 갤러리 리포트 생성
-- SELECT가 HTML 문자열을 출력해 gallery.html을 만들고 바로 연다.
-- 실행: sqlite3 met.db < 06_gallery.sql
-- (images/ 폴더와 같은 위치에서 실행할 것)
-- =========================================================
.mode list
.headers off
.output gallery.html

SELECT '<!doctype html><html lang="ko"><meta charset="utf-8">
<title>이볼라르 인벤토리 리포트 — The Met 컬렉션 50점</title>
<style>
 body{font-family:-apple-system,sans-serif;background:#141414;color:#eee;margin:0}
 h1{font-size:20px;padding:24px 28px 4px}
 p.sub{color:#9a9a9a;padding:0 28px 8px;margin:0;font-size:13px}
 .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px;padding:24px 28px}
 .card{background:#1f1f21;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,.4)}
 .card img{width:100%;height:190px;object-fit:cover;display:block}
 .meta{padding:10px 12px;font-size:12.5px;line-height:1.45}
 .meta b{font-size:13px}
 .tag{display:inline-block;margin-top:6px;padding:2px 8px;border-radius:99px;font-size:11px;background:#2e3b55;color:#aecbff}
 .tag.risk{background:#553030;color:#ffb3b3}
</style>
<h1>이볼라르 인벤토리 리포트</h1>
<p class="sub">The Met 공개 소장품 50점 · met.db에서 SQL로 자동 생성</p>
<div class="grid">';

SELECT '<div class="card"><img src="images/' || w.image_file || '" alt="">'
    || '<div class="meta"><b>' || w.title || '</b><br>'
    || a.name || ' · ' || COALESCE(w.object_date,'연대 미상') || '<br>'
    || d.name
    || CASE WHEN a.name = '미상'
            THEN '<br><span class="tag risk">작가 미상 · 검증 대상</span>'
            ELSE '<br><span class="tag">작가 확인</span>' END
    || '</div></div>'
FROM artwork w
JOIN artist a     ON a.id = w.artist_id
JOIN department d ON d.id = w.department_id
ORDER BY (a.name = '미상'), d.name, w.title;

SELECT '</div></html>';

.output stdout
.shell open gallery.html
