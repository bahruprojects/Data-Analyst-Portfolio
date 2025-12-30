-- Mendeteksi baris duplikat berdasarkan semua kolom
SELECT 
    gender, age, hypertension, heart_disease, ever_married, work_type, Residence_type, avg_glucose_level, bmi, smoking_status, stroke,
    COUNT(*) AS duplicate_count
FROM brain_stroke
GROUP BY gender, age, hypertension, heart_disease, ever_married, work_type, Residence_type, avg_glucose_level, bmi, smoking_status, stroke
HAVING COUNT(*) > 1;

-- Menghitung missing values untuk tiap kolom
SELECT
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN hypertension IS NULL THEN 1 ELSE 0 END) AS missing_hypertension,
    SUM(CASE WHEN heart_disease IS NULL THEN 1 ELSE 0 END) AS missing_heart_disease,
    SUM(CASE WHEN ever_married IS NULL THEN 1 ELSE 0 END) AS missing_ever_married,
    SUM(CASE WHEN work_type IS NULL THEN 1 ELSE 0 END) AS missing_work_type,
    SUM(CASE WHEN Residence_type IS NULL THEN 1 ELSE 0 END) AS missing_residence_type,
    SUM(CASE WHEN avg_glucose_level IS NULL THEN 1 ELSE 0 END) AS missing_avg_glucose_level,
    SUM(CASE WHEN bmi IS NULL THEN 1 ELSE 0 END) AS missing_bmi,
    SUM(CASE WHEN smoking_status IS NULL THEN 1 ELSE 0 END) AS missing_smoking_status,
    SUM(CASE WHEN stroke IS NULL THEN 1 ELSE 0 END) AS missing_stroke
FROM brain_stroke;

-- Mendeteksi Outlier (Contoh untuk kolom age menggunakan metode IQR)
WITH age_stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY age) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY age) AS Q3
  FROM brain_stroke
)
SELECT *
FROM brain_stroke, age_stats
WHERE age < Q1 - 1.5*(Q3 - Q1) OR age > Q3 + 1.5*(Q3 - Q1);

-- Data Cleaning (Menghapus Duplikat & Missing Values)
WITH CTE AS (
  SELECT *,
         ROW_NUMBER() OVER(PARTITION BY gender, age, hypertension, heart_disease, ever_married, work_type, Residence_type, avg_glucose_level, bmi, smoking_status, stroke ORDER BY (SELECT 0)) AS rn
  FROM brain_stroke
)
DELETE FROM CTE WHERE rn > 1;

-- Hapus baris dengan missing values
DELETE FROM brain_stroke
WHERE gender IS NULL OR age IS NULL OR hypertension IS NULL OR heart_disease IS NULL
   OR ever_married IS NULL OR work_type IS NULL OR Residence_type IS NULL
   OR avg_glucose_level IS NULL OR bmi IS NULL OR smoking_status IS NULL OR stroke IS NULL;

-- Menampilkan Metrik Utama
SELECT 
  COUNT(*) AS total_people,
  SUM(stroke) AS stroke_records,
  SUM(heart_disease) AS heart_disease_records,
  SUM(hypertension) AS hypertension_records,
  AVG(bmi) AS avg_bmi,
  AVG(avg_glucose_level) AS avg_glucose_level
FROM brain_stroke;






































































