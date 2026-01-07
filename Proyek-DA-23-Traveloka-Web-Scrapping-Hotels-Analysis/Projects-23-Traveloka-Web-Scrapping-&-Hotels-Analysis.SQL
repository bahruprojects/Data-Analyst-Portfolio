-- Query untuk mendeteksi data duplikat
SELECT Hotel, Star, Rating, Reviews, Harga, Places, Nearby, [Facil + Akomod], COUNT(*) AS cnt
FROM hotels
GROUP BY Hotel, Star, Rating, Reviews, Harga, Places, Nearby, [Facil + Akomod]
HAVING COUNT(*) > 1;

-- Query untuk mendeteksi missing values
SELECT *
FROM hotels
WHERE Hotel IS NULL
   OR Star IS NULL
   OR Rating IS NULL
   OR Reviews IS NULL
   OR Harga IS NULL
   OR Places IS NULL
   OR Nearby IS NULL
   OR [Facil + Akomod] IS NULL;

-- Deteksi Outliers
WITH quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CAST(Harga AS DECIMAL)) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CAST(Harga AS DECIMAL)) AS Q3
    FROM hotels
)
SELECT h.*
FROM hotels h, quartiles q
WHERE CAST(h.Harga AS DECIMAL) < q.Q1 - 1.5 * (q.Q3 - q.Q1)
   OR CAST(h.Harga AS DECIMAL) > q.Q3 + 1.5 * (q.Q3 - q.Q1);

-- Menghapus Duplikat
WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Hotel, Star, Rating, Reviews, Harga, Places, Nearby, [Facil + Akomod] ORDER BY Hotel) AS rn
    FROM hotels
)
DELETE FROM cte
WHERE rn > 1;

-- Menghapus Baris Missing Values
DELETE FROM hotels
WHERE Hotel IS NULL
   OR Star IS NULL
   OR Rating IS NULL
   OR Reviews IS NULL
   OR Harga IS NULL
   OR Places IS NULL
   OR Nearby IS NULL
   OR [Facil + Akomod] IS NULL;

-- Menghapus Outlier (contoh untuk kolom Harga)
WITH quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CAST(Harga AS DECIMAL)) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CAST(Harga AS DECIMAL)) AS Q3
    FROM hotels
),
outliers AS (
    SELECT Hotel
    FROM hotels, quartiles
    WHERE CAST(Harga AS DECIMAL) < Q1 - 1.5 * (Q3 - Q1)
       OR CAST(Harga AS DECIMAL) > Q3 + 1.5 * (Q3 - Q1)
)
DELETE FROM hotels
WHERE Hotel IN (SELECT Hotel FROM outliers);

-- Membandingkan Jumlah Data Sebelum dan Sesudah Cleaning
-- Sebelum cleaning
SELECT COUNT(*) AS total_rows_before FROM hotels_before_cleaning;

-- Sesudah cleaning (misalnya tabel baru 'hotels_cleaned')
SELECT COUNT(*) AS total_rows_after FROM hotels_cleaned;

-- Total Jumlah Hotels (Distinct)
SELECT COUNT(DISTINCT Hotel) AS Total_Hotels FROM hotels_cleaned;

-- Average Star
SELECT AVG(Star) AS Avg_Star FROM hotels_cleaned;

-- Average Rating
SELECT AVG(Rating) AS Avg_Rating FROM hotels_cleaned;

-- Total Reviewers
SELECT SUM(Reviews) AS Total_Reviewers FROM hotels_cleaned;

-- Total Revenue (asumsi kolom Harga dalam bentuk numerik atau dikonversi)
SELECT SUM(CAST(Harga AS DECIMAL)) AS Total_Revenue FROM hotels_cleaned;

-- Average Price
SELECT AVG(CAST(Harga AS DECIMAL)) AS Avg_Price FROM hotels_cleaned;














