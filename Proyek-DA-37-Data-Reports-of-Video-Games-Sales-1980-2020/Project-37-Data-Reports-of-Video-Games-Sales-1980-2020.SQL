-- Menampilkan baris yang duplikat berdasarkan semua kolom.
SELECT *
FROM vgsales
GROUP BY Rank, Name, Platform, Year, Genre, Publisher, NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales
HAVING COUNT(*) > 1;

-- Menghitung jumlah missing value pada kolom Year (contoh).
SELECT
    SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS Missing_Year,
    SUM(CASE WHEN Publisher IS NULL THEN 1 ELSE 0 END) AS Missing_Publisher
FROM vgsales;

-- Deteksi Outliers.Misalnya untuk kolom Global_Sales menggunakan metode IQR.
-- Pertama, hitung Q1 dan Q3
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Global_Sales) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Global_Sales) AS Q3
    FROM vgsales
)
SELECT v.*
FROM vgsales v, stats s
WHERE v.Global_Sales < (s.Q1 - 1.5 * (s.Q3 - s.Q1))
   OR v.Global_Sales > (s.Q3 + 1.5 * (s.Q3 - s.Q1));

-- Data Cleaning: Hapus Duplikat, Missing, dan Outlier.
-- Contoh query untuk memilih data yang bersih (tanpa missing pada Year dan Publisher serta tanpa outlier Global_Sales)
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Global_Sales) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Global_Sales) AS Q3
    FROM vgsales
)
SELECT *
FROM vgsales v, stats s
WHERE v.Year IS NOT NULL
  AND v.Publisher IS NOT NULL
  AND v.Global_Sales BETWEEN (s.Q1 - 1.5 * (s.Q3 - s.Q1)) AND (s.Q3 + 1.5 * (s.Q3 - s.Q1));

-- Query untuk Metrik Terukur.
-- Top 20 Game Berdasarkan Global Sales
SELECT Name, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Name
ORDER BY Total_Sales DESC
LIMIT 20;

-- Top 20 Publisher Berdasarkan Global Sales
SELECT Publisher, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Publisher
ORDER BY Total_Sales DESC
LIMIT 20;

-- Top 20 Platform Berdasarkan Global Sales
SELECT Platform, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Platform
ORDER BY Total_Sales DESC
LIMIT 20;

-- Top 20 Genre Berdasarkan Global Sales
SELECT Genre, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Genre
ORDER BY Total_Sales DESC
LIMIT 20;

-- Tren Penjualan per Tahun (Contoh untuk Produk)
SELECT Year, Name, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Year, Name
ORDER BY Year, Total_Sales DESC;

-- Tren Penjualan per Tahun (Contoh untuk Platform)
SELECT Year, Platform, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Year, Platform
ORDER BY Year, Total_Sales DESC;

-- Tren Penjualan per Tahun (Contoh untuk Genre)
SELECT Year, Genre, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Year, Genre
ORDER BY Year, Total_Sales DESC;

-- Tren Penjualan per Tahun (Contoh untuk Publisher)
SELECT Year, Publisher, SUM(Global_Sales) AS Total_Sales
FROM vgsales
GROUP BY Year, Publisher
ORDER BY Year, Total_Sales DESC;


































































