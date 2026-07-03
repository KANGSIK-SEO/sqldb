-- =========================================================
-- 샘플 데이터 입력 (01_schema.sql 실행 후 실행)
-- 출처: The Metropolitan Museum of Art Open Access API (CC0)
-- 부모 테이블(department, artist, classification) 먼저 -> artwork 순서
-- =========================================================

PRAGMA foreign_keys = ON;

-- department (10행)
INSERT INTO department (name) VALUES
('Arms and Armor'),
('Asian Art'),
('Costume Institute'),
('Egyptian Art'),
('European Paintings'),
('European Sculpture and Decorative Arts'),
('Islamic Art'),
('Robert Lehman Collection'),
('The American Wing'),
('The Libraries');

-- classification (12행, 실사용 8 + 미사용 표준분류 4)
INSERT INTO classification (name) VALUES
('Codices'),
('Drawings'),
('Paintings'),
('Sculpture'),
('Swords'),
('Woodwork'),
('Woodwork-Furniture'),
('미분류'),
('Prints'),
('Photographs'),
('Ceramics'),
('Textiles');

-- artist (25행)
INSERT INTO artist (name, nationality, begin_year, end_year) VALUES
('미상', NULL, NULL, NULL),
('Rembrandt (Rembrandt van Rijn)', 'Dutch', '1606', '1669'),
('Sir Edward Burne-Jones', 'British', '1833', '1898'),
('Jan Steen', 'Dutch', '1626', '1679'),
('Edwin Davis French', 'American', '1851', '1906'),
('Ogden Nicholas Rood', NULL, '1831', '1902'),
('Auguste Renoir', 'French', '1841', '1919'),
('Philip Webb', 'British', '1831', '1915'),
('Edouard Manet', 'French', '1832', '1883'),
('Ferdinand Hodler', 'Swiss', '1853', '1918'),
('Jules Bastien-Lepage', 'French', '1848', '1884'),
('D. Appleton & Co.', NULL, NULL, NULL),
('Théodore Rousseau', 'French', '1812', '1867'),
('Paul Cézanne', 'French', '1839', '1906'),
('Bronzino (Agnolo di Cosimo di Mariano)', 'Italian', '1503', '1572'),
('Bartolo di Fredi', 'Italian', '1353', '1410'),
('Honoré Daumier', 'French', '1808', '1879'),
('Bartolomé Estebán Murillo', 'Spanish', '1617', '1682'),
('Hans Memling', 'Netherlandish', '1465', '1494'),
('Jacques Louis David', 'French', '1748', '1825'),
('Hatifi', 'Iranian, active Istanbul', '1441', '1521'),
('Gerard David', 'Netherlandish', '1455', '1523'),
('Paul Gauguin', 'French', '1848', '1903'),
('Georges Seurat', 'French', '1859', '1891'),
('Johannes Vermeer', 'Dutch', '1632', '1675');

