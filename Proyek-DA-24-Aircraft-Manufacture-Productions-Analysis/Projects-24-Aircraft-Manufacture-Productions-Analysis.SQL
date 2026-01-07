-- Mendeteksi duplikat
SELECT aircraft, nbBuilt, startDate, endDate, retired, COUNT(*) AS cnt
FROM aircraft_data
GROUP BY aircraft, nbBuilt, startDate, endDate, retired
HAVING COUNT(*) > 1;

-- Mendeteksi missing values
SELECT *
FROM aircraft_data
WHERE aircraft IS NULL 
   OR nbBuilt IS NULL 
   OR startDate IS NULL 
   OR endDate IS NULL 
   OR retired IS NULL;

-- Mendeteksi outliers (contoh untuk kolom nbBuilt menggunakan metode IQR)
WITH stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY nbBuilt) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY nbBuilt) AS Q3
  FROM aircraft_data
)
SELECT a.*
FROM aircraft_data a, stats
WHERE a.nbBuilt < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR a.nbBuilt > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Membersihkan data (hapus duplikat, missing values, dan outliers)
WITH CTE AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY aircraft, nbBuilt, startDate, endDate, retired ORDER BY (SELECT NULL)) AS rn
  FROM aircraft_data
)
DELETE FROM CTE WHERE rn > 1;

-- Hapus missing values
DELETE FROM aircraft_data
WHERE aircraft IS NULL 
   OR nbBuilt IS NULL 
   OR startDate IS NULL 
   OR endDate IS NULL 
   OR retired IS NULL;

-- Hapus outliers untuk kolom nbBuilt
WITH stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY nbBuilt) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY nbBuilt) AS Q3
  FROM aircraft_data
)
DELETE FROM aircraft_data
WHERE nbBuilt < (SELECT Q1 - 1.5 * (Q3 - Q1) FROM stats)
   OR nbBuilt > (SELECT Q3 + 1.5 * (Q3 - Q1) FROM stats);

-- Jumlah Merek Aircraft (Count Distinct), Rata-rata Umur, dan Total Produksi Aircraft
SELECT 
  COUNT(DISTINCT aircraft) AS distinct_aircraft_count,
  AVG(endDate - startDate) AS average_age,
  SUM(nbBuilt) AS total_aircraft_productions
FROM aircraft_data;

-- Produksi Aircraft per Tahun (Line Chart)
SELECT startDate AS production_year, SUM(nbBuilt) AS total_productions
FROM aircraft_data
GROUP BY startDate
ORDER BY startDate;

-- Rata-rata Umur per Merek Aircraft (Bar Chart)
SELECT aircraft, AVG(endDate - startDate) AS average_age
FROM aircraft_data
GROUP BY aircraft;

































































