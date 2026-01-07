-- Deteksi data duplikat berdasarkan semua kolom
SELECT Rating, Company_Name, Job_Title, Salary, Salaries_Reported, Location, COUNT(*) AS cnt
FROM software_salaries
GROUP BY Rating, Company_Name, Job_Title, Salary, Salaries_Reported, Location
HAVING COUNT(*) > 1;

-- Menampilkan baris yang memiliki missing values
SELECT *
FROM software_salaries
WHERE Rating IS NULL
   OR Company_Name IS NULL
   OR Job_Title IS NULL
   OR Salary IS NULL
   OR Salaries_Reported IS NULL
   OR Location IS NULL;

-- Menghitung Q1 dan Q3 untuk Salary
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Salary) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Salary) AS Q3
    FROM software_salaries
)
SELECT s.*
FROM software_salaries s, stats
WHERE s.Salary < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR s.Salary > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Buat tabel baru tanpa duplikat
CREATE TABLE software_salaries_cleaned AS
SELECT DISTINCT *
FROM software_salaries;

-- Buat tabel baru tanpa missing values
CREATE TABLE software_salaries_cleaned_final AS
SELECT *
FROM software_salaries_cleaned
WHERE Rating IS NOT NULL
  AND Company_Name IS NOT NULL
  AND Job_Title IS NOT NULL
  AND Salary IS NOT NULL
  AND Salaries_Reported IS NOT NULL
  AND Location IS NOT NULL;

-- Hapus Outliers pada Salary:
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Salary) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Salary) AS Q3
    FROM software_salaries_cleaned_final
)
CREATE TABLE software_salaries_cleaned_final2 AS
SELECT s.*
FROM software_salaries_cleaned_final s, stats
WHERE s.Salary BETWEEN (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
                   AND (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Jumlah record sebelum cleaning
SELECT COUNT(*) AS Total_Record_Before FROM software_salaries;

-- Jumlah record setelah cleaning
SELECT COUNT(*) AS Total_Record_After FROM software_salaries_cleaned_final2;

-- Query SQL untuk Metrik Utama
SELECT 
    COUNT(*) AS Total_Surveyed,
    COUNT(DISTINCT Company_Name) AS Total_Companies,
    COUNT(DISTINCT Job_Title) AS Total_Job_Positions,
    AVG(Rating) AS Average_Rating_Score,
    AVG(Salary) AS Average_Salary
FROM software_salaries_cleaned_final2;




































































