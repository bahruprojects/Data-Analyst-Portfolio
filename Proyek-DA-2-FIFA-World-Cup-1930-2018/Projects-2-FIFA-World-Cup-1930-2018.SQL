-- 1. Deteksi Data Duplikat
SELECT *, COUNT(*) AS dup_count
FROM world_cup_players
GROUP BY RoundID, MatchID, "Team Initials", "Coach Name", "Line-up", "Shirt Number", "Player Name", Position, Event
HAVING COUNT(*) > 1;

-- 2. Deteksi Missing Values (contoh untuk satu kolom, ulangi sesuai kebutuhan)
SELECT COUNT(*) AS missing_player_name
FROM world_cup_players
WHERE "Player Name" IS NULL;

-- 3. Deteksi Outlier
-- Misalnya, untuk kolom "Shirt Number", asumsikan nilai yang dianggap outlier <1 atau >100
SELECT *
FROM world_cup_players
WHERE "Shirt Number" < 1 OR "Shirt Number" > 100;

-- 4. Cleaning Data: Hapus duplikat, missing values, dan outlier
-- Perintah berikut bisa berbeda-beda tergantung SQL engine; berikut contoh dalam SQL standar:
-- Hapus duplikat (cara umum, misalnya menggunakan CTE dengan ROW_NUMBER())
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY RoundID, MatchID, "Team Initials", "Coach Name", "Line-up", "Shirt Number", "Player Name", Position, Event ORDER BY RoundID) AS rn
    FROM world_cup_players
)
DELETE FROM CTE WHERE rn > 1;

-- Hapus record dengan missing values
DELETE FROM world_cup_players
WHERE "Player Name" IS NULL OR "Coach Name" IS NULL;  -- Tambahkan kolom lain sesuai kebutuhan

-- Hapus outlier pada Shirt Number
DELETE FROM world_cup_players
WHERE "Shirt Number" < 1 OR "Shirt Number" > 100;

--Query untuk Menampilkan Metrik Terukur.
-- Total Pemain (unique Player Name)
SELECT COUNT(DISTINCT "Player Name") AS Total_Pemain FROM world_cup_players;

-- Total Tim (unique Team Initials)
SELECT COUNT(DISTINCT "Team Initials") AS Total_Tim FROM world_cup_players;

-- Total Pelatih (unique Coach Name)
SELECT COUNT(DISTINCT "Coach Name") AS Total_Pelatih FROM world_cup_players;

-- Total Pertandingan (unique MatchID)
SELECT COUNT(DISTINCT MatchID) AS Total_Pertandingan FROM world_cup_players;

-- Pie Chart Data: Distribusi Posisi Pemain
SELECT Position, COUNT(*) AS Jumlah
FROM world_cup_players
WHERE Position IS NOT NULL
GROUP BY Position;

-- Horizontal Bar Chart: Top 10 Pemain Berdasarkan Kehadiran
SELECT "Player_Name", COUNT(*) AS Kehadiran
FROM world_cup_players
GROUP BY "Player_Name"
ORDER BY Kehadiran DESC
LIMIT 10;

-- Bar Chart: Top 10 Tim Berdasarkan Total Pemain (unique player per tim)
SELECT "Team_Initials", COUNT(DISTINCT "Player_Name") AS Total_Pemain
FROM world_cup_players
GROUP BY "Team_Initials"
ORDER BY Total_Pemain DESC
LIMIT 10;





































































