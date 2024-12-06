-- Query to calculate and display the sizes of various databases in GB
SELECT
    -- Calculate and format the size of the CommServ database in GB
    (SELECT FORMAT(SUM((size * 8.0) / (1024 * 1024)), 'N2') 
     FROM commserv.sys.database_files) AS 'CSDBSize(GB)',
    
    -- Calculate and format the size of the CVCloud database in GB
    (SELECT FORMAT(SUM((size * 8.0) / (1024 * 1024)), 'N2') 
     FROM CVCloud.sys.database_files) AS 'CVCloudDBSize(GB)',
    
    -- Calculate and format the size of the History database in GB
    (SELECT FORMAT(SUM((size * 8.0) / (1024 * 1024)), 'N2') 
     FROM HistoryDB.sys.database_files) AS 'HistoryDBSize(GB)',
    
    -- Calculate and format the size of the Cache database in GB
    (SELECT FORMAT(SUM((size * 8.0) / (1024 * 1024)), 'N2') 
     FROM CacheDB.sys.database_files) AS 'CacheDBSize(GB)',
    
    -- Calculate and format the size of the TempDB in GB
    (SELECT FORMAT(SUM((size * 8.0) / (1024 * 1024)), 'N2') 
     FROM tempdb.sys.database_files) AS 'TempDBSize(GB)'
