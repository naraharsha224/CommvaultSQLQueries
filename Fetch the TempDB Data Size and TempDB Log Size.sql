-- Query to calculate the size of TempDB and TempLog files in GB
SELECT 
    name AS DBName,  -- Name of the database file (TempDB or TempLog)
    CAST((SUM(((size * 8) / 1024.0)) / 1024.0) AS DECIMAL(10,2)) AS SizeInGB  -- Size in GB, rounded to 2 decimal places
FROM 
    tempdb.sys.database_files  -- System view to retrieve database file information for TempDB
WHERE 
    type IN (0, 1)  -- Filter: 0 for data files (TempDB), 1 for log files (TempLog)
GROUP BY 
    type,  -- Group by type to differentiate data and log files
    name   -- Group by file name to get size details for each specific file
