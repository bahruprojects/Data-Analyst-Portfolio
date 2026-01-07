-- Mendeteksi duplikat (berdasarkan semua kolom)
SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country, COUNT(*) AS cnt
FROM dataset
GROUP BY InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
HAVING COUNT(*) > 1;

-- Mendeteksi missing values
SELECT *
FROM dataset
WHERE InvoiceNo IS NULL
   OR StockCode IS NULL
   OR Description IS NULL
   OR Quantity IS NULL
   OR InvoiceDate IS NULL
   OR UnitPrice IS NULL
   OR CustomerID IS NULL
   OR Country IS NULL;

-- Mendeteksi outlier pada kolom Quantity (menggunakan metode IQR)
WITH quantiles AS (
    SELECT 
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity) AS Q1,
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity) AS Q3
    FROM dataset
)
SELECT d.*
FROM dataset d, quantiles q
WHERE d.Quantity < (q.Q1 - 1.5 * (q.Q3 - q.Q1))
   OR d.Quantity > (q.Q3 + 1.5 * (q.Q3 - q.Q1));

-- Melakukan Data Cleaning dan Membuat Tabel Baru
WITH quantiles_quantity AS (
    SELECT
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity) AS Q1,
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity) AS Q3
    FROM dataset
),
quantiles_unitprice AS (
    SELECT
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY UnitPrice) AS Q1,
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY UnitPrice) AS Q3
    FROM dataset
)
SELECT DISTINCT *
INTO dataset_cleaned
FROM dataset d, quantiles_quantity qq, quantiles_unitprice qu
WHERE InvoiceNo IS NOT NULL
  AND StockCode IS NOT NULL
  AND Description IS NOT NULL
  AND Quantity IS NOT NULL
  AND InvoiceDate IS NOT NULL
  AND UnitPrice IS NOT NULL
  AND CustomerID IS NOT NULL
  AND Country IS NOT NULL
  AND Quantity BETWEEN (qq.Q1 - 1.5*(qq.Q3 - qq.Q1)) AND (qq.Q3 + 1.5*(qq.Q3 - qq.Q1))
  AND UnitPrice BETWEEN (qu.Q1 - 1.5*(qu.Q3 - qu.Q1)) AND (qu.Q3 + 1.5*(qu.Q3 - qu.Q1));

-- Jumlah baris sebelum cleaning
SELECT COUNT(*) AS total_rows FROM dataset;

-- Jumlah baris setelah cleaning
SELECT COUNT(*) AS total_rows FROM dataset_cleaned;

-- Query untuk Menghitung Metrik Terukur
-- Total Transactions
SELECT COUNT(*) AS TotalTransactions
FROM dataset_cleaned;

-- Total Profit (SUM(Quantity * UnitPrice))
SELECT SUM(Quantity * UnitPrice) AS TotalProfit
FROM dataset_cleaned;

-- Total Customers dan Total Unique Customers
SELECT COUNT(CustomerID) AS TotalCustomers,
       COUNT(DISTINCT CustomerID) AS TotalUniqueCustomers
FROM dataset_cleaned;

-- Profit Berdasarkan Country
SELECT Country, SUM(Quantity * UnitPrice) AS Profit
FROM dataset_cleaned
GROUP BY Country
ORDER BY Profit DESC;

-- Profit Berdasarkan InvoiceNo
SELECT InvoiceNo, SUM(Quantity * UnitPrice) AS Profit
FROM dataset_cleaned
GROUP BY InvoiceNo
ORDER BY Profit DESC;

-- Profit vs Year-Month (asumsikan InvoiceDate bertipe DATE)
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS YearMonth, SUM(Quantity * UnitPrice) AS Profit
FROM dataset_cleaned
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY YearMonth;

-- Profit vs Year-Quartal
SELECT CONCAT(YEAR(InvoiceDate), '-Q', QUARTER(InvoiceDate)) AS YearQuarter, SUM(Quantity * UnitPrice) AS Profit
FROM dataset_cleaned
GROUP BY CONCAT(YEAR(InvoiceDate), '-Q', QUARTER(InvoiceDate))
ORDER BY YearQuarter;






































































