-- Selecting information about storage policies, copies, libraries, and volume details
SELECT  
    IdxSIDBStore.sidbstoreid AS sidbstoreid,              -- SIDB Store ID
    IdxSIDBStore.SIDBStoreAliasName,                       -- SIDB Store Alias Name
    archGroup.name AS [Storage Policy],                    -- Storage Policy Name
    archGroupCOpy.name AS [Copy],                          -- Copy of the Storage Policy
    MMLibrary.AliasName AS Library,                        -- Library Alias Name
    MMS2getMountPathNameGUIView.MountPathName AS MountPathName, -- Mount Path Name
    COUNT(*) AS VolumeCount,                               -- Count of Volumes
    SUM(PhysicalBytesMB / (1024.0 * 1024.0)) AS PhysicalBytesTB -- Total Physical Bytes in TB (converted from MB)
FROM 
    [commserv].[dbo].[MMVolume]                             -- The MMVolume table containing volume information
JOIN 
    MMS2getMountPathNameGUIView ON MMVolume.MediaSideId = MMS2getMountPathNameGUIView.MediaSideId  -- Join to get mount path information
JOIN 
    MMLibrary ON MMS2getMountPathNameGUIView.LibraryId = MMLibrary.LibraryId -- Join to get Library details
JOIN 
    IdxSIDBStore ON MMVolume.SIDBStoreId = IdxSIDBStore.SIDBStoreId  -- Join to get SIDB Store details
JOIN 
    archCopySIDBStore ON IdxSIDBStore.SIDBStoreId = archCopySIDBStore.SIDBStoreId  -- Join to get SIDB Store Copy information
JOIN 
    archGroupCopy ON archCopySIDBStore.CopyId = archGroupCopy.id  -- Join to get Storage Policy Copy
JOIN 
    archGroup ON archGroupCopy.archGroupId = archGroup.id        -- Join to get Storage Policy details
WHERE  
    IdxSIDBStore.SIDBStoreId > 0                                 -- Ensure SIDBStoreId is greater than 0
    AND (MMVolume.attributes & 512) = 0                           -- Ensure certain attributes are set (bitwise operation)
GROUP BY 
    MMLibrary.AliasName, 
    IdxSIDBStore.SIDBStoreAliasName, 
    MMS2getMountPathNameGUIView.MountPathName, 
    IdxSIDBStore.sidbstoreid, 
    archGroup.name, 
    archGroupCOpy.name  -- Grouping the result set by storage policy, copy, library, mount path, and SIDB Store
ORDER BY 
    IdxSIDBStore.SIDBStoreAliasName, 
    archGroup.name, 
    archGroupCOpy.name, 
    MMLibrary.AliasName, 
    MMS2getMountPathNameGUIView.MountPathName; -- Sorting the results in an organized manner
