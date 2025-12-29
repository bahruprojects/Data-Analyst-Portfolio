-- Menampilkan baris dengan duplikat berdasarkan kolom unik (misal: Id)
SELECT Id, COUNT(*) AS cnt
FROM credit_risk
GROUP BY Id
HAVING COUNT(*) > 1;

-- Menampilkan jumlah missing values per kolom
SELECT
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_age,
  SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS missing_income,
  SUM(CASE WHEN Emp_length IS NULL THEN 1 ELSE 0 END) AS missing_emp_length,
  SUM(CASE WHEN Rate IS NULL THEN 1 ELSE 0 END) AS missing_rate
FROM credit_risk;

-- Deteksi Outlier (contoh untuk kolom Age dengan metode IQR)
WITH quantiles AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) AS Q3
  FROM credit_risk
)
SELECT *
FROM credit_risk, quantiles
WHERE Age < (Q1 - 1.5 * (Q3 - Q1))
   OR Age > (Q3 + 1.5 * (Q3 - Q1));

-- Jumlah baris sebelum cleaning
SELECT COUNT(*) AS total_before FROM credit_risk;

-- -- Setelah menghapus duplikat, missing, dan outlier pada Age (contoh)
-- -- Proses cleaning biasanya dilakukan di ETL, sehingga query berikut adalah contoh logika filter:
-- SELECT *
-- INTO credit_risk_cleaned
-- FROM credit_risk
-- WHERE Age IS NOT NULL
--   AND Income IS NOT NULL
--   AND Emp_length IS NOT NULL
--   AND Rate IS NOT NULL
--   AND Age BETWEEN (
--         (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) FROM credit_risk)
--           - 1.5 * ((SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) FROM credit_risk)
--           - (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) FROM credit_risk))
--       )
--   AND Age <= (
--         (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) FROM credit_risk)
--           + 1.5 * ((SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Age) FROM credit_risk)
--           - (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Age) FROM credit_risk))
--       );

-- Jumlah baris setelah cleaning
SELECT COUNT(*) AS total_after FROM credit_risk_cleaned;

-- Query untuk menampilkan metrik terukur
SELECT 
  COUNT(*) AS total_applicants,
  AVG(Rate) AS avg_interest_rate,
  AVG(Cred_length) AS avg_credit_history,
  AVG(Income) AS avg_income,
  AVG(Amount) AS avg_amount
FROM credit_risk_cleaned;





































































