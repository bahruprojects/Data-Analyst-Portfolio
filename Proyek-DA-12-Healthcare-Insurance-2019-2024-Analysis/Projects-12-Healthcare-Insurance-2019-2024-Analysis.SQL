-- Query untuk mendeteksi duplikat (misalnya berdasarkan kombinasi beberapa kolom yang dianggap unik)
SELECT Name, Age, Gender, Blood_Type, Medical_Condition, Date_of_Admission,
       COUNT(*) AS duplicate_count
FROM healthcare_dataset
GROUP BY Name, Age, Gender, Blood_Type, Medical_Condition, Date_of_Admission
HAVING COUNT(*) > 1;

-- Query untuk menghitung missing values per kolom
SELECT 
    SUM(CASE WHEN Name IS NULL THEN 1 ELSE 0 END) AS missing_name,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS missing_gender,
    SUM(CASE WHEN Blood_Type IS NULL THEN 1 ELSE 0 END) AS missing_blood_type,
    SUM(CASE WHEN Medical_Condition IS NULL THEN 1 ELSE 0 END) AS missing_medical_condition,
    SUM(CASE WHEN Date_of_Admission IS NULL THEN 1 ELSE 0 END) AS missing_date_of_admission,
    SUM(CASE WHEN Doctor IS NULL THEN 1 ELSE 0 END) AS missing_doctor,
    SUM(CASE WHEN Hospital IS NULL THEN 1 ELSE 0 END) AS missing_hospital,
    SUM(CASE WHEN Insurance_Provider IS NULL THEN 1 ELSE 0 END) AS missing_insurance_provider,
    SUM(CASE WHEN Billing_Amount IS NULL THEN 1 ELSE 0 END) AS missing_billing_amount,
    SUM(CASE WHEN Room_Number IS NULL THEN 1 ELSE 0 END) AS missing_room_number,
    SUM(CASE WHEN Admission_Type IS NULL THEN 1 ELSE 0 END) AS missing_admission_type,
    SUM(CASE WHEN Discharge_Date IS NULL THEN 1 ELSE 0 END) AS missing_discharge_date,
    SUM(CASE WHEN Medication IS NULL THEN 1 ELSE 0 END) AS missing_medication,
    SUM(CASE WHEN Test_Results IS NULL THEN 1 ELSE 0 END) AS missing_test_results
FROM healthcare_dataset;

-- Deteksi Outliers (Contoh untuk Billing_Amount menggunakan metode IQR)
WITH stats AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Billing_Amount) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Billing_Amount) AS Q3
  FROM healthcare_dataset
)
SELECT t.*
FROM healthcare_dataset t, stats
WHERE t.Billing_Amount < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR t.Billing_Amount > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

--  Query untuk Data Cleaning (Menghapus Duplikat, Missing Values, dan Outliers)
WITH base AS (
  SELECT *
  FROM healthcare_dataset
  WHERE Name IS NOT NULL 
    AND Age IS NOT NULL 
    AND Gender IS NOT NULL
    AND Blood_Type IS NOT NULL 
    AND Medical_Condition IS NOT NULL
    AND Date_of_Admission IS NOT NULL 
    AND Doctor IS NOT NULL
    AND Hospital IS NOT NULL 
    AND Insurance_Provider IS NOT NULL
    AND Billing_Amount IS NOT NULL 
    AND Room_Number IS NOT NULL
    AND Admission_Type IS NOT NULL 
    AND Discharge_Date IS NOT NULL
    AND Medication IS NOT NULL 
    AND Test_Results IS NOT NULL
),
dedup AS (
  SELECT DISTINCT * FROM base
),
stats AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) AS age_Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) AS age_Q3,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Billing_Amount) AS bill_Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Billing_Amount) AS bill_Q3,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Room_Number) AS room_Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Room_Number) AS room_Q3
  FROM dedup
)
SELECT d.*
FROM dedup d, stats
WHERE d.Age BETWEEN (stats.age_Q1 - 1.5 * (stats.age_Q3 - stats.age_Q1))
                AND (stats.age_Q3 + 1.5 * (stats.age_Q3 - stats.age_Q1))
  AND d.Billing_Amount BETWEEN (stats.bill_Q1 - 1.5 * (stats.bill_Q3 - stats.bill_Q1))
                           AND (stats.bill_Q3 + 1.5 * (stats.bill_Q3 - stats.bill_Q1))
  AND d.Room_Number BETWEEN (stats.room_Q1 - 1.5 * (stats.room_Q3 - stats.room_Q1))
                      AND (stats.room_Q3 + 1.5 * (stats.room_Q3 - stats.room_Q1));

