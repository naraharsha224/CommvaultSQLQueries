--I've created this query to do pre and post quality checks while doing Commcell client migrations 

USE commserv;
WITH AllClients AS (
    -- Step 1:Get all clients in the specified with their iData Agents
    SELECT DISTINCT 
        C.name AS clientName,
        IDA.name AS idataAgent
    FROM APP_Client C
    JOIN APP_ClientGroupAssoc CGA ON C.id = CGA.clientId
    JOIN APP_ClientGroup CG ON CG.id = CGA.clientGroupId
    JOIN APP_Application APP ON APP.clientId = C.id
    JOIN APP_iDAType IDA ON IDA.type = APP.appTypeId
    WHERE CG.name = 'MoveGroup-Cluster-01'
),
SchedulesData AS (
    -- Step 2: Get schedule information
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
        ROW_NUMBER() OVER (
            PARTITION BY CBSS.clientName, CBSS.idaagent, CBSS.subclient, CBSS.schedbackuptype
            ORDER BY CBSS.schedbackupTime DESC
        ) AS row_num
    FROM CommCellBkScheduleForSubclients CBSS
    LEFT JOIN CommCellStoragePolicy CSP ON CBSS.clientName = CSP.clientName
    WHERE CSP.storagepolicy != 'CV_DEFAULT'
)
 
-- Step 3: Combine all clients with their schedules
SELECT 
    AC.clientName,
    AC.idataAgent,
    COALESCE(SD.backupset, 'defaultBackupSet') as backupset,
    COALESCE(SD.subclient, 'default') as subclient,
    SD.storagepolicy,
    SD.scheduePolicy,
    SD.scheduleName,
    SD.schedbackuptype,
    SD.schedbackupTime
FROM AllClients AC
LEFT JOIN SchedulesData SD ON AC.clientName = SD.clientName 
    AND SD.row_num = 1
    AND SD.idaagent = AC.idataAgent  
ORDER BY AC.clientName, AC.idataAgent;
