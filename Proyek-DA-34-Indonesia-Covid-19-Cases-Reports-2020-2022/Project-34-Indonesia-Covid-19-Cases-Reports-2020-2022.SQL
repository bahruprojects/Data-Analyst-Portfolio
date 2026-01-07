-- Mendeteksi baris duplikat berdasarkan semua kolom
SELECT Date, Location_ISO_Code, Location, New_Cases, New_Deaths, New_Recovered, COUNT(*)
FROM covid_data
GROUP BY Date, Location_ISO_Code, Location, New_Cases, New_Deaths, New_Recovered
HAVING COUNT(*) > 1;

-- Menampilkan jumlah missing value untuk masing-masing kolom (Sampling untuk kolom New_Cases)
SELECT
    SUM(CASE WHEN New_Cases IS NULL THEN 1 ELSE 0 END) AS Missing_New_Cases,
    SUM(CASE WHEN New_Deaths IS NULL THEN 1 ELSE 0 END) AS Missing_New_Deaths,
    SUM(CASE WHEN New_Recovered IS NULL THEN 1 ELSE 0 END) AS Missing_New_Recovered
FROM covid_data;

WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY New_Cases) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY New_Cases) AS Q3
    FROM covid_data
)
SELECT *
FROM covid_data, stats
WHERE New_Cases < (Q1 - 1.5 * (Q3 - Q1))
   OR New_Cases > (Q3 + 1.5 * (Q3 - Q1));

-- Sampling: Menghapus baris dengan missing values pada kolom New_Cases, New_Deaths, dan New_Recovered
DELETE FROM covid_data
WHERE New_Cases IS NULL
   OR New_Deaths IS NULL
   OR New_Recovered IS NULL;

-- Query SQL untuk Menampilkan Semua Metrik Terukur
SELECT Province,
       MAX(Total_Cases) AS Total_Cases,
       MAX(Total_Deaths) AS Total_Deaths,
       MAX(Total_Recovered) AS Total_Recovered,
       MAX(Total_Active_Cases) AS Total_Active_Cases
FROM covid_data
GROUP BY Province;





































