-- Jumlah baris sebelum cleaning
SELECT COUNT(*) AS total_rows FROM healthcare_dataset;

-- Jumlah baris setelah cleaning (menggunakan query bersih di atas, misalnya dengan CTE)
WITH cleaned AS (
  -- (Masukkan query cleaning di atas)
  SELECT d.*
  FROM dedup d, stats
  WHERE d.Age BETWEEN (stats.age_Q1 - 1.5 * (stats.age_Q3 - stats.age_Q1))
                  AND (stats.age_Q3 + 1.5 * (stats.age_Q3 - stats.age_Q1))
    AND d.Billing_Amount BETWEEN (stats.bill_Q1 - 1.5 * (stats.bill_Q3 - stats.bill_Q1))
                             AND (stats.bill_Q3 + 1.5 * (stats.bill_Q3 - stats.bill_Q1))
    AND d.Room_Number BETWEEN (stats.room_Q1 - 1.5 * (stats.room_Q3 - stats.room_Q1))
                        AND (stats.room_Q3 + 1.5 * (stats.room_Q3 - stats.room_Q1))
)
SELECT COUNT(*) AS cleaned_rows FROM cleaned;

-- Query untuk Menampilkan Semua Metrik Terukur
SELECT 
    COUNT(*) AS total_patients,
    AVG(Age) AS avg_age,
    MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    AVG(Billing_Amount) AS avg_billing,
    MIN(Billing_Amount) AS min_billing,
    MAX(Billing_Amount) AS max_billing,
    COUNT(DISTINCT Hospital) AS num_hospitals
FROM healthcare_dataset;

-- (Total Patients vs Year-Month Trends)
SELECT 
    DATE_FORMAT(Date_of_Admission, '%Y-%m') AS YearMonth,
    COUNT(*) AS Total_Patients
FROM healthcare_dataset_cleaned
GROUP BY YearMonth
ORDER BY YearMonth;

-- (Gender Distribution Percentages)
SELECT 
    Gender, 
    COUNT(*) AS Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM healthcare_dataset_cleaned), 2) AS Percentage
FROM healthcare_dataset_cleaned
GROUP BY Gender;

-- --  (Top 10 Insurance Providers)
-- SELECT 
--     Insurance_Provider, 
--     COUNT(*) AS Count
-- FROM healthcare_dataset_cleaned
-- GROUP BY Insurance_Provider
-- ORDER BY Count DESC
-- LIMIT 10;

-- -- (Top 10 Most Common Medications)
-- SELECT 
--     Medication, 
--     COUNT(*) AS Count
-- FROM healthcare_dataset_cleaned
-- GROUP BY Medication
-- ORDER BY Count DESC
-- LIMIT 10;

-- (Blood Type Distributions)
SELECT 
    Blood_Type, 
    COUNT(*) AS Count
FROM healthcare_dataset_cleaned
GROUP BY Blood_Type;

-- (Counts vs Age Range)
SELECT 
    CASE 
        WHEN Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN Age BETWEEN 70 AND 79 THEN '70-79'
        WHEN Age BETWEEN 80 AND 89 THEN '80-89'
        WHEN Age >= 90 THEN '90+'
    END AS Age_Range,
    COUNT(*) AS Count
FROM healthcare_dataset_cleaned
GROUP BY Age_Range
ORDER BY Age_Range;




































































