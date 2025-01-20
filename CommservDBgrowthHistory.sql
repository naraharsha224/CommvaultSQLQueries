--SQL query to retrieve information about the size history of the Commserv database from the cf_SurveyDatabaseSizeHistory table in the CVCloud database.
--We recently faced an issue that CommserveLog size got increased after performing the Commcell Migration which occupied almost the C drive space.

DBCC SQLPERF(logspace) --returns the size of the transaction log and the percentage of space used.
  

USE CVCloud
SELECT *,
       FORMAT(SizeMB/1024.0,'N2') AS sizeGB
FROM cf_SurveyDatabaseSizeHistory
WHERE DatabaseName='Commserv'
ORDER BY LogDate DESC
