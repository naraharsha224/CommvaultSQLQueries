-- Query to retrieve details of the most recent maintenance job, including its duration
SELECT 
    JobId,  -- Job ID of the maintenance operation
    DName,  -- Descriptive name of the job (likely maintenance operation name)
    status,  -- Status of the job (e.g., Completed, Failed, etc.)
    StartTime,  -- Start time of the job in readable format
    TimeEnd,  -- End time of the job in readable format
    CONVERT(varchar(8), DATEADD(second, DATEDIFF(second, StartTime, TimeEnd), '00:00:00'), 108) AS TimeTaken  -- Time taken for the job in HH:mm:ss format
FROM (
    -- Subquery to fetch and rank maintenance jobs
    SELECT 
        jt.jobId AS JobId,  -- Job ID
        jt.otherOpName AS DName,  -- Name or description of the job
        jn.stateName AS status,  -- Status of the job
        FORMAT(DATEADD(s, jt.servStart, '1970-01-01'), 'yyyy-MM-dd HH:mm:ss') AS StartTime,  -- Convert Unix timestamp for start time
        FORMAT(DATEADD(s, jt.servEnd, '1970-01-01'), 'yyyy-MM-dd HH:mm:ss') AS TimeEnd,  -- Convert Unix timestamp for end time
        DENSE_RANK() OVER (ORDER BY FORMAT(DATEADD(s, jt.servStart, '1970-01-01'), 'yyyy-MM-dd HH:mm:ss') DESC) AS rn  -- Rank jobs by most recent start time
    FROM JMAdminJobStatsTable jt
    JOIN JMJobStatusNames jn ON jt.status = jn.stateType  -- Join to get the job status name
    WHERE 
        jt.opType = 90  -- Filter for operation type corresponding to maintenance jobs
        AND jt.otherOpName LIKE '%maintenance%'  -- Further filter for jobs with "maintenance" in their description
) A
WHERE rn = 1  -- Keep only the most recent maintenance job
