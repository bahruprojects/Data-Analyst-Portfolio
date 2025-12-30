-- Menampilkan baris duplikat (berdasarkan seluruh kolom)
SELECT drink, "Volume (ml)", Calories, "Caffeine (mg)", type, COUNT(*) as cnt
FROM caffeine
GROUP BY drink, "Volume (ml)", Calories, "Caffeine (mg)", type
HAVING COUNT(*) > 1;

-- Hapus duplikat (contoh query, sintaks tergantung pada SQL dialect)
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY drink, "Volume (ml)", Calories, "Caffeine (mg)", type ORDER BY drink) as rn
    FROM caffeine
)
DELETE FROM CTE WHERE rn > 1;

-- Deteksi Missing Values
SELECT *
FROM caffeine
WHERE drink IS NULL
   OR "Volume (ml)" IS NULL
   OR Calories IS NULL
   OR "Caffeine (mg)" IS NULL
   OR type IS NULL;

-- Deteksi Outliers (Menggunakan Metode IQR)
-- Misalkan mendeteksi outlier pada kolom Calories
-- Hitung Q1 dan Q3
WITH Stats AS (
    SELECT 
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Calories) AS Q1,
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Calories) AS Q3
    FROM caffeine
)
SELECT c.*
FROM caffeine c, Stats s
WHERE c.Calories < s.Q1 - 1.5 * (s.Q3 - s.Q1)
   OR c.Calories > s.Q3 + 1.5 * (s.Q3 - s.Q1);

-- Menghapus Data yang Tidak Sesuai (Cleaning)
-- Contoh untuk kolom Calories
WITH Stats AS (
    SELECT 
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Calories) AS Q1,
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Calories) AS Q3
    FROM caffeine
)
DELETE FROM caffeine
WHERE Calories < (SELECT Q1 - 1.5 * (Q3 - Q1) FROM Stats)
   OR Calories > (SELECT Q3 + 1.5 * (Q3 - Q1) FROM Stats);

-- Menampilkan Metrik Terukur
-- Total Beverage Names (unik)
SELECT COUNT(DISTINCT drink) AS Total_Beverage_Names FROM caffeine;

-- Type Of Beverages
SELECT DISTINCT type FROM caffeine;

-- Highest Caffeine/Volume (rasio)
SELECT drink, "Caffeine (mg)"/"Volume (ml)" AS Caffeine_Per_Volume
FROM caffeine
ORDER BY Caffeine_Per_Volume DESC
LIMIT 1;

-- Highest Calories/Volume (rasio)
SELECT drink, Calories/"Volume (ml)" AS Calories_Per_Volume
FROM caffeine
ORDER BY Calories_Per_Volume DESC
LIMIT 1;





































































