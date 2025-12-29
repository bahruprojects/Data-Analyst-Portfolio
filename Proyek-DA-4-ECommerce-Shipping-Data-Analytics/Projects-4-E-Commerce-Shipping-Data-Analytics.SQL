-- Query untuk mendeteksi baris duplikat berdasarkan semua kolom
SELECT ID, Warehouse_block, Mode_of_shipment, Customer_care_calls, Customer_rating,
       Cost_of_the_product, Prior_purchases, Product_importance, Gender, Discount_offered,
       Weight_in_gms, Reached_on_time,
       COUNT(*) AS duplicate_count
FROM E_Commerce_Shipping_Data
GROUP BY ID, Warehouse_block, Mode_of_shipment, Customer_care_calls, Customer_rating,
         Cost_of_the_product, Prior_purchases, Product_importance, Gender, Discount_offered,
         Weight_in_gms, Reached_on_time
HAVING COUNT(*) > 1;

-- Deteksi Data Kosong (Missing Values)
SELECT 
    SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS missing_ID,
    SUM(CASE WHEN Warehouse_block IS NULL THEN 1 ELSE 0 END) AS missing_Warehouse_block,
    SUM(CASE WHEN Mode_of_shipment IS NULL THEN 1 ELSE 0 END) AS missing_Mode_of_shipment,
    SUM(CASE WHEN Customer_care_calls IS NULL THEN 1 ELSE 0 END) AS missing_Customer_care_calls,
    SUM(CASE WHEN Customer_rating IS NULL THEN 1 ELSE 0 END) AS missing_Customer_rating,
    SUM(CASE WHEN Cost_of_the_product IS NULL THEN 1 ELSE 0 END) AS missing_Cost_of_the_product,
    SUM(CASE WHEN Prior_purchases IS NULL THEN 1 ELSE 0 END) AS missing_Prior_purchases,
    SUM(CASE WHEN Product_importance IS NULL THEN 1 ELSE 0 END) AS missing_Product_importance,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS missing_Gender,
    SUM(CASE WHEN Discount_offered IS NULL THEN 1 ELSE 0 END) AS missing_Discount_offered,
    SUM(CASE WHEN Weight_in_gms IS NULL THEN 1 ELSE 0 END) AS missing_Weight_in_gms,
    SUM(CASE WHEN Reached_on_time IS NULL THEN 1 ELSE 0 END) AS missing_Reached_on_time
FROM E_Commerce_Shipping_Data;

-- Deteksi Outlier (Contoh pada kolom Cost_of_the_product menggunakan IQR)
WITH bounds AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Cost_of_the_product) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Cost_of_the_product) AS Q3
    FROM E_Commerce_Shipping_Data
)
SELECT *
FROM E_Commerce_Shipping_Data, bounds
WHERE Cost_of_the_product < Q1 - 1.5*(Q3 - Q1)
   OR Cost_of_the_product > Q3 + 1.5*(Q3 - Q1);

-- Menghapus Data Duplikat, Missing Values, dan Outlier
-- Menghapus duplikat: (contoh menggunakan rowid atau primary key, disesuaikan dengan DBMS)
DELETE FROM E_Commerce_Shipping_Data
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM E_Commerce_Shipping_Data
    GROUP BY ID, Warehouse_block, Mode_of_shipment, Customer_care_calls, Customer_rating,
             Cost_of_the_product, Prior_purchases, Product_importance, Gender, Discount_offered,
             Weight_in_gms, Reached_on_time
);

-- Query untuk menghapus data kosong
DELETE FROM E_Commerce_Shipping_Data
WHERE ID IS NULL OR Warehouse_block IS NULL OR Mode_of_shipment IS NULL
      OR Customer_care_calls IS NULL OR Customer_rating IS NULL OR Cost_of_the_product IS NULL
      OR Prior_purchases IS NULL OR Product_importance IS NULL OR Gender IS NULL OR Discount_offered IS NULL
      OR Weight_in_gms IS NULL OR Reached_on_time IS NULL;

-- Query untuk menghapus outlier pada kolom Cost_of_the_product
WITH bounds AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Cost_of_the_product) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Cost_of_the_product) AS Q3
    FROM E_Commerce_Shipping_Data
)
DELETE FROM E_Commerce_Shipping_Data
WHERE Cost_of_the_product < (SELECT Q1 - 1.5*(Q3-Q1) FROM bounds)
   OR Cost_of_the_product > (SELECT Q3 + 1.5*(Q3-Q1) FROM bounds);

-- Menampilkan Metrik Terukur
-- Metrik 1: Total Profit, Rata-rata Rating, dan Total Customer Care Calls
SELECT 
    SUM(Cost_of_the_product) AS Total_Profit,
    AVG(Customer_rating) AS Average_Customer_Rating,
    SUM(Customer_care_calls) AS Total_Customer_Care_Calls
FROM E_Commerce_Shipping_Data;

-- Metrik 2: Distribusi Gender
SELECT Gender, COUNT(*) AS Count_Gender
FROM E_Commerce_Shipping_Data
GROUP BY Gender;

-- Metrik 3: Distribusi Warehouse Block
SELECT Warehouse_block, COUNT(*) AS Count_Warehouse
FROM E_Commerce_Shipping_Data
GROUP BY Warehouse_block;

-- Metrik 4: Distribusi Reached on Time
SELECT Reached_on_time, COUNT(*) AS Count_Reached
FROM E_Commerce_Shipping_Data
GROUP BY Reached_on_time;

-- Metrik 5: Distribusi Mode of Shipment
SELECT Mode_of_shipment, COUNT(*) AS Count_Mode
FROM E_Commerce_Shipping_Data
GROUP BY Mode_of_shipment;

-- Metrik 6: Total Cost per Product Importance
SELECT Product_importance, SUM(Cost_of_the_product) AS Total_Cost
FROM E_Commerce_Shipping_Data
GROUP BY Product_importance;








