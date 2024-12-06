-- Select distinct records to display library name, mount path, total capacity, and total free size
SELECT DISTINCT
       ml.AliasName AS LibraryName,  -- Alias name of the library for identification
       mdc.Folder AS MountPath,  -- Mount path associated with the library
       FORMAT(1.0 * ms.TotalSpaceMB / (1024 * 1024), 'N2') AS 'TotalCapacity(TB)',  -- Total capacity in TB, formatted to 2 decimal places
       FORMAT(ABS((1.0 * ms.FreeBytesMB / (1024 * 1024) - mp.MagneticSpaceRsrvInMB / (1024 * 1024))), 'N2') AS 'TotalFreeSize(TB)'  -- Free space in TB, formatted
FROM MMLibrary ml
JOIN MMMountPath mp ON mp.LibraryId = ml.LibraryID  -- Join to associate libraries with their mount paths
JOIN MMMediaSide ms ON mp.MediaSideId = ms.MediaSideId  -- Join to get media side details for storage capacity
JOIN MMMountPathToStorageDevice mpd ON mp.MountPathId = mpd.MountPathId  -- Join to link mount paths to storage devices
JOIN MMDeviceController mdc ON mpd.DeviceId = mdc.DeviceId  -- Join to connect storage devices with their controllers
WHERE mdc.Folder != ''  -- Exclude records where the folder path is empty
  AND mp.IsOffline = 0  -- Include only online libraries
  AND mp.IsEnabled = 1  -- Include only enabled libraries
  AND ml.AliasName NOT LIKE 'CCM%'  -- Exclude libraries with names starting with 'CCM' (CommCell Migration)
