-- Deteksi Data Duplikat
SELECT *, COUNT(*)
FROM sentimentdataset
GROUP BY Text, Sentiment, Timestamp, User, Platform, Hashtags, Likes, Retweets, Country, Year, Month, Day, Hour
HAVING COUNT(*) > 1;

-- Deteksi Missing Values
SELECT COUNT(*) AS Missing_Values
FROM sentimentdataset
WHERE Text IS NULL OR Sentiment IS NULL OR Timestamp IS NULL OR 
      User IS NULL OR Platform IS NULL OR Hashtags IS NULL OR 
      Likes IS NULL OR Retweets IS NULL OR Country IS NULL OR 
      Year IS NULL OR Month IS NULL OR Day IS NULL OR Hour IS NULL;

-- Deteksi Outliers
SELECT *
FROM sentimentdataset
WHERE Likes > (SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Likes) FROM sentimentdataset)
   OR Retweets > (SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Retweets) FROM sentimentdataset);

-- Menghapus Data Duplikat
DELETE FROM sentimentdataset
WHERE id NOT IN (
    SELECT MIN(id)
    FROM sentimentdataset
    GROUP BY Text, Sentiment, Timestamp, User, Platform, Hashtags, Likes, Retweets, Country, Year, Month, Day, Hour
);

-- Menghapus Data dengan Missing Values
DELETE FROM sentimentdataset
WHERE Text IS NULL OR Sentiment IS NULL OR Timestamp IS NULL OR 
      User IS NULL OR Platform IS NULL OR Hashtags IS NULL OR 
      Likes IS NULL OR Retweets IS NULL OR Country IS NULL OR 
      Year IS NULL OR Month IS NULL OR Day IS NULL OR Hour IS NULL;

-- Menghapus Outliers
DELETE FROM sentimentdataset
WHERE Likes > (SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Likes) FROM sentimentdataset)
   OR Retweets > (SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Retweets) FROM sentimentdataset);

-- Total Users
SELECT COUNT(DISTINCT User) AS Total_Users FROM sentimentdataset;

-- Total Countries
SELECT COUNT(DISTINCT Country) AS Total_Countries FROM sentimentdataset;

-- Total Retweets
SELECT SUM(Retweets) AS Total_Retweets FROM sentimentdataset;

-- Total Likes
SELECT SUM(Likes) AS Total_Likes FROM sentimentdataset;

-- Percentages Of Platforms
SELECT Platform, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sentimentdataset) AS Percentage
FROM sentimentdataset
GROUP BY Platform;

-- Type Of Sentiments
SELECT Sentiment, COUNT(*) AS Count
FROM sentimentdataset
GROUP BY Sentiment
ORDER BY Count DESC;

-- Users By Country Origins
SELECT Country, COUNT(DISTINCT User) AS Total_Users
FROM sentimentdataset
GROUP BY Country
ORDER BY Total_Users DESC;

-- Sentiments By Year
SELECT Year, Sentiment, COUNT(*) AS Sentiment_Count
FROM sentimentdataset
GROUP BY Year, Sentiment
ORDER BY Year, Sentiment_Count DESC;
