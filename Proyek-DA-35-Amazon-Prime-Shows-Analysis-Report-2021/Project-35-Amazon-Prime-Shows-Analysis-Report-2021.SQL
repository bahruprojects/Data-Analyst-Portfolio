-- Deteksi Data Duplikat
SELECT show_id, COUNT(*) AS duplicate_count
FROM amazon_prime_titles
GROUP BY show_id
HAVING COUNT(*) > 1;

-- Deteksi Missing Values. Misalnya, untuk kolom director, cast, country, date_added, dan rating
SELECT 
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_director,
    SUM(CASE WHEN cast IS NULL THEN 1 ELSE 0 END) AS missing_cast,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS missing_date_added,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating
FROM amazon_prime_titles;

-- Deteksi Outlier. Misalnya, untuk kolom release_year
-- Anggap Q1 = 2000 dan Q3 = 2015 sebagai contoh (nilai ini harus disesuaikan dengan data)
SELECT *
FROM amazon_prime_titles
WHERE release_year < (2000 - 1.5 * (2015 - 2000))
   OR release_year > (2015 + 1.5 * (2015 - 2000));

-- Menghapus Duplikat, Missing Values, dan Outlier
-- Buat tabel baru tanpa duplikat, missing values, dan outlier
CREATE TABLE amazon_prime_titles_cleaned AS
SELECT *
FROM amazon_prime_titles
WHERE director IS NOT NULL
  AND cast IS NOT NULL
  AND country IS NOT NULL
  AND date_added IS NOT NULL
  AND rating IS NOT NULL
  AND release_year BETWEEN (2000 - 1.5 * (2015 - 2000)) AND (2015 + 1.5 * (2015 - 2000))
  AND show_id IN (
       SELECT MIN(show_id)
       FROM amazon_prime_titles
       GROUP BY show_id
  );

-- Menampilkan Metrik Terukur
-- Jumlah acara per tipe
SELECT type, COUNT(*) AS jumlah_acara
FROM amazon_prime_titles_cleaned
GROUP BY type;

-- Jumlah acara per tahun
SELECT release_year, COUNT(*) AS jumlah_acara
FROM amazon_prime_titles_cleaned
GROUP BY release_year
ORDER BY release_year;

-- Jumlah acara per negara (perlu memecah data jika ada lebih dari satu negara dalam satu kolom)
-- Untuk penyederhanaan, misal kita hanya hitung berdasarkan isi kolom secara keseluruhan
SELECT country, COUNT(*) AS jumlah_acara
FROM amazon_prime_titles_cleaned
GROUP BY country
ORDER BY jumlah_acara DESC;





































































