#!/usr/bin/env python3
"""
국제범죄조직(TCO) 제재 데이터베이스 - 스키마 정의 + 시드 데이터 + DB 생성

데이터 출처: 미국 재무부 OFAC(해외자산통제국) SDN List, "TCO"
(Transnational Criminal Organization) 프로그램 태그 항목
공개 다운로드: https://www.treasury.gov/ofac/downloads/sdn.csv
             https://www.treasury.gov/ofac/downloads/alt.csv

이 파일 하나로 DB를 (재)생성한다:
    python3 schema.py
"""

import os
import sqlite3

HERE = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(HERE, "crime_org.db")

SCHEMA_SQL = """
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS alias;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS country;
DROP TABLE IF EXISTS organization;

-- organization: 제재 대상 범죄조직 (조직 자기참조로 상하 계열 표현)
CREATE TABLE organization (
    org_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    org_name      VARCHAR(80) NOT NULL,
    org_type      VARCHAR(30) NOT NULL,
    ofac_ent_num  INTEGER NOT NULL,
    parent_org_id INTEGER,
    description   VARCHAR(200),
    UNIQUE (org_name),
    UNIQUE (ofac_ent_num),
    FOREIGN KEY (parent_org_id) REFERENCES organization(org_id)
);

-- country: 조직원의 출생지/국적 국가
CREATE TABLE country (
    country_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    country_name VARCHAR(50) NOT NULL,
    UNIQUE (country_name)
);

-- member: 제재 대상 개인 (organization 1:N member, country 1:N member)
CREATE TABLE member (
    member_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name    VARCHAR(100) NOT NULL,
    org_id       INTEGER NOT NULL,
    country_id   INTEGER,
    dob          VARCHAR(20),
    pob          VARCHAR(100),
    ofac_ent_num INTEGER NOT NULL,
    note         VARCHAR(200),
    UNIQUE (ofac_ent_num),
    FOREIGN KEY (org_id) REFERENCES organization(org_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- alias: 조직원의 별칭/가명 (member 1:N alias)
CREATE TABLE alias (
    alias_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id  INTEGER NOT NULL,
    alias_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES member(member_id)
);
"""

