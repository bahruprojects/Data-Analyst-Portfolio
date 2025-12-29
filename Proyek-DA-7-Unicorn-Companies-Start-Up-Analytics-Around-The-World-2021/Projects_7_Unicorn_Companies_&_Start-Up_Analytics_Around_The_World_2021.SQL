-- Menampilkan baris-baris yang muncul lebih dari satu kali
SELECT 
    Company, 
    Valuation_In_Billions, 
    Date_Joined, 
    Country, 
    City, 
    Industry, 
    Investor_1, 
    Investor_2, 
    Investor_3, 
    Investor_4,
    COUNT(*) AS duplicate_count
FROM Unicorn
GROUP BY Company, Valuation_In_Billions, Date_Joined, Country, City, Industry, Investor_1, Investor_2, Investor_3, Investor_4
HAVING COUNT(*) > 1;

-- Deteksi Data Kosong (Missing Values)
SELECT *
FROM Unicorn
WHERE Company IS NULL
   OR Valuation_In_Billions IS NULL
   OR Date_Joined IS NULL
   OR Country IS NULL
   OR City IS NULL
   OR Industry IS NULL
   OR Investor_1 IS NULL
   OR Investor_2 IS NULL
   OR Investor_3 IS NULL
   OR Investor_4 IS NULL;

-- Deteksi Outlier pada Valuation_In_Billions (Menggunakan IQR)
-- Catatan: Fungsi PERCENTILE_CONT tersedia di beberapa DBMS (misal: PostgreSQL, SQL Server).
WITH stats AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Valuation_In_Billions) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Valuation_In_Billions) AS Q3
  FROM Unicorn
)
SELECT u.*
FROM Unicorn u, stats
WHERE u.Valuation_In_Billions < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR u.Valuation_In_Billions > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Menghapus Data Duplikat, Missing Values, dan Outlier
-- Hapus Duplikat (menyimpan satu baris untuk tiap data yang sama):
WITH CTE AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY Company, Valuation_In_Billions, Date_Joined, Country, City, Industry, Investor_1, Investor_2, Investor_3, Investor_4 
                       ORDER BY [Index]) AS rn
  FROM Unicorn
)
DELETE FROM CTE
WHERE rn > 1;

-- Hapus Baris dengan Missing Values:
DELETE FROM Unicorn
WHERE Company IS NULL
   OR Valuation_In_Billions IS NULL
   OR Date_Joined IS NULL
   OR Country IS NULL
   OR City IS NULL
   OR Industry IS NULL
   OR Investor_1 IS NULL
   OR Investor_2 IS NULL
   OR Investor_3 IS NULL
   OR Investor_4 IS NULL;

-- Hapus Outlier pada Valuation_In_Billions:
WITH stats AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Valuation_In_Billions) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Valuation_In_Billions) AS Q3
  FROM Unicorn
)
DELETE FROM Unicorn
WHERE Valuation_In_Billions < (SELECT Q1 - 1.5 * (Q3 - Q1) FROM stats)
   OR Valuation_In_Billions > (SELECT Q3 + 1.5 * (Q3 - Q1) FROM stats);

-- Menampilkan Metrik Utama
SELECT 
  (SELECT COUNT(DISTINCT Company) FROM Unicorn) AS Total_Companies,
  (SELECT COUNT(DISTINCT City) FROM Unicorn) AS Total_Cities,
  (SELECT COUNT(DISTINCT Country) FROM Unicorn) AS Total_Countries,
  (SELECT MAX(Valuation_In_Billions) FROM Unicorn) AS Highest_Valuation;



