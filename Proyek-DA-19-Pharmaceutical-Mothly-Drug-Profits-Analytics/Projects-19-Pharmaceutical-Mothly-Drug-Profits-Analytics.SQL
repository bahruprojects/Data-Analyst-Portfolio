-- Menemukan baris duplikat berdasarkan semua kolom
SELECT datum, M01AB, M01AE, N02BA, N02BE, N05B, N05C, R03, R06, COUNT(*) AS duplicate_count
FROM salesmonthly
GROUP BY datum, M01AB, M01AE, N02BA, N02BE, N05B, N05C, R03, R06
HAVING COUNT(*) > 1;

-- Menampilkan baris yang memiliki nilai NULL pada salah satu kolom
SELECT *
FROM salesmonthly
WHERE datum IS NULL
   OR M01AB IS NULL
   OR M01AE IS NULL
   OR N02BA IS NULL
   OR N02BE IS NULL
   OR N05B IS NULL
   OR N05C IS NULL
   OR R03 IS NULL
   OR R06 IS NULL;

-- Deteksi Outliers (Contoh untuk kolom M01AB)
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY M01AB) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY M01AB) AS Q3
    FROM salesmonthly
)
SELECT s.*
FROM salesmonthly s, stats
WHERE s.M01AB < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR s.M01AB > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Hapus duplikat
-- Misalkan tabel asli adalah salesmonthly dan kita membuat tabel baru tanpa duplikat
CREATE TABLE salesmonthly_cleaned AS
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY datum, M01AB, M01AE, N02BA, N02BE, N05B, N05C, R03, R06 ORDER BY datum) AS rn
    FROM salesmonthly
) t
WHERE rn = 1;

-- Hapus missing values
DELETE FROM salesmonthly_cleaned
WHERE datum IS NULL
   OR M01AB IS NULL
   OR M01AE IS NULL
   OR N02BA IS NULL
   OR N02BE IS NULL
   OR N05B IS NULL
   OR N05C IS NULL
   OR R03 IS NULL
   OR R06 IS NULL;

-- Menampilkan Perbandingan Data Sebelum dan Sesudah Cleaning
SELECT 'Sebelum Cleaning' AS Stage, COUNT(*) AS TotalRows FROM salesmonthly_original
UNION ALL
SELECT 'Setelah Cleaning', COUNT(*) FROM salesmonthly_cleaned;

-- Total Profit masing-masing obat
SELECT 
    SUM(M01AB) AS Total_M01AB,
    SUM(M01AE) AS Total_M01AE,
    SUM(N02BA) AS Total_N02BA,
    SUM(N02BE) AS Total_N02BE,
    SUM(N05B) AS Total_N05B,
    SUM(N05C) AS Total_N05C,
    SUM(R03) AS Total_R03,
    SUM(R06) AS Total_R06
FROM salesmonthly_cleaned;

-- Line Chart data berdasarkan Bulan-Tahun
SELECT 
    strftime('%Y-%m', datum) AS MonthYear,
    SUM(M01AB) AS Total_M01AB,
    SUM(M01AE) AS Total_M01AE,
    SUM(N02BA) AS Total_N02BA,
    SUM(N02BE) AS Total_N02BE,
    SUM(N05B) AS Total_N05B,
    SUM(N05C) AS Total_N05C,
    SUM(R03) AS Total_R03,
    SUM(R06) AS Total_R06
FROM salesmonthly_cleaned
GROUP BY MonthYear
ORDER BY MonthYear;



































































