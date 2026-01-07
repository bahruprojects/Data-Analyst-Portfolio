-- Deteksi dan Pembersihan Data
-- 1. Deteksi duplikat berdasarkan TransactionNo
SELECT TransactionNo, COUNT(*) AS cnt
FROM Bakery
GROUP BY TransactionNo
HAVING COUNT(*) > 1;

-- 2. Deteksi baris dengan missing values
SELECT *
FROM Bakery
WHERE TransactionNo IS NULL
   OR Items IS NULL
   OR DateTime IS NULL
   OR Daypart IS NULL
   OR DayType IS NULL;

-- 3. Deteksi outlier berdasarkan ItemCount (asumsi kolom ItemCount telah dihitung)
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ItemCount) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ItemCount) AS Q3
    FROM Bakery
)
SELECT b.*
FROM Bakery b, stats
WHERE b.ItemCount < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR b.ItemCount > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- 4. Hapus duplikat (contoh menggunakan CTE dan ROW_NUMBER)
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY TransactionNo ORDER BY TransactionNo) AS rn
    FROM Bakery
)
DELETE FROM CTE WHERE rn > 1;

-- 5. Hapus baris dengan missing values
DELETE FROM Bakery
WHERE TransactionNo IS NULL
   OR Items IS NULL
   OR DateTime IS NULL
   OR Daypart IS NULL
   OR DayType IS NULL;

-- 6. Hapus outlier berdasarkan ItemCount
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ItemCount) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ItemCount) AS Q3
    FROM Bakery
)
DELETE FROM Bakery
WHERE ItemCount < ((SELECT Q1 FROM stats) - 1.5 * ((SELECT Q3 FROM stats) - (SELECT Q1 FROM stats)))
   OR ItemCount > ((SELECT Q3 FROM stats) + 1.5 * ((SELECT Q3 FROM stats) - (SELECT Q1 FROM stats)));

-- Query untuk Menampilkan Metrik Terukur
-- Total Transactions
SELECT COUNT(TransactionNo) AS TotalTransactions
FROM Bakery;

-- Total Unique Items (asumsi tiap baris Items adalah string; untuk menghitung item individual diperlukan pemrosesan string)
SELECT COUNT(DISTINCT Items) AS TotalDistinctItems
FROM Bakery;

-- Distribusi transaksi berdasarkan DayType (misalnya weekend vs weekday)
SELECT DayType, COUNT(*) AS TransactionCount
FROM Bakery
GROUP BY DayType;

-- Transaksi berdasarkan Daypart
SELECT Daypart, COUNT(*) AS TransactionCount
FROM Bakery
GROUP BY Daypart;

-- Total Transactions by Date
SELECT CAST(DateTime AS DATE) AS TransactionDate, COUNT(*) AS TotalTransactions
FROM Bakery
GROUP BY CAST(DateTime AS DATE)
ORDER BY TransactionDate;




