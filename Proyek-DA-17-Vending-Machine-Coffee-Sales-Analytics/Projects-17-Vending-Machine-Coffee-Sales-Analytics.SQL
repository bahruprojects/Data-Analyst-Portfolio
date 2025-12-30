-- Mendeteksi duplikat berdasarkan semua kolom
SELECT date, datetime, cash_type, card, money, coffee_name, COUNT(*) AS cnt
FROM index_data
GROUP BY date, datetime, cash_type, card, money, coffee_name
HAVING COUNT(*) > 1;

-- Mendeteksi missing values
SELECT 
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN datetime IS NULL THEN 1 ELSE 0 END) AS missing_datetime,
    SUM(CASE WHEN cash_type IS NULL THEN 1 ELSE 0 END) AS missing_cash_type,
    SUM(CASE WHEN card IS NULL THEN 1 ELSE 0 END) AS missing_card,
    SUM(CASE WHEN money IS NULL THEN 1 ELSE 0 END) AS missing_money,
    SUM(CASE WHEN coffee_name IS NULL THEN 1 ELSE 0 END) AS missing_coffee_name
FROM index_data;

-- Mendeteksi outlier pada kolom 'money' menggunakan metode IQR
-- Langkah pertama: hitung Q1 dan Q3 (ini biasanya dilakukan di level aplikasi atau dengan subquery)
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY money) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY money) AS Q3
    FROM index_data
)
SELECT i.*
FROM index_data i, stats s
WHERE i.money < (s.Q1 - 1.5*(s.Q3 - s.Q1))
   OR i.money > (s.Q3 + 1.5*(s.Q3 - s.Q1));


-- Membuat tabel baru hasil cleaning
CREATE TABLE index_data_cleaned AS
SELECT * FROM index_data
WHERE date IS NOT NULL
  AND datetime IS NOT NULL
  AND cash_type IS NOT NULL
  AND card IS NOT NULL
  AND money IS NOT NULL
  AND coffee_name IS NOT NULL
  AND money BETWEEN 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY money) - 1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY money) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY money)) FROM index_data)
      AND
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY money) + 1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY money) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY money)) FROM index_data);


-- Query untuk Menampilkan Metrik Terukur
-- Total Jenis Coffee
SELECT COUNT(DISTINCT coffee_name) AS total_jenis_coffee
FROM index_data_cleaned;

-- Total Income
SELECT SUM(money) AS total_income
FROM index_data_cleaned;

-- Total Sales (jumlah baris)
SELECT COUNT(*) AS total_sales
FROM index_data_cleaned;

-- Total Cards (jumlah baris dimana card tidak null)
SELECT COUNT(card) AS total_cards
FROM index_data_cleaned;

-- Income per Year-Month (asumsi kolom datetime dalam format yang bisa dikonversi ke tanggal)
SELECT TO_CHAR(TO_DATE(datetime, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM') AS year_month,
       SUM(money) AS income
FROM index_data_cleaned
GROUP BY TO_CHAR(TO_DATE(datetime, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM')
ORDER BY year_month;

-- Persentase penjualan per jenis coffee
SELECT coffee_name, COUNT(*) AS jumlah_transaksi,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM index_data_cleaned), 2) AS persentase
FROM index_data_cleaned
GROUP BY coffee_name
ORDER BY jumlah_transaksi DESC;

-- Total Income per Jenis Coffee
SELECT coffee_name, SUM(money) AS total_income
FROM index_data_cleaned
GROUP BY coffee_name
ORDER BY total_income DESC;






































































