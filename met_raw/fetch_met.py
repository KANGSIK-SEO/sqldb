import json
import os
import time
import urllib.request

BASE = "https://collectionapi.metmuseum.org/public/collection/v1/objects/"
IDS_FILE = "search_ids.json"
OUT_META = "objects_raw.json"
IMAGES_DIR = "../images"
TARGET_COUNT = 50

os.makedirs(IMAGES_DIR, exist_ok=True)

with open(IDS_FILE) as f:
    ids = json.load(f)["objectIDs"]

collected = []
seen_titles = set()

for oid in ids:
    if len(collected) >= TARGET_COUNT:
        break
    try:
        with urllib.request.urlopen(BASE + str(oid), timeout=15) as resp:
            obj = json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        print(f"skip {oid}: fetch error {e}")
        continue

    if not obj.get("isPublicDomain"):
        continue
    img_url = obj.get("primaryImageSmall") or obj.get("primaryImage")
    if not img_url:
        continue
    title = (obj.get("title") or "").strip()
    if not title or title in seen_titles:
        continue

    # download image
    ext = os.path.splitext(img_url.split("?")[0])[1] or ".jpg"
    if ext.lower() not in (".jpg", ".jpeg", ".png"):
        ext = ".jpg"
    filename = f"{oid}{ext}"
    local_path = os.path.join(IMAGES_DIR, filename)
    try:
        urllib.request.urlretrieve(img_url, local_path)
    except Exception as e:
        print(f"skip {oid}: image download error {e}")
        continue

    seen_titles.add(title)
    collected.append({
        "objectID": oid,
        "title": title,
        "artistDisplayName": obj.get("artistDisplayName") or "",
        "artistNationality": obj.get("artistNationality") or "",
        "artistBeginDate": obj.get("artistBeginDate") or "",
        "artistEndDate": obj.get("artistEndDate") or "",
        "department": obj.get("department") or "",
        "classification": obj.get("classification") or "",
        "objectDate": obj.get("objectDate") or "",
        "medium": obj.get("medium") or "",
        "dimensions": obj.get("dimensions") or "",
        "creditLine": obj.get("creditLine") or "",
        "isHighlight": obj.get("isHighlight", False),
        "objectURL": obj.get("objectURL") or "",
        "image_url": img_url,
        "image_file": filename,
    })
    print(f"[{len(collected)}/{TARGET_COUNT}] {oid} - {title[:40]}")
    time.sleep(0.15)

with open(OUT_META, "w") as f:
    json.dump(collected, f, ensure_ascii=False, indent=2)

print(f"done. collected={len(collected)}")
