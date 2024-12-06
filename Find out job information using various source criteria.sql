USE commserv;

-- Select various fields from multiple tables
SELECT 
    (af.jobid) AS "Job #",                        -- Job ID
    (cl.name) AS "Client",                        -- Client Name
    (ag.name) AS "Agent",                         -- Agent Name
    (bs.name) AS "BackupSet",                     -- Backup Set Name
    (sc.subclientname) AS "Subclient",            -- Subclient Name
    (sc.id) AS "SCID",                            -- Subclient ID
    (af.id) AS "AFileID",                         -- Archive File ID
    (sp.name) AS "Storage Policy",                -- Storage Policy Name
    (spc.name) AS "Copy",                         -- Storage Policy Copy
    (cl2.name) AS "MediaAgent",                   -- Media Agent Name
    (lib.aliasname) AS "Library",                 -- Library Alias Name
    (med.barcode) AS "Barcode",                   -- Barcode of the Media
    (mp.mountpathname) AS "MountPath",            -- Mount Path of the Volume
    (vol.volumename) AS "Volume",                 -- Volume Name
    (ch.id) AS "Chunk",                           -- Chunk ID
    (ddb.sidbstoreid) AS "DDB Store",             -- DDB Store ID
    (ddb.status) AS "Store Status"                -- DDB Store Status
FROM 
    archchunkmapping acm                         -- ArchChunkMapping table
LEFT JOIN 
    archchunk ch ON acm.archchunkid = ch.id      -- Join ArchChunk table
LEFT JOIN 
    mmvolume vol ON ch.volumeid = vol.volumeid   -- Join Volume table
LEFT JOIN 
    mmmountpath mp ON vol.mediasideid = mp.mediasideid  -- Join Mount Path table
LEFT JOIN 
    mmmediaside ms ON vol.mediasideid = ms.mediasideid  -- Join Media Side table
LEFT JOIN 
    mmmedia med ON ms.mediaid = med.mediaid      -- Join Media table
LEFT JOIN 
    mmlibrary lib ON med.libraryid = lib.libraryid  -- Join Library table
LEFT JOIN 
    archfile af ON acm.archfileid = af.id        -- Join ArchFile table
LEFT JOIN 
    app_application sc ON af.appid = sc.id       -- Join App Application table (Subclient)
LEFT JOIN 
    mmlibrarycontroller ma ON lib.libraryid = ma.libraryid  -- Join Library Controller table
LEFT JOIN 
    app_client cl2 ON ma.clientid = cl2.id       -- Join Client table for Media Agent
LEFT JOIN 
    archjobsonstoreinfo ddb2j ON af.jobid = ddb2j.jobid  -- Join ArchJob on Store Info table
LEFT JOIN 
    idxsidbstore ddb ON ddb2j.storeid = ddb.sidbstoreid  -- Join DDB Store table
LEFT JOIN 
    archgroup sp ON sc.dataarchgrpid = sp.id      -- Join Archive Group table for Storage Policy
LEFT JOIN 
    archgroupcopy spc ON acm.archcopyid = spc.id -- Join Archive Group Copy table
LEFT JOIN 
    app_backupsetname bs ON sc.backupset = bs.id -- Join Backup Set Name table
LEFT JOIN 
    app_idatype ag ON sc.apptypeid = ag.type     -- Join Agent Type table
LEFT JOIN 
    app_client cl ON sc.clientid = cl.id         -- Join Client table for Backup Info

-- You can filter data by adding a WHERE condition for any of the fields below:

/*** Uncomment and replace the content including the <> brackets for the value you wish to search on  ***/

-- WHERE cl.name LIKE '%<ClientName>%'  -- Filter by Client Name (Use % to match partial names)
-- WHERE cl.id = <ClientID>            -- Filter by Client ID
-- WHERE sc.backupset = <BackupSetID>  -- Filter by Backup Set ID
-- WHERE sc.subclientname LIKE '%<SubClientName>%'  -- Filter by Subclient Name
-- WHERE sc.id = <SubClientID>         -- Filter by Subclient ID
-- WHERE af.jobid = <JobID>            -- Filter by Job ID
-- WHERE af.id = <ArchiveFileID>       -- Filter by Archive File ID
-- WHERE lib.libraryid = <LibraryID>   -- Filter by Library ID
-- WHERE mp.mountpathname LIKE '%<MountPathName>%'  -- Filter by Mount Path Name
-- WHERE vol.volumeid = <VolumeID>     -- Filter by Volume ID
-- WHERE ch.id = <ChunkID>             -- Filter by Chunk ID
-- WHERE med.barcode = '<Barcode>'     -- Filter by Barcode of the Media
-- WHERE ddb.status = <DDBStatus>      -- Filter by DDB Store Status
-- WHERE sp.name LIKE '%<StoragePolicyName>%'  -- Filter by Storage Policy Name
-- WHERE spc.name LIKE '%<StoragePolicyCopyName>%'  -- Filter by Storage Policy Copy Name
