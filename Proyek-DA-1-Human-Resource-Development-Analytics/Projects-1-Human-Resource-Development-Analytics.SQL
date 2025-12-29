-- Mendeteksi baris duplikat berdasarkan Number ID
SELECT Number_ID, COUNT(*) AS duplicate_count
FROM HR_Analytics
GROUP BY Number_ID
HAVING COUNT(*) > 1;

-- Mengecek missing values di tiap kolom (misalnya, pada satisfaction_level dan last_evaluation)
SELECT 
    SUM(CASE WHEN satisfaction_level IS NULL THEN 1 ELSE 0 END) AS missing_satisfaction_level,
    SUM(CASE WHEN last_evaluation IS NULL THEN 1 ELSE 0 END) AS missing_last_evaluation,
    SUM(CASE WHEN number_project IS NULL THEN 1 ELSE 0 END) AS missing_number_project,
    SUM(CASE WHEN average_montly_hours IS NULL THEN 1 ELSE 0 END) AS missing_average_montly_hours,
    SUM(CASE WHEN time_spend_company IS NULL THEN 1 ELSE 0 END) AS missing_time_spend_company,
    SUM(CASE WHEN Work_accident IS NULL THEN 1 ELSE 0 END) AS missing_Work_accident,
    SUM(CASE WHEN left IS NULL THEN 1 ELSE 0 END) AS missing_left,
    SUM(CASE WHEN promotion_last_5years IS NULL THEN 1 ELSE 0 END) AS missing_promotion_last_5years,
    SUM(CASE WHEN Department IS NULL THEN 1 ELSE 0 END) AS missing_Department,
    SUM(CASE WHEN Salary IS NULL THEN 1 ELSE 0 END) AS missing_Salary
FROM HR_Analytics;

-- Mendeteksi Outliers. Misalnya, untuk kolom average_montly_hours menggunakan metode IQR:
WITH quantiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY average_montly_hours) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY average_montly_hours) AS Q3
    FROM HR_Analytics
)
SELECT *
FROM HR_Analytics, quantiles
WHERE average_montly_hours < (Q1 - 1.5 * (Q3 - Q1))
   OR average_montly_hours > (Q3 + 1.5 * (Q3 - Q1));

-- Data Cleaning Secara SQL
DELETE FROM HR_Analytics
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM HR_Analytics
    GROUP BY Number_ID
);

-- Query SQL untuk Metrik Terukur:
-- Jumlah Karyawan Aktif
SELECT (COUNT(DISTINCT Number_ID) - SUM(left)) AS active_employees
FROM HR_Analytics;

-- Jumlah Karyawan Resign
SELECT SUM(left) AS resigned_employees
FROM HR_Analytics;

-- Persentase Resign
SELECT (SUM(left) / COUNT(DISTINCT Number_ID)) * 100 AS resignation_percentage
FROM HR_Analytics;

-- Average Performance Rate
SELECT AVG(last_evaluation) * 100 AS avg_performance
FROM HR_Analytics;

-- Satisfaction Level
SELECT AVG(satisfaction_level) * 100 AS avg_satisfaction
FROM HR_Analytics;

-- Data untuk Bar Chart Berdasarkan Department
SELECT 
    Department,
    SUM(left) AS total_resign,
    COUNT(Number_ID) AS total_employees,
    (SUM(left) / COUNT(Number_ID)) * 100 AS turnover_rate,
    AVG(satisfaction_level) * 100 AS avg_satisfaction,
    AVG(last_evaluation) * 100 AS avg_evaluation
FROM HR_Analytics
GROUP BY Department;











