import json

def esc(s):
    if s is None:
        return "NULL"
    s = str(s).replace("'", "''")
    return f"'{s}'"

data = json.load(open("objects_raw.json"))

# --- department ---
departments = sorted(set(d["department"] for d in data))

# --- classification: 실제 사용된 값 + 표준 Met 분류 중 미사용 값 몇 개(0건짜리) 추가 ---
used_classifications = sorted(set((d["classification"] or "미분류") for d in data))
extra_unused_classifications = ["Prints", "Photographs", "Ceramics", "Textiles"]
classifications = used_classifications + [c for c in extra_unused_classifications if c not in used_classifications]

# --- artist: 이름 없는 항목은 '미상'으로 통일 ---
def artist_key(d):
    return d["artistDisplayName"] or "미상"

artists = {}
for d in data:
    key = artist_key(d)
    if key not in artists:
        artists[key] = {
            "name": key,
            "nationality": d["artistNationality"] if key != "미상" else "",
            "begin_year": d["artistBeginDate"] if key != "미상" else "",
            "end_year": d["artistEndDate"] if key != "미상" else "",
        }

dept_idx = {name: i + 1 for i, name in enumerate(departments)}
class_idx = {name: i + 1 for i, name in enumerate(classifications)}
artist_names = list(artists.keys())
artist_idx = {name: i + 1 for i, name in enumerate(artist_names)}

lines = []
lines.append("-- =========================================================")
lines.append("-- 샘플 데이터 입력 (01_schema.sql 실행 후 실행)")
lines.append("-- 출처: The Metropolitan Museum of Art Open Access API (CC0)")
lines.append("-- 부모 테이블(department, artist, classification) 먼저 -> artwork 순서")
lines.append("-- =========================================================")
lines.append("")
lines.append("PRAGMA foreign_keys = ON;")
lines.append("")

lines.append(f"-- department ({len(departments)}행)")
lines.append("INSERT INTO department (name) VALUES")
lines.append(",\n".join(f"({esc(n)})" for n in departments) + ";")
lines.append("")

lines.append(f"-- classification ({len(classifications)}행, 실사용 {len(used_classifications)} + 미사용 표준분류 {len(classifications)-len(used_classifications)})")
lines.append("INSERT INTO classification (name) VALUES")
lines.append(",\n".join(f"({esc(n)})" for n in classifications) + ";")
lines.append("")

lines.append(f"-- artist ({len(artist_names)}행)")
lines.append("INSERT INTO artist (name, nationality, begin_year, end_year) VALUES")
rows = []
for name in artist_names:
    a = artists[name]
    rows.append(f"({esc(a['name'])}, {esc(a['nationality']) if a['nationality'] else 'NULL'}, "
                f"{esc(a['begin_year']) if a['begin_year'] else 'NULL'}, {esc(a['end_year']) if a['end_year'] else 'NULL'})")
lines.append(",\n".join(rows) + ";")
lines.append("")

lines.append(f"-- artwork ({len(data)}행)")
lines.append("INSERT INTO artwork (met_object_id, title, department_id, artist_id, classification_id, "
              "object_date, medium, dimensions, credit_line, is_highlight, image_url, image_file, object_url) VALUES")
rows = []
for d in data:
    dept_id = dept_idx[d["department"]]
    cls_id = class_idx[d["classification"] or "미분류"]
    art_id = artist_idx[artist_key(d)]
    rows.append(
        "(" + ", ".join([
            str(d["objectID"]),
            esc(d["title"]),
            str(dept_id),
            str(art_id),
            str(cls_id),
            esc(d["objectDate"]) if d["objectDate"] else "NULL",
            esc(d["medium"]) if d["medium"] else "NULL",
            esc(d["dimensions"]) if d["dimensions"] else "NULL",
            esc(d["creditLine"]) if d["creditLine"] else "NULL",
            "1" if d["isHighlight"] else "0",
            esc(d["image_url"]) if d["image_url"] else "NULL",
            esc(d["image_file"]) if d["image_file"] else "NULL",
            esc(d["objectURL"]) if d["objectURL"] else "NULL",
        ]) + ")"
    )
lines.append(",\n".join(rows) + ";")
lines.append("")

with open("../02_seed.sql", "w") as f:
    f.write("\n".join(lines))

print("departments:", len(departments))
print("classifications:", len(classifications))
print("artists:", len(artist_names))
print("artworks:", len(data))
print("written ../02_seed.sql")
