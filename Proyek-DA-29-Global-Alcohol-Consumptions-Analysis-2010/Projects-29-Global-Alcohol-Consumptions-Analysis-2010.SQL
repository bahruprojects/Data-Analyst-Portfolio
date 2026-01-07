-- Deteksi Duplikat (berdasarkan semua kolom)
SELECT country, beer_servings, spirit_servings, wine_servings, total_litres_of_pure_alcohol, COUNT(*) AS cnt
FROM drinks
GROUP BY country, beer_servings, spirit_servings, wine_servings, total_litres_of_pure_alcohol
HAVING COUNT(*) > 1;

-- Deteksi Missing Values
SELECT *
FROM drinks
WHERE country IS NULL
   OR beer_servings IS NULL
   OR spirit_servings IS NULL
   OR wine_servings IS NULL
   OR total_litres_of_pure_alcohol IS NULL;

-- Deteksi Outliers (Contoh untuk beer_servings menggunakan metode IQR)
WITH stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY beer_servings) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY beer_servings) AS Q3
  FROM drinks
)
SELECT d.*
FROM drinks d, stats s
WHERE d.beer_servings < s.Q1 - 1.5 * (s.Q3 - s.Q1)
   OR d.beer_servings > s.Q3 + 1.5 * (s.Q3 - s.Q1);

-- Query Data Cleaning (Contoh: membuat tabel baru hasil cleaning)
CREATE TABLE drinks_cleaned AS
SELECT DISTINCT *
FROM drinks
WHERE country IS NOT NULL
  AND beer_servings IS NOT NULL
  AND spirit_servings IS NOT NULL
  AND wine_servings IS NOT NULL
  AND total_litres_of_pure_alcohol IS NOT NULL
  -- Contoh penghapusan outlier untuk beer_servings:
  AND beer_servings BETWEEN 
      (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY beer_servings) FROM drinks)
      - 1.5 * ((SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY beer_servings) FROM drinks)
               - (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY beer_servings) FROM drinks))
  AND beer_servings <= 
      (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY beer_servings) FROM drinks)
      + 1.5 * ((SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY beer_servings) FROM drinks) - (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY beer_servings) FROM drinks));


-- Query untuk Menampilkan Metrik Terukur
SELECT 
  SUM(beer_servings) AS total_beer_servings,
  SUM(wine_servings) AS total_wine_servings,
  SUM(spirit_servings) AS total_spirit_servings,
  SUM(total_litres_of_pure_alcohol) AS total_alcohol,
  COUNT(DISTINCT country) AS total_countries
FROM drinks;

-- Top 20 Beer Servings by Country
SELECT country, beer_servings
FROM drinks
ORDER BY beer_servings DESC
LIMIT 20;

-- Top 20 Wine Servings by Country
SELECT country, wine_servings
FROM drinks
ORDER BY wine_servings DESC
LIMIT 20;

-- Top 20 Spirit Servings by Country
SELECT country, spirit_servings
FROM drinks
ORDER BY spirit_servings DESC
LIMIT 20;

-- Top 20 Pure Alcohol by Country
SELECT country, total_litres_of_pure_alcohol
FROM drinks
ORDER BY total_litres_of_pure_alcohol DESC
LIMIT 20;




































































