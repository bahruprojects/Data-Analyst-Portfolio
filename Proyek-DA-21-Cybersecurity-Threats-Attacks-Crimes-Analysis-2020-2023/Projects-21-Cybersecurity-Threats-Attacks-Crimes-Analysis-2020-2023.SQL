-- Menampilkan baris yang duplikat (berdasarkan seluruh kolom)
SELECT *, COUNT(*) as dup_count
FROM updated_cybersecurity_attacks
GROUP BY Timestamp, Source_IP_Address, Destination_IP_Address, Source_Port, Destination_Port, Protocol, Packet_Length, Packet_Type, Traffic_Type, Payload_Data, Malware_Indicators, Anomaly_Scores, Alerts_Warnings, Attack_Type, Attack_Signature, Action_Taken, Severity_Level, User_Information, Network_Segment, Geo_location_Data, Proxy_Information, Firewall_Logs, IDS_IPS_Alerts, Log_Source, Browser, Device_OS, Year, Month, Day, Hour, Minute, Second, DayOfWeek
HAVING COUNT(*) > 1;

-- Menampilkan jumlah missing values per kolom (misal untuk kolom Source_IP_Address)
SELECT COUNT(*) AS missing_Source_IP_Address
FROM updated_cybersecurity_attacks
WHERE Source_IP_Address IS NULL;

--  Deteksi Outlier (Contoh: Packet_Length menggunakan IQR). Query berikut adalah contoh konseptual; perhitungan IQR biasanya dilakukan di aplikasi layer, namun Anda bisa menggunakan subquery.
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Packet_Length) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Packet_Length) AS Q3
    FROM updated_cybersecurity_attacks
)
SELECT a.*
FROM updated_cybersecurity_attacks a, stats
WHERE a.Packet_Length < (stats.Q1 - 1.5*(stats.Q3 - stats.Q1))
   OR a.Packet_Length > (stats.Q3 + 1.5*(stats.Q3 - stats.Q1));

-- Hapus duplikat dengan cara menyimpan record unik ke tabel baru
CREATE TABLE updated_cybersecurity_attacks_cleaned AS
SELECT DISTINCT *
FROM updated_cybersecurity_attacks
WHERE Source_IP_Address IS NOT NULL
  AND Destination_IP_Address IS NOT NULL;
  
-- Untuk menghapus outlier, misalnya untuk Packet_Length, Anda dapat menyimpan data yang tidak masuk kriteria outlier:
CREATE TABLE updated_cybersecurity_attacks_cleaned AS
WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Packet_Length) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Packet_Length) AS Q3
    FROM updated_cybersecurity_attacks
)
SELECT a.*
FROM updated_cybersecurity_attacks a, stats
WHERE a.Packet_Length BETWEEN (stats.Q1 - 1.5*(stats.Q3 - stats.Q1))
                          AND (stats.Q3 + 1.5*(stats.Q3 - stats.Q1))
  AND a.Source_IP_Address IS NOT NULL
  AND a.Destination_IP_Address IS NOT NULL;

-- Total record sebelum cleaning
SELECT COUNT(*) AS total_record_before FROM updated_cybersecurity_attacks;

-- Total record setelah cleaning
SELECT COUNT(*) AS total_record_after FROM updated_cybersecurity_attacks_cleaned;

-- Metrik 
-- Total Kasus, Total User, Total Lokasi
SELECT 
    COUNT(*) AS total_cases,
    COUNT(DISTINCT User_Information) AS total_users,
    COUNT(DISTINCT Geo_location_Data) AS total_locations
FROM updated_cybersecurity_attacks_cleaned;

-- Distribusi Jenis Serangan (Attack_Type) – untuk pie chart
SELECT Attack_Type, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Attack_Type;

-- Distribusi Traffic Type
SELECT Traffic_Type, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Traffic_Type;

-- Distribusi Severity Level
SELECT Severity_Level, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Severity_Level;

-- Distribusi Protocol, Browser, Log Source, dsb.
SELECT Protocol, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Protocol;

SELECT Browser, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Browser;

SELECT Log_Source, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Log_Source;

-- Distribusi Device/OS dan Top 10 Lokasi Cyberattacks.
SELECT Device_OS, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Device_OS;

SELECT Geo_location_Data, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Geo_location_Data
ORDER BY count DESC
LIMIT 10;

--  Trend Serangan per Tahun (Year vs Count)
SELECT Year, COUNT(*) AS count
FROM updated_cybersecurity_attacks_cleaned
GROUP BY Year
ORDER BY Year;

--  Trend Serangan per Tahun (Year vs Jumlah Serangan sarkan Jenis)
SELECT 
    Year, 
    Attack_Type, 
    COUNT(*) AS Count
FROM updated_cybersecurity_attacks_cleaned
WHERE Attack_Type IN ('Intrusion', 'Malware', 'DDoS')
GROUP BY Year, Attack_Type
ORDER BY Year;



































