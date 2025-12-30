-- Mendeteksi baris duplikat berdasarkan kombinasi kolom kunci (misal: Store dan Date)
SELECT Store, Date, COUNT(*) as count
FROM Walmart_Sales
GROUP BY Store, Date
HAVING COUNT(*) > 1;

-- Menghitung jumlah missing values per kolom
SELECT 
    SUM(CASE WHEN Store IS NULL THEN 1 ELSE 0 END) AS missing_store,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN Weekly_Sales IS NULL THEN 1 ELSE 0 END) AS missing_weekly_sales,
    SUM(CASE WHEN Holiday_Flag IS NULL THEN 1 ELSE 0 END) AS missing_holiday_flag,
    SUM(CASE WHEN Temperature IS NULL THEN 1 ELSE 0 END) AS missing_temperature,
    SUM(CASE WHEN Fuel_Price IS NULL THEN 1 ELSE 0 END) AS missing_fuel_price,
    SUM(CASE WHEN CPI IS NULL THEN 1 ELSE 0 END) AS missing_cpi,
    SUM(CASE WHEN Unemployment IS NULL THEN 1 ELSE 0 END) AS missing_unemployment
FROM Walmart_Sales;

-- Mendeteksi Outliers.Misalnya, untuk kolom Weekly_Sales dengan metode IQR
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Weekly_Sales) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Weekly_Sales) AS Q3
    FROM Walmart_Sales
)
SELECT ws.*
FROM Walmart_Sales ws, stats
WHERE ws.Weekly_Sales < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR ws.Weekly_Sales > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Data Cleaning (Membuat Tabel Bersih)
CREATE TABLE Walmart_Sales_Cleaned AS
SELECT *
FROM Walmart_Sales
WHERE Store IS NOT NULL
  AND Date IS NOT NULL
  AND Weekly_Sales IS NOT NULL
  AND Holiday_Flag IS NOT NULL
  AND Temperature IS NOT NULL
  AND Fuel_Price IS NOT NULL
  AND CPI IS NOT NULL
  AND Unemployment IS NOT NULL
  AND Weekly_Sales BETWEEN 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Weekly_Sales) FROM Walmart_Sales)
      - 1.5 * (
          (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Weekly_Sales) FROM Walmart_Sales) -
          (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Weekly_Sales) FROM Walmart_Sales)
      )
      AND
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Weekly_Sales) FROM Walmart_Sales)
      + 1.5 * (
          (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Weekly_Sales) FROM Walmart_Sales) -
          (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Weekly_Sales) FROM Walmart_Sales)
      );

-- Query untuk Menghitung Metrik Terukur
SELECT 
    COUNT(DISTINCT Store) AS Total_Stores,
    AVG(Unemployment) AS Average_Unemployment_Rate,
    SUM(Weekly_Sales) AS Total_Sales,
    MAX(Fuel_Price) AS Highest_Full_Price,
    MIN(Fuel_Price) AS Lowest_Full_Price,
    AVG(CPI) AS Average_CPI
FROM Walmart_Sales_Cleaned;





































































