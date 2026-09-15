-- 1. Tablo Tasarımı ve Kısıtlar

PRAGMA foreign_keys = ON;

CREATE TABLE uyeler(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			ad TEXT NOT NULL,
			yas INTEGER CHECK(yas>13),
			sehir TEXT DEFAULT 'Erzincan',
			kayit TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kitaplar(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			ad TEXT NOT NULL UNIQUE
);

CREATE TABLE odunc(
			uye_id INTEGER REFERENCES uyeler(id) ON DELETE CASCADE,
			kitap_id INTEGER REFERENCES kitaplar(id),
			gun INTEGER,
			PRIMARY KEY (uye_id, kitap_id)
);

-- üye silinince kayıtların gitmesi mantıklı çünkü kişi sistemden ayrılıyor.
-- ama kitap silinince geçmiş ödünç kayıtlarının da yok olması veri kaybına yol açar.


-- 2. Veri Ekleme

INSERT INTO kitaplar (ad) VALUES 
('Suç ve Ceza'),
('1984'),
('Simyacı'),
('Küçük Prens'),
('Tutunamayanlar');

INSERT INTO uyeler (ad, yas, sehir) VALUES
('Ali Veli', 20, 'Ankara'),
('Ayşe Kaya', 25, 'İstanbul'),
('Mehmet Demir', 19, 'İzmir'),
('Zeynep Öz', 30, NULL),
('Can Yıldız', 22, 'Bursa');

INSERT INTO uyeler (ad, yas) VALUES
('Elif Su', 28),
('Burak Ak', 17),
('Deniz Kara', 21),
('Selin Tan', 24),
('Onur Ak', 19);

SELECT * FROM uyeler;

-- INSERT INTO uyeler (ad, yas) VALUES ('Küçük Çocuk', 10);
-- Hata alırız çünkü tabloyu CHECK(yas > 13) kuralıyla kurmuştuk.

-- INSERT INTO odunc (uye_id, kitap_id, gun) VALUES (99, 1, 10);
-- Bu da hata verecek çünkü uye_id foreign key ile uyeler(id)'ye bağlı ve 99 numaralı üye yok.

INSERT INTO odunc (uye_id, kitap_id, gun) VALUES
(1, 1, 10), (1, 3, 25),
(2, 2, 5),  (2, 4, 40),
(3, 1, 30), (3, 5, 12),
(4, 2, 45), (4, 3, 8),
(5, 4, 20), (5, 1, 33),
(6, 5, 15), (6, 2, 3),
(7, 3, 22), (7, 4, 38),
(8, 1, 7),  (8, 5, 29),
(9, 2, 41), (9, 3, 14),
(10, 4, 6), (10, 5, 27);


-- 3. Join

SELECT u.ad, k.ad AS kitap, o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id;


SELECT u.ad, k.ad AS kitap, o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE o.gun > 30;


SELECT u.ad, k.ad AS kitap, o.gun
FROM odunc o
JOIN uyeler u ON u.id = o.uye_id
JOIN kitaplar k ON k.id = o.kitap_id
WHERE u.sehir = 'Erzincan';


-- LEFT JOIN
SELECT u.ad, k.ad AS kitap, o.gun
FROM uyeler u
LEFT JOIN odunc o ON u.id = o.uye_id
LEFT JOIN kitaplar k ON k.id = o.kitap_id;


-- 4. Gruplama ve Toplama Fonksiyonları

SELECT uye_id, AVG(gun) AS ortalama, COUNT(*) AS kitap_sayisi, MAX(gun) AS max_gun
FROM odunc
GROUP BY uye_id
HAVING AVG(gun) > 20;


-- WHERE = gruplamadan önce filtreler.
-- HAVING = gruplamadan sonra, hesaplanan sonuçları (AVG, COUNT) filtreler.


SELECT k.ad, COUNT(*) AS alinma_sayisi
FROM odunc o
JOIN kitaplar k ON k.id = o.kitap_id
GROUP BY k.ad;


SELECT sehir, COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;


--5. Alt Sorgu

SELECT ad FROM uyeler
WHERE id IN (SELECT uye_id FROM odunc WHERE gun > 30);


INSERT INTO kitaplar (ad) VALUES ('Sefiller');

SELECT ad FROM kitaplar
WHERE id NOT IN (SELECT kitap_id FROM odunc);


SELECT * FROM odunc
WHERE gun > (SELECT AVG(gun) FROM odunc);

SELECT * FROM odunc
WHERE gun > (SELECT AVG(gun) FROM odunc);


-- 6. Case

SELECT *,
    CASE 
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun >= 15 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum
FROM odunc;


SELECT ad,
    CASE WHEN yas <= 18 THEN 'Genç' ELSE 'Yetişkin' END AS grup
FROM uyeler;


SELECT 
    CASE 
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun >= 15 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum,
    COUNT(*) AS kayit_sayisi
FROM odunc
GROUP BY durum;


-- 7. Index

CREATE INDEX idx_uye_ad ON uyeler(ad);

-- ad sorgularını hızlandırır.
SELECT * FROM uyeler WHERE ad = 'Ali Veli';


ALTER TABLE uyeler ADD COLUMN eposta TEXT;
CREATE UNIQUE INDEX idx_eposta ON uyeler(eposta);


UPDATE uyeler SET eposta = 'ali@example.com' WHERE ad = 'Ali Veli';
-- Bir üyeye daha aynı eposta verilirse UNIQUE INDEX seçtiğimiz için hata mesajı alırız.
