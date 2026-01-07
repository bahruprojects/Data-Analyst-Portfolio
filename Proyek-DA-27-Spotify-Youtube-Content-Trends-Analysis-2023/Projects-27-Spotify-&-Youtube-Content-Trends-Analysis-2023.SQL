-- Menampilkan baris yang duplikat berdasarkan kombinasi kolom yang dianggap unik (misal: Track dan Artist)
SELECT Track, Artist, COUNT(*) AS duplicate_count
FROM spotify_youtube
GROUP BY Track, Artist
HAVING COUNT(*) > 1;

-- Query untuk menghitung jumlah nilai kosong di beberapa kolom
SELECT 
    SUM(CASE WHEN Track IS NULL THEN 1 ELSE 0 END) AS missing_track,
    SUM(CASE WHEN Artist IS NULL THEN 1 ELSE 0 END) AS missing_artist,
    SUM(CASE WHEN Album IS NULL THEN 1 ELSE 0 END) AS missing_album,
    SUM(CASE WHEN Channel IS NULL THEN 1 ELSE 0 END) AS missing_channel
FROM spotify_youtube;

-- Query untuk Mendeteksi Outliers (Kolom Views)
WITH stats AS (
  SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Views) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Views) AS Q3
  FROM spotify_youtube
)
SELECT sy.*
FROM spotify_youtube sy, stats s
WHERE sy.Views < s.Q1 - 1.5 * (s.Q3 - s.Q1)
   OR sy.Views > s.Q3 + 1.5 * (s.Q3 - s.Q1);

-- Query untuk Menghapus Duplikat
-- WITH cte AS (
--     SELECT *,
--            ROW_NUMBER() OVER (PARTITION BY Track, Artist ORDER BY (SELECT NULL)) AS rn
--     FROM spotify_youtube
-- )
-- DELETE FROM spotify_youtube
-- WHERE (Track, Artist) IN (
--     SELECT Track, Artist
--     FROM cte
--     WHERE rn > 1
-- );

--Query untuk Menampilkan Semua Metrik Terukur
SELECT 
    COUNT(*) AS Total_Contents,
    COUNT(DISTINCT Artist) AS Total_Artists,
    COUNT(DISTINCT Album) AS Total_Albums,
    COUNT(DISTINCT Channel) AS Total_Channels,
    SUM(Likes) AS Total_Likes,
    SUM(Comments) AS Total_Comments
FROM spotify_youtube;






































































