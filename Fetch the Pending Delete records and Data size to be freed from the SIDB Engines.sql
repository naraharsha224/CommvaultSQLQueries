-- Query to retrieve details about SIDBs with pending delete records and significant pruning left
SELECT 
    SIDBStoreName AS 'Name(SIDB)',  -- Name of the SIDB Store
    SIDBStoreId AS 'Id',  -- ID of the SIDB Store
    ModifiedDate AS 'As of(UTC)',  -- UTC timestamp of the last modification
    SUM(ZeroRefCount) AS PendingDeleteRecords,  -- Total count of records marked for deletion (ZeroRefCount)
    FORMAT(SUM(DataSizeToBeFreed), 'N3') AS 'PruningLeft(TB)'  -- Total data size to be freed in TB, formatted to 3 decimal places
FROM (
    -- Subquery to filter and prepare data for aggregation
    SELECT DISTINCT 
        ss.SIDBStoreId,  -- SIDB Store ID
        ss.SIDBStoreName,  -- SIDB Store name
        suh.ZeroRefCount,  -- Count of records marked for deletion
        FORMAT(DATEADD(s, suh.ModifiedTime, '1970-01-01'), 'yyyy-MM-dd HH') AS 'ModifiedDate',  -- Convert Unix timestamp to human-readable format
        (1.0 * (suh.DataSizeToPrune) / (1024 * 1024 * 1024)) / 1024 AS DataSizeToBeFreed,  -- Convert size from bytes to TB
        DENSE_RANK() OVER(PARTITION BY suh.SIDBStoreId ORDER BY FORMAT(DATEADD(s, suh.ModifiedTime, '1970-01-01'), 'yyyy-MM-dd HH') DESC) AS rn  -- Rank records by the most recent modification time
    FROM IdxSIDBUsageHistory suh
    JOIN IdxSIDBStore ss ON ss.SIDBStoreId = suh.SIDBStoreId  -- Join to link usage history with SIDB store details
    WHERE 
        CAST(GETUTCDATE() AS DATE) = CAST(DATEADD(s, suh.ModifiedTime, '1970-01-01') AS DATE)  -- Include records from the current date only
        AND ss.SealedTime = 0  -- Exclude sealed SIDBs
) A
-- Filter results to include only the most recent records and exclude entries with no data to be freed
WHERE rn = 1 AND DataSizeToBeFreed != 0  -- Include only the most recent record per SIDB and non-zero pruning data
GROUP BY SIDBStoreName, SIDBStoreId, ModifiedDate  -- Group data by SIDB name, ID, and modification date
HAVING SUM(DataSizeToBeFreed) > 10  -- Include only SIDBs where the total data size to be freed exceeds 10 TB
ORDER BY ModifiedDate DESC  -- Sort results by the modification date in descending order
