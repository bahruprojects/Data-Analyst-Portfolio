-- Query untuk mendeteksi baris duplikat (mengelompokkan semua kolom)
SELECT 
    COMPANY, MODEL, TYPE, SIZE, transmission, state, condition, odometer, color, interior, seller, mmr, sellingprice, "Sale Day", "Sale month", saleyear,
    COUNT(*) AS count_duplicates
FROM car_prices_3
GROUP BY 
    COMPANY, MODEL, TYPE, SIZE, transmission, state, condition, odometer, color, interior, seller, mmr, sellingprice, "Sale Day", "Sale month", saleyear
HAVING COUNT(*) > 1;

-- Query untuk menghitung missing values per kolom
SELECT 
    SUM(CASE WHEN COMPANY IS NULL THEN 1 ELSE 0 END) AS missing_company,
    SUM(CASE WHEN MODEL IS NULL THEN 1 ELSE 0 END) AS missing_model,
    SUM(CASE WHEN SIZE IS NULL THEN 1 ELSE 0 END) AS missing_size,
    SUM(CASE WHEN transmission IS NULL THEN 1 ELSE 0 END) AS missing_transmission,
    SUM(CASE WHEN condition IS NULL THEN 1 ELSE 0 END) AS missing_condition,
    SUM(CASE WHEN odometer IS NULL THEN 1 ELSE 0 END) AS missing_odometer,
    SUM(CASE WHEN color IS NULL THEN 1 ELSE 0 END) AS missing_color,
    SUM(CASE WHEN interior IS NULL THEN 1 ELSE 0 END) AS missing_interior,
    SUM(CASE WHEN seller IS NULL THEN 1 ELSE 0 END) AS missing_seller,
    SUM(CASE WHEN mmr IS NULL THEN 1 ELSE 0 END) AS missing_mmr,
    SUM(CASE WHEN sellingprice IS NULL THEN 1 ELSE 0 END) AS missing_sellingprice,
    SUM(CASE WHEN "SaleDay" IS NULL THEN 1 ELSE 0 END) AS missing_sale_day,
    SUM(CASE WHEN "Salemonth" IS NULL THEN 1 ELSE 0 END) AS missing_sale_month,
    SUM(CASE WHEN SaleYear IS NULL THEN 1 ELSE 0 END) AS missing_saleyear
FROM car_prices_3;

-- Mendeteksi Outlier (Contoh untuk sellingprice menggunakan IQR)
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sellingprice) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sellingprice) AS Q3
    FROM car_prices_3
)
SELECT cp.*
FROM car_prices_3 cp, stats
WHERE cp.sellingprice < stats.Q1 - 1.5 * (stats.Q3 - stats.Q1)
   OR cp.sellingprice > stats.Q3 + 1.5 * (stats.Q3 - stats.Q1);


-- Membuat tabel baru hasil cleaning (contoh untuk dua kolom numerik: sellingprice dan odometer)
CREATE TABLE car_prices_3_cleaned AS
WITH stats_sellingprice AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sellingprice) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sellingprice) AS Q3
    FROM car_prices_3
),
stats_odometer AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY odometer) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY odometer) AS Q3
    FROM car_prices_3
),
cleaned AS (
    SELECT *
    FROM car_prices_3
    WHERE COMPANY IS NOT NULL AND MODEL IS NOT NULL AND TYPE IS NOT NULL 
      AND SIZE IS NOT NULL AND transmission IS NOT NULL AND state IS NOT NULL 
      AND condition IS NOT NULL AND odometer IS NOT NULL AND color IS NOT NULL 
      AND interior IS NOT NULL AND seller IS NOT NULL AND mmr IS NOT NULL 
      AND sellingprice IS NOT NULL AND "Sale Day" IS NOT NULL 
      AND "Sale month" IS NOT NULL AND saleyear IS NOT NULL
)
SELECT DISTINCT c.*
FROM cleaned c,
     stats_sellingprice ssp,
     stats_odometer so
WHERE c.sellingprice BETWEEN ssp.Q1 - 1.5 * (ssp.Q3 - ssp.Q1) AND ssp.Q3 + 1.5 * (ssp.Q3 - ssp.Q1)
  AND c.odometer BETWEEN so.Q1 - 1.5 * (so.Q3 - so.Q1) AND so.Q3 + 1.5 * (so.Q3 - so.Q1);

-- Jumlah baris sebelum cleaning
SELECT COUNT(*) AS total_rows_before FROM car_prices_3;

-- Jumlah baris setelah cleaning
SELECT COUNT(*) AS total_rows_after FROM car_prices_3_cleaned;

-- Query untuk Menampilkan Metrik
SELECT 
    (SELECT COUNT(DISTINCT COMPANY) FROM car_prices_3_cleaned) AS total_brands,
    (SELECT COUNT(DISTINCT MODEL) FROM car_prices_3_cleaned) AS total_models,
    (SELECT COUNT(*) FROM car_prices_3_cleaned) AS total_sales,
    (SELECT AVG(sellingprice) FROM car_prices_3_cleaned) AS avg_price,
    (SELECT SUM(sellingprice) FROM car_prices_3_cleaned) AS total_sales_profit;


