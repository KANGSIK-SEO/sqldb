-- =========================================================
-- SQL로 만드는 나만의 데이터베이스
-- 주제: 뉴욕 메트로폴리탄미술관(The Met) 소장품 데이터베이스
-- 데이터 출처: The Met Collection API (Open Access, CC0 퍼블릭 도메인)
--             https://collectionapi.metmuseum.org
-- DB: SQLite3
-- 실행 순서: 01_schema.sql -> 02_seed.sql -> 03_queries.sql
-- =========================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS artwork;
DROP TABLE IF EXISTS artist;
DROP TABLE IF EXISTS classification;
DROP TABLE IF EXISTS department;

-- ---------------------------------------------------------
-- 1. department (미술관 소장 부서, 예: European Paintings, Asian Art)
-- ---------------------------------------------------------
CREATE TABLE department (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    TEXT NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- 2. artist (작가)
-- ---------------------------------------------------------
CREATE TABLE artist (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    nationality   TEXT,
    begin_year    TEXT,
    end_year      TEXT
);

-- ---------------------------------------------------------
-- 3. classification (작품 유형, 예: Paintings, Sculpture, Drawings)
-- ---------------------------------------------------------
CREATE TABLE classification (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name    TEXT NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- 4. artwork (소장품) - department:artwork = 1:N,
--                       artist:artwork     = 1:N,
--                       classification:artwork = 1:N
-- ---------------------------------------------------------
CREATE TABLE artwork (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    met_object_id        INTEGER NOT NULL UNIQUE,  -- Met API의 원본 objectID
    title                TEXT NOT NULL,
    department_id        INTEGER NOT NULL,
    artist_id            INTEGER NOT NULL,
    classification_id    INTEGER NOT NULL,
    object_date          TEXT,
    medium               TEXT,
    dimensions           TEXT,
    credit_line          TEXT,
    is_highlight         INTEGER NOT NULL DEFAULT 0,  -- 1: 미술관 대표 소장품
    image_url            TEXT,
    image_file           TEXT,   -- images/ 폴더 내 로컬 파일명
    object_url            TEXT,   -- Met 공식 소장품 페이지 링크
    FOREIGN KEY (department_id)     REFERENCES department(id),
    FOREIGN KEY (artist_id)         REFERENCES artist(id),
    FOREIGN KEY (classification_id) REFERENCES classification(id)
);
