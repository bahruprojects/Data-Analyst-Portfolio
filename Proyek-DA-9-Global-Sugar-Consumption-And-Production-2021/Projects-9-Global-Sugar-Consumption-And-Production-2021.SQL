-- Deteksi duplikat
SELECT Country, COUNT(*) AS cnt
FROM sugar_trade
GROUP BY Country
HAVING COUNT(*) > 1;

-- Deteksi missing values
SELECT *
FROM sugar_trade
WHERE Country IS NULL
   OR CONSUMPTION_IN_YEAR_2021 IS NULL
   OR PRODUCTION_IN_YEAR_2021 IS NULL;

-- Deteksi outliers menggunakan metode IQR untuk 'CONSUMPTION_IN_YEAR_2021'
WITH consumption_stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CONSUMPTION_IN_YEAR_2021) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CONSUMPTION_IN_YEAR_2021) AS Q3
    FROM sugar_trade
)
SELECT st.*
FROM sugar_trade st, consumption_stats cs
WHERE st.CONSUMPTION_IN_YEAR_2021 < (cs.Q1 - 1.5 * (cs.Q3 - cs.Q1))
   OR st.CONSUMPTION_IN_YEAR_2021 > (cs.Q3 + 1.5 * (cs.Q3 - cs.Q1));

-- Deteksi outliers untuk 'PRODUCTION_IN_YEAR_2021'
WITH production_stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY PRODUCTION_IN_YEAR_2021) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY PRODUCTION_IN_YEAR_2021) AS Q3
    FROM sugar_trade
)
SELECT st.*
FROM sugar_trade st, production_stats ps
WHERE st.PRODUCTION_IN_YEAR_2021 < (ps.Q1 - 1.5 * (ps.Q3 - ps.Q1))
   OR st.PRODUCTION_IN_YEAR_2021 > (ps.Q3 + 1.5 * (ps.Q3 - ps.Q1));

-- Misalnya, hapus outlier pada consumption
WITH consumption_stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CONSUMPTION_IN_YEAR_2021) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CONSUMPTION_IN_YEAR_2021) AS Q3
    FROM sugar_trade
)
DELETE FROM sugar_trade
WHERE CONSUMPTION_IN_YEAR_2021 < (
    SELECT Q1 - 1.5 * (Q3 - Q1) FROM consumption_stats
)
OR CONSUMPTION_IN_YEAR_2021 > (
    SELECT Q3 + 1.5 * (Q3 - Q1) FROM consumption_stats
);

-- Proses yang sama dapat diterapkan untuk PRODUCTION_IN_YEAR_2021.

-- FULL OUTER JOIN Query untuk Menampilkan Metrik Terukur
SELECT 
    COALESCE(cons.Country, prod.Country) AS Country,
    cons.CONSUMPTION_IN_YEAR_2021,
    prod.PRODUCTION_IN_YEAR_2021
FROM Sugar_World_Trade_CONS AS cons
FULL OUTER JOIN Sugar_World_Trade_PROD AS prod
    ON cons.Country = prod.Country;
