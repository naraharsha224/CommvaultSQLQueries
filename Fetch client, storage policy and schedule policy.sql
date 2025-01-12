--I've created this query to do pre and post quality checks while doing Commcell client migrations 

SELECT DISTINCT 
    CBSS.clientName,
    CBSS.idaagent,
    CBSS.backupset,
    CBSS.subclient,
    CSP.storagepolicy,
    CBSS.scheduePolicy,
    CBSS.schedbackuptype,
    CBSS.schedbackupTime
FROM CommCellBkScheduleForSubclients CBSS
INNER JOIN APP_Client C ON C.name = CBSS.clientName
INNER JOIN APP_ClientGroupAssoc CGA ON C.id = CGA.clientId
INNER JOIN APP_ClientGroup CG ON CG.id = CGA.clientGroupId
INNER JOIN CommCellStoragePolicy CSP ON CSP.clientname = C.name
WHERE CG.name = 'CS401-MoveGroup-EverythingElse-02' --Give the groupName as required
      AND CSP.storagepolicy != 'CV_DEFAULT';
