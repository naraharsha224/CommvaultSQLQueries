SELECT DISTINCT
SUBSTRING(af.name, 15, 36) AS 'Index GUID',
jobid,
cl.name 'Media Agent',
bs.name 'backupSet Name',
(SELECT name FROM app_client WHERE id=app.clientid) AS 'Client Name'
FROM archfile af
JOIN App_IndexDBInfo idbi ON idbi.dbName=SUBSTRING(af.name, 15,36)
JOIN APP_Client cl ON idbi.currentIdxServer=cl.id
JOIN APP_BackupSetName bs ON idbi.backupSetId=bs.id
JOIN APP_Application app ON bs.id=app.backupSet
WHERE af.name like 'IdxCheckPoint_%'
--AND SUBSTRING(af.name, 15, 36)='9CDF85C4-XXXX-4FA6-BFD1-937BBD839ADD' --uncomment to search by specific Index GUID
--AND cl.name='CSXXXXDMXX' --uncomment to search by Media Agent
--AND (SELECT name FROM app_client WHERE id=app.clientid)='123456-9876543' --uncomment to search by specific client
ORDER BY jobId
