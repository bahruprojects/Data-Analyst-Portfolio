-- Deteksi Duplikat
SELECT 
  Pregnancies, Glucose, BloodPressure, SkinThickness, Insulin, BMI, 
  DiabetesPedigreeFunction, Age, Outcome, COUNT(*) AS dup_count
FROM diabetes
GROUP BY 
  Pregnancies, Glucose, BloodPressure, SkinThickness, Insulin, BMI, 
  DiabetesPedigreeFunction, Age, Outcome
HAVING COUNT(*) > 1;

-- Deteksi Missing Values
SELECT 
  SUM(CASE WHEN Pregnancies IS NULL THEN 1 ELSE 0 END) AS Missing_Pregnancies,
  SUM(CASE WHEN Glucose IS NULL THEN 1 ELSE 0 END) AS Missing_Glucose,
  SUM(CASE WHEN BloodPressure IS NULL THEN 1 ELSE 0 END) AS Missing_BloodPressure,
  SUM(CASE WHEN SkinThickness IS NULL THEN 1 ELSE 0 END) AS Missing_SkinThickness,
  SUM(CASE WHEN Insulin IS NULL THEN 1 ELSE 0 END) AS Missing_Insulin,
  SUM(CASE WHEN BMI IS NULL THEN 1 ELSE 0 END) AS Missing_BMI,
  SUM(CASE WHEN DiabetesPedigreeFunction IS NULL THEN 1 ELSE 0 END) AS Missing_DiabetesPedigreeFunction,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,
  SUM(CASE WHEN Outcome IS NULL THEN 1 ELSE 0 END) AS Missing_Outcome
FROM diabetes;

-- Deteksi Outliers (Contoh untuk kolom Glucose dengan metode IQR)
WITH stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Glucose) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Glucose) AS Q3
  FROM diabetes
)
SELECT d.*
FROM diabetes d, stats s
WHERE d.Glucose < (s.Q1 - 1.5 * (s.Q3 - s.Q1))
   OR d.Glucose > (s.Q3 + 1.5 * (s.Q3 - s.Q1));


-- -- Membuat Tabel Dataset Bersih
-- CREATE TABLE diabetes_cleaned AS
-- SELECT DISTINCT *
-- FROM diabetes
-- WHERE Pregnancies IS NOT NULL
--   AND Glucose IS NOT NULL
--   AND BloodPressure IS NOT NULL
--   AND SkinThickness IS NOT NULL
--   AND Insulin IS NOT NULL
--   AND BMI IS NOT NULL
--   AND DiabetesPedigreeFunction IS NOT NULL
--   AND Age IS NOT NULL
--   AND Outcome IS NOT NULL
--   AND Glucose BETWEEN 
--        (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Glucose) FROM diabetes)
--        - 1.5 * ((SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Glucose) FROM diabetes)
--        - (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Glucose) FROM diabetes))
--    AND
--        (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Glucose) FROM diabetes)
--        + 1.5 * ((SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Glucose) FROM diabetes)
--        - (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Glucose) FROM diabetes));

-- Query untuk Menghitung Metrik
SELECT 
  COUNT(*) AS Total_Participants,
  SUM(CASE WHEN Outcome = 1 THEN 1 ELSE 0 END) AS Total_Patients,
  AVG(Age) AS Average_Age,
  AVG(Glucose) AS Average_Glucose,
  AVG(BMI) AS Average_BMI
FROM diabetes_cleaned;





































































