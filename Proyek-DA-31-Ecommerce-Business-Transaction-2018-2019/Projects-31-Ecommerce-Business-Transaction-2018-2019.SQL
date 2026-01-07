-- Menampilkan transaksi duplikat berdasarkan TransactionNo
SELECT TransactionNo, COUNT(*) AS cnt
FROM SalesTransaction
GROUP BY TransactionNo
HAVING COUNT(*) > 1;

-- Menampilkan jumlah record dengan CustomerNo yang NULL
SELECT COUNT(*) AS MissingCustomerNo
FROM SalesTransaction
WHERE CustomerNo IS NULL;

--  Deteksi Outlier untuk Kolom Price (menggunakan metode IQR)
WITH PriceStats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) AS Q3
  FROM SalesTransaction
)
SELECT *
FROM SalesTransaction, PriceStats
WHERE Price < Q1 - 1.5 * (Q3 - Q1)
   OR Price > Q3 + 1.5 * (Q3 - Q1);

-- Membuat Tabel Cleaned (Menghapus duplikat, missing, outlier)
CREATE TABLE SalesTransaction_Cleaned AS
SELECT DISTINCT *
FROM SalesTransaction
WHERE CustomerNo IS NOT NULL
  AND Price BETWEEN 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price)
       FROM SalesTransaction) - 1.5 * (
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price)
       FROM SalesTransaction) - 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price)
       FROM SalesTransaction))
      AND 
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price)
       FROM SalesTransaction) + 1.5 * (
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price)
       FROM SalesTransaction) - 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price)
       FROM SalesTransaction))
  AND Quantity BETWEEN 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity)
       FROM SalesTransaction) - 1.5 * (
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity)
       FROM SalesTransaction) - 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity)
       FROM SalesTransaction))
      AND 
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity)
       FROM SalesTransaction) + 1.5 * (
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Quantity)
       FROM SalesTransaction) - 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Quantity)
       FROM SalesTransaction));

-- Query untuk Metrik Terukur
-- Total Transactions
SELECT COUNT(*) AS TotalTransactions FROM SalesTransaction_Cleaned;

-- Total Profits
SELECT SUM(Price * Quantity) AS TotalProfits FROM SalesTransaction_Cleaned;

-- Total Customers (jumlah record)
SELECT COUNT(CustomerNo) AS TotalCustomers FROM SalesTransaction_Cleaned;

-- Total Unique Customers
SELECT COUNT(DISTINCT CustomerNo) AS TotalUniqueCustomers FROM SalesTransaction_Cleaned;

-- Total Unique Products
SELECT COUNT(DISTINCT ProductNo) AS TotalUniqueProducts FROM SalesTransaction_Cleaned;

-- Top 10 Negara berdasarkan jumlah transaksi
SELECT Country, COUNT(*) AS TransactionCount
FROM SalesTransaction_Cleaned
GROUP BY Country
ORDER BY TransactionCount DESC
LIMIT 10;

-- Top 30 Produk Paling Menguntungkan
SELECT ProductNo, SUM(Price * Quantity) AS Profit
FROM SalesTransaction_Cleaned
GROUP BY ProductNo
ORDER BY Profit DESC
LIMIT 30;

-- Profit per Month-Year (dengan asumsi kolom Date bertipe DATE)
SELECT DATE_FORMAT(Date, '%Y-%m') AS MonthYear, SUM(Price * Quantity) AS Profit
FROM SalesTransaction_Cleaned
GROUP BY MonthYear
ORDER BY MonthYear;

-- Jumlah Transaksi per Month-Year
SELECT DATE_FORMAT(Date, '%Y-%m') AS MonthYear, COUNT(*) AS TransactionCount
FROM SalesTransaction_Cleaned
GROUP BY MonthYear
ORDER BY MonthYear;








































































