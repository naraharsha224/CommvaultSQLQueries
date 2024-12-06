-- Query to retrieve details about DDB backups, including last backup time, duration, and state
SELECT DISTINCT 
    ac.name AS DDBName,  -- Name of the DDB (SIDB client)
    iss.LastSnapJobId AS JobId,  -- ID of the last snapshot job
    FORMAT(DATEADD(s, iss.LastSnapTime, '1970-01-01'), 'yyyy-MM-dd HH:mm:ss') AS LastBackupTime,  -- Last backup time converted to readable format
    FORMAT(DATEADD(s, js.duration, '00:00:00'), 'HH:mm:ss') AS TimeTaken,  -- Duration of the backup in HH:mm:ss format
    jn.stateName  -- State of the job (e.g., Completed, Failed, etc.)
FROM idxsidbsubstore iss
-- Join with APP_CLIENT to get the name of the DDB
JOIN APP_CLIENT ac ON ac.id = iss.ClientID
-- Join with JMBKPStats to get job details, such as duration
JOIN JMBKPStats js ON js.jobId = iss.LastSnapJobId
-- Join with JMJobStatusNames to get the job state name
JOIN JMJobStatusNames jn ON jn.stateType = js.status
-- Order results by the last backup time in ascending order
ORDER BY LastBackupTime
