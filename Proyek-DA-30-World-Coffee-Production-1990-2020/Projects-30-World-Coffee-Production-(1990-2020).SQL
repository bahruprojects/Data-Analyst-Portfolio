-- Mendeteksi Duplikat
SELECT Country, `Coffee type`, COUNT(*) AS count_duplikat
FROM coffee_production
GROUP BY Country, `Coffee type`
HAVING COUNT(*) > 1;

-- Mendeteksi Missing Values
SELECT *
FROM coffee_production
WHERE Country IS NULL
   OR `Coffee type` IS NULL OR `1990/91` IS NULL
   OR `1991/92` IS NULL OR `1992/93` IS NULL OR `1993/94` IS NULL
   OR `1994/95` IS NULL OR `1995/96` IS NULL OR `1997/98` IS NULL OR `1998/99` IS NULL
;

-- Mendeteksi Outlier (Contoh untuk kolom 2000/01 menggunakan metode IQR)
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY `2000/01`) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY `2000/01`) AS Q3
    FROM coffee_production
)
SELECT cp.*
FROM coffee_production cp, stats
WHERE cp.`2000/01` < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR cp.`2000/01` > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

-- Query untuk Melakukan Data Cleaning (hapus duplikat, missing values, outliers – contoh untuk kolom 2000/01)
DELETE FROM coffee_production
WHERE id IN (
    SELECT id FROM (
        SELECT id,
            ROW_NUMBER() OVER (PARTITION BY Country, `Coffee type` ORDER BY id) AS rn
        FROM coffee_production
    ) AS t
    WHERE rn > 1
)
OR Country IS NULL
OR `Coffee type` IS NULL
OR `2000/01` IS NULL
OR `2000/01` < (
    SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY `2000/01`)
           - 1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY `2000/01`)
           - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY `2000/01`))
    FROM coffee_production
)
OR `2000/01` > (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY `2000/01`)
           + 1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY `2000/01`)
           - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY `2000/01`))
    FROM coffee_production
);

-- Query SQL untuk Menampilkan Metrik Terukur
SELECT 
    SUM(`Total_production`) AS Total_Global_Production,
    AVG(`Total_production`) AS Rata_Rata_Produksi,
    MIN(`Total_production`) AS Produksi_Minimum,
    MAX(`Total_production`) AS Produksi_Maksimum
FROM coffee_production;



































































