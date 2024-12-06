-- Query to retrieve jobs that have been running for more than a specified number of days
SELECT 
    jobid,  -- Job ID
    client_name,  -- Client name associated with the job
    jobstartDate,  -- Job start date
    currentPhaseName AS 'phaseName(current)',  -- Current phase name of the job
    DATEDIFF(DAY, JobStartDate, CurrentDate) AS runningDays  -- Number of days the job has been running
FROM (
    -- Subquery to fetch job details including start date and current phase
    SELECT 
        ji.jobid,  -- Job ID
        ac.name AS client_name,  -- Client name (from APP_Client table)
        FORMAT(DATEADD(s, ji.jobStartTime, '1970-01-01'), 'yyyy-MM-dd') AS 'JobstartDate',  -- Job start date in yyyy-MM-dd format
        CAST(GETUTCDATE() AS DATE) AS 'CurrentDate',  -- Current date (UTC)
        ji.currentPhaseName  -- Current phase name of the job
    FROM 
        JMJobInfo ji  -- Job information table
    JOIN 
        JMBkpJobInfo jbi ON jbi.jobId = ji.jobId  -- Join to get job info details
    JOIN 
        APP_Application aa ON jbi.applicationId = aa.id  -- Join to associate the job with its application
    JOIN 
        APP_Client ac ON aa.clientId = ac.id  -- Join to associate the application with its client
) A
WHERE 
    DATEDIFF(DAY, JobStartDate, CurrentDate) >= 5  -- Filter to show only jobs running for 5 or more days (can adjust the value as needed)
