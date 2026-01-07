-- Deteksi Duplikat
SELECT work_year, experience_level, employment_type, job_title, salary, salary_currency, salary_in_usd, employee_residence, remote_ratio, company_location, company_size, COUNT(*) AS duplicate_count
FROM ds_salaries
GROUP BY work_year, experience_level, employment_type, job_title, salary, salary_currency, salary_in_usd, employee_residence, remote_ratio, company_location, company_size
HAVING COUNT(*) > 1;

-- Deteksi Missing Values kolom "work_year".
SELECT COUNT(*) AS missing_work_year FROM ds_salaries WHERE work_year IS NULL;

-- Deteksi Outliers (Contoh: untuk kolom salary menggunakan metode IQR).
WITH salary_stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS Q3
    FROM ds_salaries
)
SELECT s.*
FROM ds_salaries s, salary_stats
WHERE s.salary < (salary_stats.Q1 - 1.5 * (salary_stats.Q3 - salary_stats.Q1))
   OR s.salary > (salary_stats.Q3 + 1.5 * (salary_stats.Q3 - salary_stats.Q1));

-- Melakukan Data Cleaning (Menghapus Duplikat, Missing Values, dan Outliers).
-- Contoh untuk menghapus duplikat dengan menyimpan data unik ke tabel baru
CREATE TABLE ds_salaries_cleaned AS
SELECT DISTINCT *
FROM ds_salaries;

-- Untuk missing values, bisa digunakan filter.
CREATE TABLE ds_salaries_cleaned AS
SELECT *
FROM ds_salaries
WHERE work_year IS NOT NULL
  AND experience_level IS NOT NULL
  AND employment_type IS NOT NULL
  AND job_title IS NOT NULL
  AND salary IS NOT NULL
  AND salary_currency IS NOT NULL
  AND salary_in_usd IS NOT NULL
  AND employee_residence IS NOT NULL
  AND remote_ratio IS NOT NULL
  AND company_location IS NOT NULL
  AND company_size IS NOT NULL;

-- Query Metrik Terukur.
-- Distribusi Ukuran Perusahaan.
SELECT company_size, COUNT(*) AS count
FROM ds_salaries_cleaned
GROUP BY company_size;

-- Distribusi Experience Level.
SELECT experience_level, COUNT(*) AS count
FROM ds_salaries_cleaned
GROUP BY experience_level;

-- Distribusi Ukuran Perusahaan dalam Persentase.
SELECT 
  company_size, 
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ds_salaries_cleaned) AS percentage
FROM ds_salaries_cleaned
GROUP BY company_size;

-- Distribusi Experience Level dalam Persentase.
SELECT 
  experience_level, 
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ds_salaries_cleaned) AS percentage
FROM ds_salaries_cleaned
GROUP BY experience_level;

--Distribusi Job Title (jumlah masing-masing job_title).
SELECT job_title, COUNT(*) AS count
FROM ds_salaries_cleaned
GROUP BY job_title;

--Distribusi Job Title dalam Persentase.
SELECT 
  job_title, 
  COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ds_salaries_cleaned) AS percentage
FROM ds_salaries_cleaned
GROUP BY job_title;


--Gaji Rata-rata per Negara.
SELECT employee_residence, AVG(salary_in_usd) AS avg_salary
FROM ds_salaries_cleaned
GROUP BY employee_residence
ORDER BY avg_salary DESC;

--Rata-rata Gaji Berdasarkan Job Title, Experience, dan Employment Type.
SELECT job_title, experience_level, employment_type, AVG(salary_in_usd) AS avg_salary
FROM ds_salaries_cleaned
GROUP BY job_title, experience_level, employment_type
ORDER BY avg_salary DESC;






































































