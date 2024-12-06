-- Retrieve Q&I (Queue & Indexing) statistics for DDB (SIDB) partitions with significant activity
SELECT 
    B.QIDateTime AS As_of_UTC,  -- The UTC timestamp of the data record
    ss.SIDBStoreName AS 'DDB(SIDBName)',  -- Name of the DDB (SIDB Store)
    CONCAT('[', ac.name, ']', ' ', iss.SIDBSnapPath, ' [ID: ', B.SubStoreId, ']') AS DDBPartition,  -- Partition details, including client name, snapshot path, and SubStore ID
    CONCAT(B.AvgQITime, ' µs (', B.QIPercent, '%)') AS 'Q&I(AvgFor3Days)'  -- Average Queue & Indexing time over 3 days with percentage
FROM (
    -- Subquery to calculate ranking and filter relevant Q&I data
    SELECT 
        SIDBStoreId,  -- DDB Store ID
        SubStoreId,  -- SubStore ID (partition)
        AvgQITime,  -- Average Queue & Indexing time
        QIPercent,  -- Q&I time as a percentage of the threshold
        QIDateTime,  -- UTC timestamp of the record
        ROW_NUMBER() OVER(PARTITION BY SubStoreId ORDER BY AvgQITime DESC) AS qiRank  -- Rank based on AvgQITime per SubStore
    FROM (
        -- Subquery to fetch and rank data by the most recent ModifiedTime
        SELECT 
            SIDBStoreId,  -- DDB Store ID
            substoreId,  -- SubStore ID
            AvgQITime,  -- Average Queue & Indexing time
            FORMAT(DATEADD(s, ModifiedTime, '1970-01-01'), 'yyyy-MM-dd HH:mm:ss') AS QIDateTime,  -- Convert Unix timestamp to readable date format
            DENSE_RANK() OVER(ORDER BY ModifiedTime DESC) AS dateRank,  -- Rank data by ModifiedTime in descending order
            (AvgQITime / 20) AS QIPercent  -- Calculate Q&I time as a percentage of the threshold (20 units assumed)
        FROM IdxSIDBUsageHistory
        WHERE HistoryType = 2  -- Filter for specific history type (2 = relevant data)
    ) A
    WHERE dateRank IN (1, 2, 3)  -- Include only the top 3 most recent records
) B
-- Join to fetch additional details about the DDB partition
JOIN IdxSIDBSubStore iss ON iss.SubStoreId = B.SubStoreId  -- Link SubStore details
JOIN APP_Client ac ON ac.id = iss.ClientId  -- Link client details
JOIN IdxSIDBStore ss ON ss.SIDBStoreId = iss.SIDBStoreId  -- Link DDB Store details
WHERE qiRank = 2 AND QIPercent >= 70  -- Filter for records ranked 2nd and with Q&I percentage >= 70 (Major: >=70%, Critical: >=90%)
