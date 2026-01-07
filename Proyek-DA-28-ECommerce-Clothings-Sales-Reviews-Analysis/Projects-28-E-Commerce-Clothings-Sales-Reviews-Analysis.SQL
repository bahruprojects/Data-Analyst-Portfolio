-- Mendeteksi duplikat berdasarkan semua kolom (asumsi data duplikat memiliki nilai yang sama di seluruh kolom)
SELECT 
    "Clothing ID", Age, Title, "Review Text", Rating, "Recommended IND", "Positive Feedback Count", 
    "Division Name", "Department Name", "Class Name",
    COUNT(*) AS cnt
FROM Womens_Clothing_Reviews
GROUP BY 
    "Clothing ID", Age, Title, "Review Text", Rating, "Recommended IND", "Positive Feedback Count", 
    "Division Name", "Department Name", "Class Name"
HAVING COUNT(*) > 1;

-- Menghitung jumlah missing (NULL) pada setiap kolom
SELECT 
    SUM(CASE WHEN "Clothing ID" IS NULL THEN 1 ELSE 0 END) AS Clothing_ID_Missing,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Age_Missing,
    SUM(CASE WHEN Title IS NULL THEN 1 ELSE 0 END) AS Title_Missing,
    SUM(CASE WHEN "Review Text" IS NULL THEN 1 ELSE 0 END) AS Review_Text_Missing,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS Rating_Missing,
    SUM(CASE WHEN "Recommended IND" IS NULL THEN 1 ELSE 0 END) AS Recommended_IND_Missing,
    SUM(CASE WHEN "Positive Feedback Count" IS NULL THEN 1 ELSE 0 END) AS Positive_Feedback_Missing,
    SUM(CASE WHEN "Division Name" IS NULL THEN 1 ELSE 0 END) AS Division_Name_Missing,
    SUM(CASE WHEN "Department Name" IS NULL THEN 1 ELSE 0 END) AS Department_Name_Missing,
    SUM(CASE WHEN "Class Name" IS NULL THEN 1 ELSE 0 END) AS Class_Name_Missing
FROM Womens_Clothing_Reviews;

-- Menggunakan metode IQR untuk mendeteksi outlier pada kolom Age
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) AS Q3
    FROM Womens_Clothing_Reviews
)
SELECT w.*
FROM Womens_Clothing_Reviews w, stats
WHERE w.Age < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR w.Age > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- -- Membuat tabel baru dengan data yang telah dibersihkan
-- CREATE TABLE Womens_Clothing_Reviews_Cleaned AS
-- SELECT DISTINCT *
-- FROM Womens_Clothing_Reviews
-- WHERE "Clothing ID" IS NOT NULL
--   AND Age IS NOT NULL
--   AND Title IS NOT NULL
--   AND "Review Text" IS NOT NULL
--   AND Rating IS NOT NULL
--   AND "Recommended IND" IS NOT NULL
--   AND "Positive Feedback Count" IS NOT NULL
--   AND "Division Name" IS NOT NULL
--   AND "Department Name" IS NOT NULL
--   AND "Class Name" IS NOT NULL
--   AND Age BETWEEN (
--       SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) - 1.5 * 
--              (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age))
--       FROM Womens_Clothing_Reviews
--   )
--   AND (
--       SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) + 1.5 * 
--              (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age))
--       FROM Womens_Clothing_Reviews
--   );

-- Total baris sebelum cleaning
SELECT COUNT(*) AS Total_Rows FROM Womens_Clothing_Reviews;

-- Total baris setelah cleaning
SELECT COUNT(*) AS Total_Rows_Cleaned FROM Womens_Clothing_Reviews_Cleaned;

-- Query untuk Metrik-Metrik Terukur
SELECT 
    COUNT("Clothing ID") AS Total_Transactions,
    COUNT(DISTINCT "Clothing ID") AS Total_Items,
    AVG(Rating) AS Average_Rating,
    SUM("Positive Feedback Count") AS Total_Positive_Feedback
FROM Womens_Clothing_Reviews_Cleaned;

-- Percentages by Division Name
SELECT "Division Name", COUNT(*) AS Count
FROM Womens_Clothing_Reviews_Cleaned
GROUP BY "Division Name";

-- Sales by Department Name
SELECT "Department Name", COUNT(*) AS Count
FROM Womens_Clothing_Reviews_Cleaned
GROUP BY "Department Name";

-- Sales by Class Name
SELECT "Class Name", COUNT(*) AS Count
FROM Womens_Clothing_Reviews_Cleaned
GROUP BY "Class Name";

-- Percentages By Recommendation Rated
SELECT "Recommended IND", COUNT(*) AS Count
FROM Womens_Clothing_Reviews_Cleaned
GROUP BY "Recommended IND";

-- Total Sales by Class Name (misalkan jumlah review per class sebagai proxy)
SELECT "Class Name", COUNT(*) AS Total_Sales
FROM Womens_Clothing_Reviews_Cleaned
GROUP BY "Class Name"
ORDER BY "Class Name";






































































