-- Deteksi duplikat (berdasarkan kolom NamaNegara, misalnya):
SELECT NamaNegara, COUNT(*) AS jumlah
FROM negara_eropa
GROUP BY NamaNegara
HAVING jumlah > 1;

-- Deteksi missing values (contoh untuk masing-masing kolom):
SELECT *
FROM negara_eropa
WHERE NamaNegara IS NULL
   OR SkorIQ IS NULL
   OR SkorPISA IS NULL
   OR [PendapatanperKapitaUSD] IS NULL
   OR GDP IS NULL
   OR PersentaseStunting IS NULL;

-- Deteksi outlier menggunakan pendekatan sederhana:
-- Misalnya, untuk kolom SkorIQ, hitung Q1 dan Q3 (nilai-nilai tersebut harus dihitung terlebih dahulu)
-- Asumsikan Q1_iq = 90 dan Q3_iq = 110 (contoh), IQR = 20
-- Maka outlier adalah SkorIQ < 90 - 1.5*20 atau > 110 + 1.5*20
SELECT *
FROM negara_eropa
WHERE SkorIQ < (90 - 30) OR SkorIQ > (110 + 30);

-- Hapus duplikat (misalnya, dengan menyimpan baris dengan id terkecil, tergantung struktur tabel)
DELETE FROM negara_eropa
WHERE rowid NOT IN (
  SELECT MIN(rowid)
  FROM negara_eropa
  GROUP BY NamaNegara
);

-- Hapus baris dengan missing values
DELETE FROM negara_eropa
WHERE NamaNegara IS NULL
   OR SkorIQ IS NULL
   OR SkorPISA IS NULL
   OR [PendapatanperKapitaUSD] IS NULL
   OR GDP IS NULL
   OR PersentaseStunting IS NULL;

-- Hapus outlier untuk SkorIQ (contoh):
DELETE FROM negara_eropa
WHERE SkorIQ < (90 - 30) OR SkorIQ > (110 + 30);

-- Sebelum cleaning (misalnya, simpan hasil awal ke tabel sementara atau hitung sebelum DELETE)
SELECT COUNT(*) AS Total_Sebelum FROM negara_europa_backup;

-- Setelah cleaning:
SELECT COUNT(*) AS Total_Sesudah FROM negara_eropa;

-- Query untuk Menampilkan Metrik Terukur
-- Average GDP, IQ Score, dan Capita Income
SELECT 
    AVG(GDP) AS Avg_GDP,
    AVG(SkorIQ) AS Avg_IQ,
    AVG([PendapatanperKapitaUSD]) AS Avg_CapitaIncome
FROM negara_eropa;

-- Negara dengan GDP tertinggi
SELECT NamaNegara, GDP
FROM negara_eropa
ORDER BY GDP DESC
LIMIT 1;

-- Negara dengan IQ tertinggi
SELECT NamaNegara, SkorIQ
FROM negara_eropa
ORDER BY SkorIQ DESC
LIMIT 1;

-- Negara dengan Capita Income tertinggi
SELECT NamaNegara, [PendapatanperKapitaUSD]
FROM negara_eropa
ORDER BY [PendapatanperKapitaUSD] DESC
LIMIT 1;





































































