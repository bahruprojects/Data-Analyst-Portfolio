-- 1. Mendeteksi duplikat berdasarkan VIN
SELECT VIN, COUNT(*) AS duplicate_count
FROM Electric_Vehicle_Population_Data
GROUP BY VIN
HAVING COUNT(*) > 1;

-- 2. Mendeteksi missing values per kolom
SELECT
    SUM(CASE WHEN VIN IS NULL THEN 1 ELSE 0 END) AS missing_VIN,
    SUM(CASE WHEN County IS NULL THEN 1 ELSE 0 END) AS missing_County,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS missing_City,
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS missing_State,
    SUM(CASE WHEN Postal_Code IS NULL THEN 1 ELSE 0 END) AS missing_Postal_Code,
    SUM(CASE WHEN Model_Year IS NULL THEN 1 ELSE 0 END) AS missing_Model_Year,
    SUM(CASE WHEN Make IS NULL THEN 1 ELSE 0 END) AS missing_Make,
    SUM(CASE WHEN Model IS NULL THEN 1 ELSE 0 END) AS missing_Model,
    SUM(CASE WHEN Electric_Vehicle_Type IS NULL THEN 1 ELSE 0 END) AS missing_Electric_Vehicle_Type,
    SUM(CASE WHEN Clean_Alternative_Fuel_Vehicle_Eligibility IS NULL THEN 1 ELSE 0 END) AS missing_Fuel_Eligibility,
    SUM(CASE WHEN Electric_Range IS NULL THEN 1 ELSE 0 END) AS missing_Electric_Range,
    SUM(CASE WHEN Base_MSRP IS NULL THEN 1 ELSE 0 END) AS missing_Base_MSRP,
    SUM(CASE WHEN Legislative_District IS NULL THEN 1 ELSE 0 END) AS missing_Legislative_District,
    SUM(CASE WHEN DOL_Vehicle_ID IS NULL THEN 1 ELSE 0 END) AS missing_DOL_Vehicle_ID,
    SUM(CASE WHEN Vehicle_Location IS NULL THEN 1 ELSE 0 END) AS missing_Vehicle_Location,
    SUM(CASE WHEN Electric_Utility IS NULL THEN 1 ELSE 0 END) AS missing_Electric_Utility,
    SUM(CASE WHEN "2020_Census_Tract" IS NULL THEN 1 ELSE 0 END) AS missing_2020_Census_Tract
FROM Electric_Vehicle_Population_Data;

-- 3. Mendeteksi outliers untuk kolom Base_MSRP menggunakan metode IQR
WITH quantiles AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Base_MSRP) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Base_MSRP) AS Q3
  FROM Electric_Vehicle_Population_Data
)
SELECT *
FROM Electric_Vehicle_Population_Data, quantiles
WHERE Base_MSRP < (Q1 - 1.5*(Q3-Q1))
   OR Base_MSRP > (Q3 + 1.5*(Q3-Q1));

-- 4. Data Cleaning

-- a. Hapus duplikat (contoh menggunakan CTE dan ROW_NUMBER; sesuaikan dengan DBMS Anda)
WITH CTE AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY VIN ORDER BY VIN) AS rn
  FROM Electric_Vehicle_Population_Data
)
DELETE FROM Electric_Vehicle_Population_Data
WHERE VIN IN (SELECT VIN FROM CTE WHERE rn > 1);

-- b. Hapus baris dengan nilai kosong
DELETE FROM Electric_Vehicle_Population_Data
WHERE VIN IS NULL OR County IS NULL OR City IS NULL OR State IS NULL 
   OR Postal_Code IS NULL OR Model_Year IS NULL OR Make IS NULL OR Model IS NULL 
   OR Electric_Vehicle_Type IS NULL OR Clean_Alternative_Fuel_Vehicle_Eligibility IS NULL 
   OR Electric_Range IS NULL OR Base_MSRP IS NULL OR Legislative_District IS NULL 
   OR DOL_Vehicle_ID IS NULL OR Vehicle_Location IS NULL OR Electric_Utility IS NULL 
   OR "2020_Census_Tract" IS NULL;

-- c. Hapus outliers untuk Base_MSRP (contoh)
WITH quantiles AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Base_MSRP) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Base_MSRP) AS Q3
  FROM Electric_Vehicle_Population_Data
)
DELETE FROM Electric_Vehicle_Population_Data
WHERE Base_MSRP < (
  SELECT Q1 - 1.5*(Q3-Q1) FROM quantiles
)
OR Base_MSRP > (
  SELECT Q3 + 1.5*(Q3-Q1) FROM quantiles
);

-- Untuk membandingkan data sebelum dan sesudah cleaning, catat jumlah baris:
SELECT COUNT(*) AS Total_Rows FROM Electric_Vehicle_Population_Data;

-- 5. Query untuk menampilkan metrik-metrik

SELECT 
  (SELECT COUNT(DISTINCT VIN) FROM Electric_Vehicle_Population_Data) AS Total_Vehicles,
  (SELECT COUNT(DISTINCT City) FROM Electric_Vehicle_Population_Data) AS Total_Cities,
  (SELECT COUNT(DISTINCT Model) FROM Electric_Vehicle_Population_Data) AS Total_Models,
  (SELECT COUNT(DISTINCT Make) FROM Electric_Vehicle_Population_Data) AS Total_Brands,
  (SELECT COUNT(DISTINCT "2020_Census_Tract") FROM Electric_Vehicle_Population_Data) AS Total_Census_Tracks,
  (SELECT COUNT(DISTINCT Vehicle_Location) FROM Electric_Vehicle_Population_Data) AS Total_Locations,
  (SELECT COUNT(DISTINCT State) FROM Electric_Vehicle_Population_Data) AS Total_States;

-- 6. Query untuk visualisasi agregat

-- a. Types Of Vehicles (persentase berdasarkan Electric_Vehicle_Type)
SELECT Electric_Vehicle_Type,
       ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Electric_Vehicle_Population_Data)), 2) AS Percentage
FROM Electric_Vehicle_Population_Data
GROUP BY Electric_Vehicle_Type;

-- b. Top 10 Brand berdasarkan jumlah kendaraan
SELECT Make, COUNT(*) AS Vehicle_Count
FROM Electric_Vehicle_Population_Data
GROUP BY Make
ORDER BY Vehicle_Count DESC
LIMIT 10;

-- c. Top 10 Brand berdasarkan population kendaraan (misal sama dengan count)
SELECT Make, COUNT(*) AS Vehicle_Population
FROM Electric_Vehicle_Population_Data
GROUP BY Make
ORDER BY Vehicle_Population DESC
LIMIT 10;

-- d. Types Of Fuels (persentase berdasarkan Clean_Alternative_Fuel_Vehicle_Eligibility)
SELECT Clean_Alternative_Fuel_Vehicle_Eligibility AS Fuel_Type,
       ROUND( (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Electric_Vehicle_Population_Data)), 2) AS Percentage
FROM Electric_Vehicle_Population_Data
GROUP BY Clean_Alternative_Fuel_Vehicle_Eligibility;

-- e. Jumlah Kendaraan per Tahun (1997-2023)
SELECT Model_Year, COUNT(*) AS Vehicle_Count
FROM Electric_Vehicle_Population_Data
WHERE Model_Year BETWEEN 1997 AND 2023
GROUP BY Model_Year
ORDER BY Model_Year;
