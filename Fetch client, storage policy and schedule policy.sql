--I've created this query to do pre and post quality checks while doing Commcell client migrations 

USE commserv;
WITH processedData AS (
SELECT 
        CBSS.clientName,
        CBSS.idaagent,
        CBSS.backupset,
        CBSS.subclient,
        CSP.storagepolicy,
        CBSS.scheduePolicy,
        CBSS.scheduleName,
        CBSS.schedbackuptype,
        CBSS.schedbackupTime,
        ROW_NUMBER() OVER (PARTITION BY CBSS.clientName, CBSS.subclient, schedbackuptype ORDER BY CBSS.schedbackupTime DESC
        ) AS row_num
    FROM CommCellBkScheduleForSubclients CBSS
    JOIN APP_Client C ON C.name = CBSS.clientName
    JOIN APP_ClientGroupAssoc CGA ON C.id = CGA.clientId
    JOIN APP_ClientGroup CG ON CG.id = CGA.clientGroupId
    JOIN CommCellStoragePolicy CSP ON CSP.clientName = C.name
    WHERE CG.name = 'CS803-MoveGroup-Cluster-5' -- Specify the groupName as required
      AND CSP.storagepolicy != 'CV_DEFAULT'
)
SELECT 
    clientName,
    idaagent,
    backupset,
    subclient,
    storagepolicy,
    scheduePolicy,
    scheduleName,
    schedbackuptype,
    schedbackupTime
FROM processedData
WHERE row_num = 1
ORDER BY clientName, subclient;
