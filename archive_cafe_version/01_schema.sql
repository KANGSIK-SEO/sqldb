-- =========================================================
-- SQL로 만드는 나만의 데이터베이스
-- 주제: 카페 주문 관리 (Cafe Order Management)
-- DB: SQLite3
-- 실행 순서: 01_schema.sql -> 02_seed.sql -> 03_queries.sql
-- =========================================================

PRAGMA foreign_keys = ON;  -- SQLite 전용: FK 제약조건 실제로 동작하게 하려면 반드시 켜야 함

-- 기존 테이블 초기화 (재실행 대비)
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS category;

-- ---------------------------------------------------------
-- 1. category (메뉴 카테고리)
-- ---------------------------------------------------------
CREATE TABLE category (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- 2. menu (메뉴) - category : menu = 1 : N
-- ---------------------------------------------------------
CREATE TABLE menu (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL UNIQUE,
    category_id   INTEGER NOT NULL,
    price         INTEGER NOT NULL,
    is_available  INTEGER NOT NULL DEFAULT 1,  -- 1: 판매중, 0: 단종
    FOREIGN KEY (category_id) REFERENCES category(id)
);

-- ---------------------------------------------------------
-- 3. customer (고객)
-- ---------------------------------------------------------
CREATE TABLE customer (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    phone       TEXT,
    joined_at   DATE NOT NULL
);

-- ---------------------------------------------------------
-- 4. orders (주문) - customer : orders = 1 : N
-- ---------------------------------------------------------
CREATE TABLE orders (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id   INTEGER NOT NULL,
    order_date    DATETIME NOT NULL,
    status        TEXT NOT NULL DEFAULT 'COMPLETED',  -- COMPLETED / CANCELED
    FOREIGN KEY (customer_id) REFERENCES customer(id)
);

-- ---------------------------------------------------------
-- 5. order_item (주문 상세) - orders : order_item = 1 : N,
--                             menu   : order_item = 1 : N
-- ---------------------------------------------------------
CREATE TABLE order_item (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id      INTEGER NOT NULL,
    menu_id       INTEGER NOT NULL,
    quantity      INTEGER NOT NULL,
    unit_price    INTEGER NOT NULL,  -- 주문 시점 가격 스냅샷
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (menu_id)  REFERENCES menu(id)
);
