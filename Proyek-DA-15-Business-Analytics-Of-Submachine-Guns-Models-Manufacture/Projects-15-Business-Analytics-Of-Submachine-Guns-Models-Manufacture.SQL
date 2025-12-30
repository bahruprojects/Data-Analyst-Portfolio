-- Deteksi Duplikat, Missing Values, dan Outliers
-- Duplikat
SELECT Name, Manufacturer, Country, Introduced, Type, COUNT(*) AS cnt
FROM df_2
GROUP BY Name, Manufacturer, Country, Introduced, Type
HAVING COUNT(*) > 1;

-- Missing Values
SELECT *
FROM df_2
WHERE Name IS NULL 
   OR Manufacturer IS NULL 
   OR Country IS NULL 
   OR Introduced IS NULL 
   OR Type IS NULL;

-- Outliers pada Introduced:
-- Misalnya, anggap outlier jika tahun < 1900 atau tahun > tahun saat ini
-- (Sintaks fungsi tanggal dapat bervariasi, contoh di bawah menggunakan fungsi YEAR())
SELECT *
FROM df_2
WHERE YEAR(Introduced) < 1900 OR YEAR(Introduced) > YEAR(CURRENT_DATE);

-- Melakukan Data Cleaning dan Membandingkan Data Sebelum & Sesudah
CREATE TABLE df_2_cleaned AS
SELECT DISTINCT *
FROM df_2
WHERE Name IS NOT NULL
  AND Manufacturer IS NOT NULL
  AND Country IS NOT NULL
  AND Introduced IS NOT NULL
  AND Type IS NOT NULL
  AND YEAR(Introduced) BETWEEN 1900 AND YEAR(CURRENT_DATE);

-- Untuk membandingkan jumlah record sebelum dan sesudah cleaning
SELECT 'Before Cleaning' AS Stage, COUNT(*) AS TotalRecords FROM df_2
UNION ALL
SELECT 'After Cleaning' AS Stage, COUNT(*) AS TotalRecords FROM df_2_cleaned;

--Menampilkan Metrik Terukur
SELECT
  (SELECT COUNT(DISTINCT Name) FROM df_2_cleaned) AS Distinct_Product_Names,
  (SELECT COUNT(DISTINCT Manufacturer) FROM df_2_cleaned) AS Distinct_Manufacturers,
  (SELECT COUNT(DISTINCT Country) FROM df_2_cleaned) AS Distinct_Countries,
  (SELECT COUNT(DISTINCT Type) FROM df_2_cleaned) AS Distinct_Types;

-- Bar Chart Data (Agregasi per Type, Manufacturer, Country)
-- Jenis Machine Gun
SELECT Type, COUNT(*) AS Count
FROM df_2_cleaned
GROUP BY Type
ORDER BY Count DESC;

-- Top 20 Manufacturer
SELECT Manufacturer, COUNT(*) AS Count
FROM df_2_cleaned
GROUP BY Manufacturer
ORDER BY Count DESC
LIMIT 20;

-- Distribusi Country
SELECT Country, COUNT(*) AS Count
FROM df_2_cleaned
GROUP BY Country
ORDER BY Count DESC;

-- Line Chart: Production Year vs Count of Models
SELECT YEAR(Introduced) AS Production_Year, COUNT(*) AS Model_Count
FROM df_2_cleaned
GROUP BY YEAR(Introduced)
ORDER BY Production_Year;




































































