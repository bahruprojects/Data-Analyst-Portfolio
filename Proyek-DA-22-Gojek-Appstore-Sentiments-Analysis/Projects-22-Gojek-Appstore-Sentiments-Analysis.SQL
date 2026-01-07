-- 1. Mendeteksi baris duplikat berdasarkan semua kolom (date, review, rating, title)
SELECT date, review, rating, title, COUNT(*) AS cnt
FROM AppStoreGojekReviews
GROUP BY date, review, rating, title
HAVING COUNT(*) > 1;

-- 2. Mendeteksi baris dengan missing values
SELECT *
FROM AppStoreGojekReviews
WHERE date IS NULL 
   OR review IS NULL 
   OR rating IS NULL 
   OR title IS NULL;

-- 3. Mendeteksi outlier pada rating (misal, rating di luar rentang 1-5)
SELECT *
FROM AppStoreGojekReviews
WHERE rating < 1 OR rating > 5;

-- 4. Membuat tabel baru yang sudah dibersihkan (tanpa duplikat, missing values, dan outlier)
CREATE TABLE AppStoreGojekReviews_Cleaned AS
SELECT DISTINCT *
FROM AppStoreGojekReviews
WHERE date IS NOT NULL 
  AND review IS NOT NULL 
  AND rating IS NOT NULL 
  AND title IS NOT NULL
  AND rating BETWEEN 1 AND 5;

-- 5. Membandingkan jumlah record sebelum dan sesudah cleaning
SELECT 'Sebelum Cleaning' AS Data_Status, COUNT(*) AS Record_Count FROM AppStoreGojekReviews
UNION ALL
SELECT 'Setelah Cleaning' AS Data_Status, COUNT(*) AS Record_Count FROM AppStoreGojekReviews_Cleaned;

-- 6. Menampilkan metrik

-- Total Reviews
SELECT COUNT(*) AS Total_Reviews
FROM AppStoreGojekReviews_Cleaned;

-- Rata-rata Rating
SELECT AVG(rating) AS Average_Rating
FROM AppStoreGojekReviews_Cleaned;

-- Persentase tiap rating (untuk pie chart)
SELECT rating, COUNT(*) AS Count, 
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM AppStoreGojekReviews_Cleaned), 2) AS Percentage
FROM AppStoreGojekReviews_Cleaned
GROUP BY rating;

-- Distribusi Sentimen (misal: rating <=2 = Negative, rating = 3 = Neutral, rating >=4 = Positive)
SELECT 
    CASE 
        WHEN rating <= 2 THEN 'Negative'
        WHEN rating = 3 THEN 'Neutral'
        WHEN rating >= 4 THEN 'Positive'
    END AS Sentiment,
    COUNT(*) AS Count
FROM AppStoreGojekReviews_Cleaned
GROUP BY Sentiment;

-- Jumlah Review per Tanggal
SELECT date, COUNT(*) AS Review_Count
FROM AppStoreGojekReviews_Cleaned
GROUP BY date
ORDER BY date;