-- artwork (50행)
INSERT INTO artwork (met_object_id, title, department_id, artist_id, classification_id, object_date, medium, dimensions, credit_line, is_highlight, image_url, image_file, object_url) VALUES
(544864, 'Statuette of a hippo goddess, probably Taweret', 4, 1, 8, '332–30 BCE', 'Glassy faience', 'H. 11 × W. 3.3 × D. 4.8 cm (4 5/16 × 1 5/16 × 1 7/8 in)', 'Purchase, Edward S. Harkness Gift, 1926', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP243443.jpg', '544864.jpg', 'https://www.metmuseum.org/art/collection/search/544864'),
(544766, 'Stela of the royal scribe Amunnakht praising the divine barque of Amun-Re, Lord of the Thrones of the Two Lands', 4, 1, 8, 'ca. 1184–1070 BCE', 'Limestone, pigment', 'H. 43.4 × W. 28.7 × D. 7.5 cm, 17.6 kg (17 1/16 × 11 5/16 × 2 15/16 in., 38.8 lb.)', 'Rogers Fund, 1921', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP234728.jpg', '544766.jpg', 'https://www.metmuseum.org/art/collection/search/544766'),
(459210, 'Satire on Art Criticism', 8, 2, 2, '1644', 'Pen and brown ink corrected with white.', '6 1/8 x 7 15/16 in.  (15.5 x 20.1 cm)', 'Robert Lehman Collection, 1975', 1, 'https://images.metmuseum.org/CRDImages/rl/web-large/DP359033.jpg', '459210.jpg', 'https://www.metmuseum.org/art/collection/search/459210'),
(587598, 'Statue of the God Ptah', 4, 1, 8, 'ca. 1070–712 BCE', 'Bronze, gold leaf, glass', 'H. 30 × W. 9.5 × D. 5.5 cm (11 13/16 × 3 3/4 × 2 3/16 in.); H. (with tang): 31.9 cm (12 9/16 in.)', 'Purchase, Gift in memory of Manuel Schnitzer, 2009', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP216330.jpg', '587598.jpg', 'https://www.metmuseum.org/art/collection/search/587598'),
(548310, 'Statuette of Isis with the infant Horus', 4, 1, 8, '332–30 BCE', 'Faience', 'H. 17 × W. 5.1 × D. 7.7 cm (6 11/16 × 2 × 3 1/16 in.)', 'Purchase, Joseph Pulitzer Bequest Fund, 1955', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP241036.jpg', '548310.jpg', 'https://www.metmuseum.org/art/collection/search/548310'),
(435826, 'The Love Song', 5, 3, 3, '1868–77', 'Oil on canvas', '45 x 61 3/8 in. (114.3 x 155.9 cm)', 'The Alfred N. Punnett Endowment Fund, 1947', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP323394.jpg', '435826.jpg', 'https://www.metmuseum.org/art/collection/search/435826'),
(24320, 'Saber', 1, 1, 5, '1522–66', 'Steel, gold, fish skin, wood', 'L. 37 7/8 in. (96.2 cm); L. of blade 30 3/4 in. (78.1 cm); W. 6 1/8 in. (15.5 cm); Wt. 2 lb. 5 oz. (1049 g)', 'Bequest of George C. Stone, 1935', 1, 'https://images.metmuseum.org/CRDImages/aa/web-large/DP160333.jpg', '24320.jpg', 'https://www.metmuseum.org/art/collection/search/24320'),
(545027, 'Statue of a kneeling Kushite king', 4, 1, 8, 'ca. 733–664 BCE', 'Bronze; gold leaf', 'H. 7.3 × W. 3.2 × D. 3.7 cm (2 7/8 × 1 1/4 × 1 7/16 in.)', 'Purchase, Lila Acheson Wallace Gift and Anne and John V. Hansen Egyptian Purchase Fund, 2002', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-38848-005.jpg', '545027.jpg', 'https://www.metmuseum.org/art/collection/search/545027'),
(544092, 'Striding Thoth', 4, 1, 8, '332–30 BCE', 'Faience', 'H. 14.1 × W. 3.6 × D. 5.4 cm (5 9/16 × 1 7/16 × 2 1/8 in.)', 'Purchase, Edward S. Harkness Gift, 1926', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-39665-005.jpg', '544092.jpg', 'https://www.metmuseum.org/art/collection/search/544092'),
(587591, 'Head of a goddess, probably Mut, for attachment to a processional barque', 4, 1, 8, 'ca. 733–664 BCE', 'Cupreous metal, gold leaf, formerly inlaid', 'H. 17.5 cm (6 7/8 in); H. of face (forehead to chin) 5.2 cm (2 in); H. of modius 3.5 cm (1 3/8 in); depth 14 cm total (5 1/2 in) including 2.5 cm (1 in) of perpendicular attachment element extending beyond headdress', 'Purchase, Liana Weindling Gift, in memory of her mother, 2008', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-39621-001.jpg', '587591.jpg', 'https://www.metmuseum.org/art/collection/search/587591'),
(545213, 'Figure of a Baboon', 4, 1, 8, '664–525 BCE', 'Faience', 'H. 9.8 × W. 4.3 × D. 5.7 cm (3 7/8 × 1 11/16 × 2 1/4 in.)', 'Purchase, Edward S. Harkness Gift, 1926', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-28668-005.jpg', '545213.jpg', 'https://www.metmuseum.org/art/collection/search/545213'),
(544077, 'Lion Cub', 4, 1, 8, 'ca. 3100–2900 BCE', 'Quartzite', 'L. 23.4 x H. 12 x W. 12.5 cm (9 3/16 x 4 3/4 x 4 15/16 in.)', 'Purchase, Fletcher Fund and The Guide Foundation Inc. Gift, 1966', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP244929.jpg', '544077.jpg', 'https://www.metmuseum.org/art/collection/search/544077'),
(437749, 'Merry Company on a Terrace', 5, 4, 3, 'ca. 1670', 'Oil on canvas', '55 1/2 x 51 3/4 in. (141 x 131.4 cm)', 'Fletcher Fund, 1958', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP146455.jpg', '437749.jpg', 'https://www.metmuseum.org/art/collection/search/437749'),
(65397, 'Pensive bodhisattva', 2, 1, 4, 'mid-7th century', 'Gilt bronze', 'H. 8 7/8 in. (22.5 cm); W. 4 in. (10.2 cm); D. 4 1/4 in. (10.8 cm)', 'Purchase, Walter and Leonore Annenberg and The Annenberg Foundation Gift, 2003', 1, 'https://images.metmuseum.org/CRDImages/as/web-large/DT11140.jpg', '65397.jpg', 'https://www.metmuseum.org/art/collection/search/65397'),
(547556, 'Inlay of the Horus falcon on the hieroglyph for "gold"', 4, 1, 8, '360–343 BCE', 'Faience', 'H. 15.6 × W. 1.2 × L. 12.9 cm (6 1/8 × 1/2 × 5 1/16 in.)', 'Purchase, Edward S. Harkness Gift, 1926', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP240847.jpg', '547556.jpg', 'https://www.metmuseum.org/art/collection/search/547556'),
(544118, 'Cat Statuette intended to contain a mummified cat', 4, 1, 8, '332–30 BCE', 'Leaded bronze', 'H. 27.4 × W. 11.9 × D. 23.3 cm, 2.5 kg (10 13/16 × 4 11/16 × 9 3/16 in., 5.5 lb.); With tangs: H. 32 cm (12 5/8 in.); With mount: 3.7 kg (8.2 lb.)', 'Harris Brisbane Dick Fund, 1956', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-38628-001.jpg', '544118.jpg', 'https://www.metmuseum.org/art/collection/search/544118'),
(545870, 'Statuette of Kary carrying a standard of Horus', 4, 1, 8, 'ca. 1304–1237 BCE', 'Wood', 'H. 49.5 × W. 13.5 × D. 28.8 cm (19 1/2 × 5 5/16 × 11 5/16 in.)', 'Rogers Fund, 1965', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-24218-001.jpg', '545870.jpg', 'https://www.metmuseum.org/art/collection/search/545870'),
(821879, 'Library of the Metropolitan Museum of Art bookplate', 10, 5, 8, '1895', NULL, 'Height: 4 3/4 in. (12 cm)
Width: 4 5/16 in. (11 cm)', NULL, 1, 'https://images.metmuseum.org/CRDImages/li/web-large/b1511333_002.jpg', '821879.jpg', 'https://www.metmuseum.org/art/collection/search/821879'),
(738466, 'Modern chromatics : with applications to art and industry', 10, 6, 8, '1879', NULL, '3 pages, 1 leaf, [v]-viii, [9]-329 pages : color frontispiece, illustrations, diagrams ; Height: 7 7/8 in. (20 cm)', NULL, 1, 'https://images.metmuseum.org/CRDImages/li/web-large/b1100612_001.jpg', '738466.jpg', 'https://www.metmuseum.org/art/collection/search/738466'),
(820668, 'Metropolitan Museum of Art Library accession books, 1881-1969', 10, 1, 8, '1881–1969', NULL, '16 volumes ; 50 cm. or smaller + 5 boxes of catalog cards', NULL, 1, 'https://images.metmuseum.org/CRDImages/li/web-large/b1512115_002.jpg', '820668.jpg', 'https://www.metmuseum.org/art/collection/search/820668'),
(544874, 'Statuette of Amun', 4, 1, 8, 'ca. 945–712 BCE', 'Gold', 'H. 17.5 × W. 4.7 × D. 5.8 cm, 0.9 kg (6 7/8 × 1 7/8 × 2 1/4 in, 2 lbs)', 'Purchase, Edward S. Harkness Gift, 1926', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-38626-001.jpg', '544874.jpg', 'https://www.metmuseum.org/art/collection/search/544874'),
(438815, 'Madame Georges Charpentier (Marguerite-Louise Lemonnier, 1848–1904) and Her Children, Georgette-Berthe (1872–1945) and Paul-Emile-Charles (1875–1895)', 5, 7, 3, '1878', 'Oil on canvas', '60 1/2 x 74 7/8 in. (153.7 x 190.2 cm)', 'Catharine Lorillard Wolfe Collection, Wolfe Fund, 1907', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-35674-001.jpg', '438815.jpg', 'https://www.metmuseum.org/art/collection/search/438815'),
(544826, 'Arm Panel From a Ceremonial Chair of Thutmose IV', 4, 1, 8, 'ca. 1400–1390 BCE', 'Wood (<em>Ficus sycomorus</em>?)', 'H. 26 × W. 30 × Th. 2.2 cm (10 1/4 × 11 13/16 × 7/8 in.)', 'Theodore M. Davis Collection, Bequest of Theodore M. Davis, 1915', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-17705-001.jpg', '544826.jpg', 'https://www.metmuseum.org/art/collection/search/544826'),
(544887, 'Statue of Horus as a falcon protecting King Nectanebo II', 4, 1, 8, '360–343 BCE', 'Metagraywacke', 'H. 72 × W. 20 × D. 46.5 cm, 55.3 kg (28 3/8 × 7 7/8 × 18 5/16 in., 122 lb.)', 'Rogers Fund, 1934', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-38684-002.jpg', '544887.jpg', 'https://www.metmuseum.org/art/collection/search/544887'),
(195456, 'The Backgammon Players', 6, 8, 7, '1861', 'Painted pine, oil paint on leather, brass, copper', 'Overall: 73 × 45 × 21 in. (185.4 × 114.3 × 53.3 cm)', 'Rogers Fund, 1926', 1, 'https://images.metmuseum.org/CRDImages/es/web-large/DP169654.jpg', '195456.jpg', 'https://www.metmuseum.org/art/collection/search/195456'),
(436964, 'Young Lady in 1866', 5, 9, 3, '1866', 'Oil on canvas', '72 7/8 x 50 5/8 in. (185.1 x 128.6 cm)', 'Gift of Erwin Davis, 1889', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP273977.jpg', '436964.jpg', 'https://www.metmuseum.org/art/collection/search/436964'),
(546037, 'Magical Stela with Horus the Child', 4, 1, 8, '360–343 BCE', 'Metagraywacke', 'H. 83.5 × W. 33.5 × D. 14.4 cm, 52.6 kg (32 7/8 × 13 3/16 × 5 11/16 in., 116 lb.)', 'Fletcher Fund, 1950', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-38634-001.jpg', '546037.jpg', 'https://www.metmuseum.org/art/collection/search/546037'),
(547689, 'Statuette of an ancestral king', 4, 1, 8, '390–246 BCE', 'Wood, formerly clad with lead sheet', 'H. 20.8 × W. 14.5 × D. 11 cm (8 3/16 × 5 11/16 × 4 5/16 in.); H. (with tang): 23.3 cm (9 3/16 in.)', 'Purchase, Anne and John V. Hansen Egyptian Purchase Fund, and Magda Saleh and Jack Josephson Gift, 2003', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP-38637-001.jpg', '547689.jpg', 'https://www.metmuseum.org/art/collection/search/547689'),
(634108, 'The Dream of the Shepherd (Der Traum des Hirten)', 5, 10, 3, '1896', 'Oil on canvas', '98 1/2 × 51 3/8 in. (250.2 × 130.5 cm)', 'Purchase, European Paintings Funds, Lila Acheson Wallace Gift, Catharine Lorillard Wolfe Collection, Wolfe Fund, Charles and Jessie Price Gift, funds from various donors, and Bequests of Collis P. Huntington and Isaac D. Fletcher, by exchange, 2013', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP318843.jpg', '634108.jpg', 'https://www.metmuseum.org/art/collection/search/634108'),
(435621, 'Joan of Arc', 5, 11, 3, '1879', 'Oil on canvas', '100 x 110 in. (254 x 279.4 cm)', 'Gift of Erwin Davis, 1889', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-14201-049.jpg', '435621.jpg', 'https://www.metmuseum.org/art/collection/search/435621'),
(547771, 'Ram''s-head  Amulet', 4, 1, 8, 'ca. 712–664 BCE', 'Gold', 'H. 4.2 × W. 3.6 × D. 2 cm, 65g (1 5/8 × 1 7/16 × 13/16 in., 2.293oz.)', 'Gift of Norbert Schimmel Trust, 1989', 1, 'https://images.metmuseum.org/CRDImages/eg/web-large/DP139144.jpg', '547771.jpg', 'https://www.metmuseum.org/art/collection/search/547771'),
(705638, 'Artistic houses : being a series of interior views of a number of the most beautiful and celebrated homes in the United States : with a description of the art treasures contained therein', 10, 12, 8, '1883–84', NULL, '2 volumes in 4, [193] leaves of plates ; Height: 20 1/2 in. (52 cm)', NULL, 1, 'https://images.metmuseum.org/CRDImages/li/web-large/DP359804.jpg', '705638.jpg', 'https://www.metmuseum.org/art/collection/search/705638'),
(438816, 'The Forest in Winter at Sunset', 5, 13, 3, 'ca. 1846–67', 'Oil on canvas', '64 x 102 3/8 in. (162.6 x 260 cm)', 'Gift of P. A. B. Widener, 1911', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-31520-001.jpg', '438816.jpg', 'https://www.metmuseum.org/art/collection/search/438816'),
(435882, 'Still Life with Apples and a Pot of Primroses', 5, 14, 3, 'ca. 1890', 'Oil on canvas', '28 3/4 x 36 3/8 in. (73 x 92.4 cm)', 'Bequest of Sam A. Lewisohn, 1951', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DT47.jpg', '435882.jpg', 'https://www.metmuseum.org/art/collection/search/435882'),
(435802, 'Portrait of a Young Man', 5, 15, 3, '1530s', 'Oil on wood', '37 5/8 x 29 1/2 in. (95.6 x 74.9 cm)', 'H. O. Havemeyer Collection, Bequest of Mrs. H. O. Havemeyer, 1929', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-14286-011.jpg', '435802.jpg', 'https://www.metmuseum.org/art/collection/search/435802'),
(458956, 'The Adoration of the Magi', 8, 16, 3, 'ca. 1390', 'Tempera and gold on wood', '58 1/2 x 35 1/8 in. (148.6 x 89.2 cm)', 'Robert Lehman Collection, 1975', 1, 'https://images.metmuseum.org/CRDImages/rl/web-large/DT3007.jpg', '458956.jpg', 'https://www.metmuseum.org/art/collection/search/458956'),
(436095, 'The Third-Class Carriage', 5, 17, 3, '1864', 'Oil on canvas', '25 3/4 x 35 1/2 in. (65.4 x 90.2 cm)', 'H. O. Havemeyer Collection, Bequest of Mrs. H. O. Havemeyer, 1929', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-21027-001.jpg', '436095.jpg', 'https://www.metmuseum.org/art/collection/search/436095'),
(437175, 'Virgin and Child', 5, 18, 3, '1670s', 'Oil on canvas', '65 1/4 x 43 in. (165.7 x 109.2 cm)', 'Rogers Fund, 1943', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-14936-010.jpg', '437175.jpg', 'https://www.metmuseum.org/art/collection/search/437175'),
(437490, 'The Annunciation', 5, 19, 3, 'ca. 1465–70', 'Oil on wood', '73 1/4 x 45 1/4 in. (186.1 x 114.9 cm)', 'Gift of J. Pierpont Morgan, 1917', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP240360.jpg', '437490.jpg', 'https://www.metmuseum.org/art/collection/search/437490'),
(436106, 'Antoine Laurent Lavoisier (1743–1794) and Marie Anne Lavoisier (Marie Anne Pierrette Paulze, 1758–1836)', 5, 20, 3, '1788', 'Oil on canvas', '102 1/4 x 76 5/8 in. (259.7 x 194.6 cm)', 'Purchase, Mr. and Mrs. Charles Wrightsman Gift, in honor of Everett Fahy, 1977', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-19709-001.jpg', '436106.jpg', 'https://www.metmuseum.org/art/collection/search/436106'),
(452037, 'Khusrau and Shirin', 7, 21, 1, 'dated 904 AH/1498–99 CE', 'Main support: ink, opaque watercolor, and gold on paper; binding: leather', 'H.  9 7/16 in. (24 cm)
W. 6 7/16 in. (16.4 cm)', 'Harris Brisbane Dick Fund, 1969', 1, 'https://images.metmuseum.org/CRDImages/is/web-large/DP234022.jpg', '452037.jpg', 'https://www.metmuseum.org/art/collection/search/452037'),
(436947, 'Boating', 5, 9, 3, '1874', 'Oil on canvas', '38 1/4 x 51 1/4 in. (97.2 x 130.2 cm)', 'H. O. Havemeyer Collection, Bequest of Mrs. H. O. Havemeyer, 1929', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-25466-001.jpg', '436947.jpg', 'https://www.metmuseum.org/art/collection/search/436947'),
(6887, 'Room from the Hart House, Ipswich, Massachusetts', 9, 1, 8, '1680', 'Wood, oak, pine', 'Dimensions unavailable', 'Munsey Fund, 1936', 1, 'https://images.metmuseum.org/CRDImages/ad/web-large/DP170794.jpg', '6887.jpg', 'https://www.metmuseum.org/art/collection/search/6887'),
(435868, 'The Card Players', 5, 14, 3, '1890–92', 'Oil on canvas', '25 3/4 x 32 1/4 in. (65.4 x 81.9 cm)', 'Bequest of Stephen C. Clark, 1960', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP231550.jpg', '435868.jpg', 'https://www.metmuseum.org/art/collection/search/435868'),
(436101, 'The Rest on the Flight into Egypt', 5, 22, 3, 'ca. 1512–15', 'Oil on wood', '21 in. × 15 11/16 in. (53.3 × 39.8 cm)', 'The Jules Bache Collection, 1949', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP-14936-023.jpg', '436101.jpg', 'https://www.metmuseum.org/art/collection/search/436101'),
(205485, 'Boiserie from the Hôtel de Cabris, Grasse', 6, 1, 6, 'ca. 1774, with later additions', 'Carved, painted, and gilded oak', 'Overall: H. 11 ft. 8-1/2 in. x  W. 22 ft. 10-1/2 in. x  L. 25 ft. 6 in. (3.56 x 6.96 x 7.77 m); 
or H. 140-1/2 x W. 274-1/2 x D. 306 in. (356.9 x 697.2 x 777.2 cm)', 'Purchase, Mr. and Mrs. Charles Wrightsman Gift, 1972', 1, 'https://images.metmuseum.org/CRDImages/es/web-large/DP159275.jpg', '205485.jpg', 'https://www.metmuseum.org/art/collection/search/205485'),
(83605, 'Robe à la française', 3, 1, 8, '1750–75', 'silk', NULL, 'Purchase, Irene Lewisohn Bequest, 1954', 1, 'https://images.metmuseum.org/CRDImages/ci/web-large/CI54.70ab.jpg', '83605.jpg', 'https://www.metmuseum.org/art/collection/search/83605'),
(438821, 'Ia Orana Maria (Hail Mary)', 5, 23, 3, '1891', 'Oil on canvas', '44 3/4 x 34 1/2 in. (113.7 x 87.6 cm)', 'Bequest of Sam A. Lewisohn, 1951', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DT1025.jpg', '438821.jpg', 'https://www.metmuseum.org/art/collection/search/438821'),
(437654, 'Circus Sideshow (Parade de cirque)', 5, 24, 3, '1887–88', 'Oil on canvas', '39 1/4 x 59 in. (99.7 x 149.9 cm)', 'Bequest of Stephen C. Clark, 1960', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP375450_cropped.jpg', '437654.jpg', 'https://www.metmuseum.org/art/collection/search/437654'),
(437879, 'Study of a Young Woman', 5, 25, 3, 'ca. 1665–67', 'Oil on canvas', '17 1/2 x 15 3/4 in. (44.5 x 40 cm)', 'Gift of Mr. and Mrs. Charles Wrightsman, in memory of Theodore Rousseau Jr., 1979', 1, 'https://images.metmuseum.org/CRDImages/ep/web-large/DP353256.jpg', '437879.jpg', 'https://www.metmuseum.org/art/collection/search/437879');