SEED_SQL = """
PRAGMA foreign_keys = ON;

INSERT INTO organization (org_name, org_type, ofac_ent_num, parent_org_id, description) VALUES
('YAKUZA',        '일본 야쿠자', 12816, NULL, '일본 폭력단(반사회적 세력)을 총칭하는 상위 분류'),
('CAMORRA',       '이탈리아 마피아', 12817, NULL, '이탈리아 나폴리 지역 기반 마피아 조직'),
('THIEVES-IN-LAW','유라시아 마피아', 23223, NULL, '옛 소련권(러시아·조지아·우즈베키스탄 등)에서 활동하는 범죄조직 네트워크'),
('MS-13',         '중미 갱단', 15412, NULL, '중미(엘살바도르·온두라스 등) 기반의 국제 갱단'),
('KINAHAN ORGANIZED CRIME GROUP', '아일랜드 마피아', 34979, NULL, '아일랜드 더블린 기반, 국제 마약 밀매로 제재된 조직'),
('HYSA ORGANIZED CRIME GROUP',    '알바니아 마피아', 56265, NULL, '알바니아계, 멕시코·캐나다 등에 유령회사를 둔 마약밀매 조직');

INSERT INTO organization (org_name, org_type, ofac_ent_num, parent_org_id, description) VALUES
('YAMAGUCHI-GUMI',     '일본 야쿠자', 13071, (SELECT org_id FROM organization WHERE org_name='YAKUZA'), '고베 기반, 일본 최대 규모의 야쿠자 조직'),
('KOBE YAMAGUCHI-GUMI','일본 야쿠자', 20379, (SELECT org_id FROM organization WHERE org_name='YAKUZA'), '2015년 야마구치구미에서 분리된 고베 계열 조직'),
('SUMIYOSHI-KAI',      '일본 야쿠자', 15495, (SELECT org_id FROM organization WHERE org_name='YAKUZA'), '도쿄 기반, 일본 2대 야쿠자 조직 중 하나'),
('INAGAWA-KAI',        '일본 야쿠자', 15661, (SELECT org_id FROM organization WHERE org_name='YAKUZA'), '도쿄·요코하마 기반의 3대 야쿠자 조직 중 하나'),
('KUDO-KAI',           '일본 야쿠자', 16604, (SELECT org_id FROM organization WHERE org_name='YAKUZA'), '기타큐슈 기반, 폭력성이 강한 것으로 알려진 조직');

INSERT INTO organization (org_name, org_type, ofac_ent_num, parent_org_id, description) VALUES
('KODO-KAI',    '일본 야쿠자', 17787, (SELECT org_id FROM organization WHERE org_name='YAMAGUCHI-GUMI'), '나고야 기반, 야마구치구미 산하 최대 2차 조직'),
('YAMAKEN-GUMI','일본 야쿠자', 20380, (SELECT org_id FROM organization WHERE org_name='KOBE YAMAGUCHI-GUMI'), '고베 야마구치구미 산하 2차 조직');

INSERT INTO country (country_name) VALUES
('Japan'), ('Uzbekistan'), ('Russia'), ('Georgia'), ('Honduras'),
('Ireland'), ('Albania'), ('El Salvador'), ('Italy'), ('United Kingdom');

INSERT INTO member (full_name, org_id, country_id, dob, pob, ofac_ent_num, note) VALUES
('SHINODA, Kenichi', (SELECT org_id FROM organization WHERE org_name='YAMAGUCHI-GUMI'), (SELECT country_id FROM country WHERE country_name='Japan'), '1942-01-25', 'Oita Kyushu, Japan', 13072, '2012년 美 재무부 발표 기준 야마구치구미 구미초(두목)'),
('TAKAYAMA, Kiyoshi', (SELECT org_id FROM organization WHERE org_name='YAMAGUCHI-GUMI'), (SELECT country_id FROM country WHERE country_name='Japan'), '1947-09-05', 'Tsushimasi, Aichi Prefecture, Japan', 13073, '2012년 美 재무부 발표 기준 야마구치구미 와카가시라(2인자)'),
('TAKEUCHI, Teruaki', (SELECT org_id FROM organization WHERE org_name='KODO-KAI'), (SELECT country_id FROM country WHERE country_name='Japan'), '1960-02', NULL, 17788, 'KODO-KAI 및 YAMAGUCHI-GUMI와 연계'),
('FUKUDA, Hareaki', (SELECT org_id FROM organization WHERE org_name='SUMIYOSHI-KAI'), (SELECT country_id FROM country WHERE country_name='Japan'), '1943~1944', NULL, 15497, NULL),
('RAKHIMOV, Gafur-Arslanbek Akhmedovich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Uzbekistan'), '1951-07-22', 'Tashkent, Uzbekistan', 13087, NULL),
('KHRISTOFOROV, Vasiliy Aleksandrovich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Russia'), '1972-03-12', 'Dzerzhinsk, Nizhny Novgorod, Russia', 13088, NULL),
('SHUSHANASHVILI, Lasha Pavlovich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Georgia'), '1961-07-25', 'Rustavi, Georgia', 13165, NULL),
('KALASHOV, Zakhary Knyazevich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Georgia'), '1953-03-20', 'Tbilisi, Georgia', 15645, NULL),
('PICHUGIN, Yuri Viktorovich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Russia'), '1965-10-18', 'Azanka, Tavdinsky District, Sverdlovsk Oblast, Russia', 23229, NULL),
('TOKHTAKHUNOV, Alimzhan Tursunovich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Uzbekistan'), '1949-01-01', 'Tashkent, Uzbekistan', 23230, NULL),
('TYURIN, Vladimir Anatolyevich', (SELECT org_id FROM organization WHERE org_name='THIEVES-IN-LAW'), (SELECT country_id FROM country WHERE country_name='Russia'), '1958-11-25', 'Tirlyan, Beloretskiy Rayon, Bashkiria, Russia', 23243, NULL),
('ROBERTO ORELLANA, Jose', (SELECT org_id FROM organization WHERE org_name='MS-13'), (SELECT country_id FROM country WHERE country_name='El Salvador'), '1973-06-29', NULL, 19391, NULL),
('ROMERO GARCIA, Dany Balmore', (SELECT org_id FROM organization WHERE org_name='MS-13'), (SELECT country_id FROM country WHERE country_name='El Salvador'), '1974-04-26', NULL, 19408, NULL),
('ARCHAGA CARIAS, Yulan Adonay', (SELECT org_id FROM organization WHERE org_name='MS-13'), (SELECT country_id FROM country WHERE country_name='Honduras'), '1982-02-13', 'San Pedro Sula, Cortes, Honduras', 39319, NULL),
('CAMPBELL LICONA, David Elias', (SELECT org_id FROM organization WHERE org_name='MS-13'), (SELECT country_id FROM country WHERE country_name='Honduras'), '1967-03-18', 'San Pedro Sula, Honduras', 39336, NULL),
('KINAHAN, Christopher Vincent', (SELECT org_id FROM organization WHERE org_name='KINAHAN ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Ireland'), '1957-03-23', 'Cabra, Ireland', 34980, NULL),
('KINAHAN, Daniel Joseph', (SELECT org_id FROM organization WHERE org_name='KINAHAN ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Ireland'), '1977-06-25', 'Dublin, Ireland', 34982, NULL),
('KINAHAN JUNIOR, Christopher Vincent', (SELECT org_id FROM organization WHERE org_name='KINAHAN ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Ireland'), '1980-09-24', 'Dublin, Ireland', 34993, NULL),
('MCGOVERN, Sean Gerard', (SELECT org_id FROM organization WHERE org_name='KINAHAN ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Ireland'), '1986-02-12', 'Dublin, Ireland', 34994, 'OFAC 원자료상으로는 개인(KINAHAN, Daniel Joseph)에 연결되어 있으나 소속 조직으로 정리함'),
('CLANCY, Bernard Patrick', (SELECT org_id FROM organization WHERE org_name='KINAHAN ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Ireland'), '1977-09-04', 'Ireland', 35006, NULL),
('MORRISSEY, John Francis', (SELECT org_id FROM organization WHERE org_name='KINAHAN ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Ireland'), '1959-12-20', NULL, 35010, NULL),
('HYSA, Luftar', (SELECT org_id FROM organization WHERE org_name='HYSA ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Albania'), '1967-03-01', 'Elbasan, Albania', 56264, NULL),
('HYSA, Arben', (SELECT org_id FROM organization WHERE org_name='HYSA ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Albania'), '1970-09-15', 'Belsh, Albania', 56313, NULL),
('HYSA, Ramiz', (SELECT org_id FROM organization WHERE org_name='HYSA ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Albania'), '1962-09-08', 'Belsh, Albania', 56314, NULL),
('HYSA, Fatos', (SELECT org_id FROM organization WHERE org_name='HYSA ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Albania'), '1972-06-15', NULL, 56315, NULL),
('HYSA, Fabjon', (SELECT org_id FROM organization WHERE org_name='HYSA ORGANIZED CRIME GROUP'), (SELECT country_id FROM country WHERE country_name='Albania'), '1993-09-27', 'Elbasan, Albania', 56316, NULL);

INSERT INTO alias (member_id, alias_name) VALUES
((SELECT member_id FROM member WHERE ofac_ent_num=13072), 'TSUKASA, Shinobu'),
((SELECT member_id FROM member WHERE ofac_ent_num=13087), 'RAKHIMOV, Gofur-Arslonbek'),
((SELECT member_id FROM member WHERE ofac_ent_num=13088), 'KHRISTOFOROV, Vasili'),
((SELECT member_id FROM member WHERE ofac_ent_num=13165), 'LASHA RUSTAVSKY'),
((SELECT member_id FROM member WHERE ofac_ent_num=15645), 'SHAKRO MOLODOY'),
((SELECT member_id FROM member WHERE ofac_ent_num=23229), 'PICHUGA'),
((SELECT member_id FROM member WHERE ofac_ent_num=23230), 'TAIVANCHIK'),
((SELECT member_id FROM member WHERE ofac_ent_num=23243), 'TYURIK'),
((SELECT member_id FROM member WHERE ofac_ent_num=34980), 'THE DAPPER DON'),
((SELECT member_id FROM member WHERE ofac_ent_num=34993), 'CHRISTY JNR.'),
((SELECT member_id FROM member WHERE ofac_ent_num=35010), 'MORRISSEY, Johnny'),
((SELECT member_id FROM member WHERE ofac_ent_num=19391), 'TIO SAM'),
((SELECT member_id FROM member WHERE ofac_ent_num=19408), 'BIG BOY'),
((SELECT member_id FROM member WHERE ofac_ent_num=39319), 'PORKY'),
((SELECT member_id FROM member WHERE ofac_ent_num=39336), 'DON DAVID');
"""


def build_db():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.executescript(SCHEMA_SQL)
    conn.executescript(SEED_SQL)
    conn.commit()
    conn.close()
    print(f"[완료] {DB_PATH} 생성/초기화 완료")


if __name__ == "__main__":
    build_db()
