-- Mendeteksi baris duplikat berdasarkan semua kolom
SELECT age, sex, bmi, children, smoker, region, charges, COUNT(*) AS dup_count
FROM insurance
GROUP BY age, sex, bmi, children, smoker, region, charges
HAVING COUNT(*) > 1;

-- Mendeteksi baris yang memiliki nilai kosong pada salah satu kolom
SELECT *
FROM insurance
WHERE age IS NULL OR sex IS NULL OR bmi IS NULL OR children IS NULL OR smoker IS NULL OR region IS NULL OR charges IS NULL;

-- Deteksi Outlier (Contoh pada kolom charges)
SELECT *
FROM insurance
WHERE charges > (SELECT AVG(charges) + 2 * STDDEV(charges) FROM insurance)
   OR charges < (SELECT AVG(charges) - 2 * STDDEV(charges) FROM insurance);

-- Menghapus duplikat (menyimpan satu instance saja)
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY age, sex, bmi, children, smoker, region, charges ORDER BY (SELECT 0)) AS rn
    FROM insurance
)
DELETE FROM CTE WHERE rn > 1;

-- Menghapus baris dengan nilai kosong
DELETE FROM insurance
WHERE age IS NULL OR sex IS NULL OR bmi IS NULL OR children IS NULL OR smoker IS NULL OR region IS NULL OR charges IS NULL;

-- Menghapus outlier pada kolom charges
DELETE FROM insurance
WHERE charges > (SELECT AVG(charges) + 2 * STDDEV(charges) FROM insurance)
   OR charges < (SELECT AVG(charges) - 2 * STDDEV(charges) FROM insurance);

-- Metrik data asli
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT age, sex, bmi, children, smoker, region, charges) AS unique_records
FROM insurance_raw;

-- Metrik data setelah cleaning
SELECT COUNT(*) AS total_records,
       COUNT(DISTINCT age, sex, bmi, children, smoker, region, charges) AS unique_records
FROM insurance_cleaned;

-- Query untuk Menghitung Metrik-Metrik Utama
-- Total Unique ID (dengan menggabungkan kolom sebagai identifier)
SELECT COUNT(DISTINCT CONCAT(age, '-', sex, '-', bmi, '-', children, '-', smoker, '-', region, '-', charges)) AS total_unique_id
FROM insurance;

-- Total ID (COUNT)
SELECT COUNT(*) AS total_id FROM insurance;

-- Total Charges (SUM)
SELECT SUM(charges) AS total_charges FROM insurance;

-- Highest Charges
SELECT MAX(charges) AS highest_charges FROM insurance;

-- Average Charges
SELECT AVG(charges) AS average_charges FROM insurance;

-- Average BMI
SELECT AVG(bmi) AS average_bmi FROM insurance;

-- Average Age
SELECT AVG(age) AS average_age FROM insurance;

-- Query untuk Visualisasi Berdasarkan Kelompok
-- Pie Chart: Persentase berdasarkan Gender
SELECT sex, COUNT(*) AS count
FROM insurance
GROUP BY sex;

-- Bar Chart: Jumlah ID vs Children
SELECT children, COUNT(*) AS count
FROM insurance
GROUP BY children
ORDER BY children;

-- Bar Chart: Jumlah ID vs Umur dengan Kelompok Umur
SELECT
    CASE 
        WHEN age < 20 THEN '0-20'
        WHEN age >= 20 AND age < 30 THEN '20-30'
        WHEN age >= 40 AND age < 50 THEN '40-50'
        WHEN age >= 50 THEN '50-100'
        ELSE '30-40'
    END AS age_group,
    COUNT(*) AS count
FROM insurance
GROUP BY age_group;

-- Pie Chart: Persentase Status Merokok
SELECT smoker, COUNT(*) AS count
FROM insurance
GROUP BY smoker;





































































