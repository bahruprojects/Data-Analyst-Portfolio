-- Mendeteksi Data Duplikat
SELECT date, price, percentChange, change, COUNT(*) AS count_duplicates
FROM crude_oil_price
GROUP BY date, price, percentChange, change
HAVING COUNT(*) > 1;

-- Mendeteksi Missing Values
SELECT 
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN percentChange IS NULL THEN 1 ELSE 0 END) AS missing_percentChange,
    SUM(CASE WHEN change IS NULL THEN 1 ELSE 0 END) AS missing_change
FROM crude_oil_price;

-- Mendeteksi Outliers (Menggunakan IQR untuk kolom price)
WITH stats AS (
    SELECT 
        percentile_cont(0.25) WITHIN GROUP (ORDER BY price) AS q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY price) AS q3
    FROM crude_oil_price
),
data_with_stats AS (
    SELECT 
        c.*,
        s.q1, s.q3,
        (s.q3 - s.q1) AS iqr
    FROM crude_oil_price c, stats s
)
SELECT *
FROM data_with_stats
WHERE price < (q1 - 1.5 * iqr) OR price > (q3 + 1.5 * iqr);

 -- Melakukan Data Cleaning (Menghapus Duplikat, Missing Values, dan Outliers)
 -- Hapus Duplikat :
DELETE FROM crude_oil_price a
USING crude_oil_price b
WHERE a.ctid < b.ctid
  AND a.date = b.date
  AND a.price = b.price
  AND a.percentChange = b.percentChange
  AND a.change = b.change;
--Hapus Missing Values :
DELETE FROM crude_oil_price
WHERE date IS NULL OR price IS NULL OR percentChange IS NULL OR change IS NULL;
-- Hapus Outliers (Kolom price)
WITH stats AS (
    SELECT 
        percentile_cont(0.25) WITHIN GROUP (ORDER BY price) AS q1,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY price) AS q3
    FROM crude_oil_price
),
data_with_stats AS (
    SELECT 
        c.*,
        s.q1, s.q3,
        (s.q3 - s.q1) AS iqr
    FROM crude_oil_price c, stats s
)
DELETE FROM crude_oil_price
WHERE price < ((SELECT q1 FROM stats) - 1.5 * (SELECT q3 - q1 FROM stats))
   OR price > ((SELECT q3 FROM stats) + 1.5 * (SELECT q3 - q1 FROM stats));


-- Sebelum Cleaning (misal, jika Anda memiliki log atau backup tabel)
SELECT COUNT(*) AS total_records_before FROM crude_oil_price_backup;

-- Sesudah Cleaning
SELECT COUNT(*) AS total_records_after FROM crude_oil_price;

SELECT 
    MIN(price) AS lowest_price,
    MAX(price) AS highest_price,
    AVG(price) AS average_price,
    MAX(change) AS highest_change
FROM crude_oil_price;



