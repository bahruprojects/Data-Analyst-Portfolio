-- 1. SQL Queries untuk Data Cleaning

-- Mendeteksi data duplikat
SELECT customer_id, COUNT(*) as duplicate_count
FROM bank_customer_churn
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Mendeteksi missing values
SELECT 
    COUNT(*) - COUNT(customer_id) as missing_customer_id,
    COUNT(*) - COUNT(credit_score) as missing_credit_score,
    COUNT(*) - COUNT(country) as missing_country,
    COUNT(*) - COUNT(gender) as missing_gender,
    COUNT(*) - COUNT(age) as missing_age,
    COUNT(*) - COUNT(tenure) as missing_tenure,
    COUNT(*) - COUNT(balance) as missing_balance,
    COUNT(*) - COUNT(products_number) as missing_products_number,
    COUNT(*) - COUNT(credit_card) as missing_credit_card,
    COUNT(*) - COUNT(active_member) as missing_active_member,
    COUNT(*) - COUNT(estimated_salary) as missing_estimated_salary,
    COUNT(*) - COUNT(churn) as missing_churn
FROM bank_customer_churn;

-- Mendeteksi outliers menggunakan metode IQR
WITH stats AS (
    SELECT
        column_name,
        AVG(column_value) as mean,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY column_value) as q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY column_value) as q3
    FROM (
        SELECT 'credit_score' as column_name, credit_score as column_value FROM bank_customer_churn
        UNION ALL
        SELECT 'age', age FROM bank_customer_churn
        UNION ALL
        SELECT 'balance', balance FROM bank_customer_churn
        UNION ALL
        SELECT 'estimated_salary', estimated_salary FROM bank_customer_churn
    ) unpivoted
    GROUP BY column_name
)
SELECT 
    column_name,
    mean,
    q1,
    q3,
    q3 - q1 as iqr,
    q1 - 1.5 * (q3 - q1) as lower_bound,
    q3 + 1.5 * (q3 - q1) as upper_bound
FROM stats;

-- Cleaning data (menghapus duplikat dan missing values)
CREATE TABLE bank_customer_churn_cleaned AS
SELECT DISTINCT *
FROM bank_customer_churn
WHERE customer_id IS NOT NULL
    AND credit_score IS NOT NULL
    AND country IS NOT NULL
    AND gender IS NOT NULL
    AND age IS NOT NULL
    AND tenure IS NOT NULL
    AND balance IS NOT NULL
    AND products_number IS NOT NULL
    AND credit_card IS NOT NULL
    AND active_member IS NOT NULL
    AND estimated_salary IS NOT NULL
    AND churn IS NOT NULL;

-- 2. SQL Queries untuk KPI

-- Churn Rate
SELECT 
    ROUND(AVG(churn) * 100, 2) as churn_rate_percentage
FROM bank_customer_churn_cleaned;

-- Average Credit Score by Churn Status
SELECT 
    churn,
    ROUND(AVG(credit_score), 2) as avg_credit_score
FROM bank_customer_churn_cleaned
GROUP BY churn;

-- Average Balance by Churn Status
SELECT 
    churn,
    ROUND(AVG(balance), 2) as avg_balance
FROM bank_customer_churn_cleaned
GROUP BY churn;

-- Customer Retention Rate
SELECT 
    ROUND((1 - AVG(churn)) * 100, 2) as retention_rate_percentage
FROM bank_customer_churn_cleaned;

-- Product Usage Distribution
SELECT 
    products_number,
    COUNT(*) as customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_customer_churn_cleaned), 2) as percentage
FROM bank_customer_churn_cleaned
GROUP BY products_number
ORDER BY products_number;

-- Active Member Analysis
SELECT 
    active_member,
    COUNT(*) as customer_count,
    ROUND(AVG(churn) * 100, 2) as churn_rate_percentage
FROM bank_customer_churn_cleaned
GROUP BY active_member;

-- Age Group Analysis
SELECT 
    CASE 
        WHEN age < 30 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END as age_group,
    COUNT(*) as customer_count,
    ROUND(AVG(churn) * 100, 2) as churn_rate_percentage
FROM bank_customer_churn_cleaned
GROUP BY 
    CASE 
        WHEN age < 30 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
    END
ORDER BY age_group;


-- 1. Total Customers
SELECT COUNT(*) AS total_customers FROM bank_customer_churn;

-- 2. AVG Credit Score
SELECT AVG(credit_score) AS avg_credit_score FROM bank_customer_churn;

-- 3. AVG Balance
SELECT AVG(balance) AS avg_balance FROM bank_customer_churn;

-- 4. AVG Salary
SELECT AVG(estimated_salary) AS avg_salary FROM bank_customer_churn;

-- 5. Max Salary
SELECT MAX(estimated_salary) AS max_salary FROM bank_customer_churn;

-- 6. Churn Rate Percentage
SELECT 
    (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate_percentage
FROM bank_customer_churn;

-- 7. Customer Based On Gender
SELECT gender, COUNT(*) AS total_customers 
FROM bank_customer_churn 
GROUP BY gender;

-- 8. Country Categorized
SELECT country, COUNT(*) AS total_customers 
FROM bank_customer_churn 
GROUP BY country;

-- 9. Active Member Percentage
SELECT 
    (SUM(CASE WHEN active_member = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS active_member_percentage
FROM bank_customer_churn;

-- 10. Credit Card Percentage
SELECT 
    (SUM(CASE WHEN credit_card = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS credit_card_percentage
FROM bank_customer_churn;

-- 11. Customer Churn Based On Country
SELECT country, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
       COUNT(*) AS total_customers,
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM bank_customer_churn
GROUP BY country
ORDER BY churn_rate DESC;

-- 12. Churn Rate By Gender
SELECT gender, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
       COUNT(*) AS total_customers,
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM bank_customer_churn
GROUP BY gender
ORDER BY churn_rate DESC;

-- 13. Churn Rate By Active Member
SELECT active_member, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
       COUNT(*) AS total_customers,
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM bank_customer_churn
GROUP BY active_member
ORDER BY churn_rate DESC;

-- 14. Korelasi nilai Churn dengan faktor lainnya
SELECT 
    CORR(credit_score, churn) AS credit_score_corr,
    CORR(age, churn) AS age_corr,
    CORR(balance, churn) AS balance_corr,
    CORR(estimated_salary, churn) AS salary_corr,
    CORR(products_number, churn) AS products_corr,
    CORR(tenure, churn) AS tenure_corr
FROM bank_customer_churn;
