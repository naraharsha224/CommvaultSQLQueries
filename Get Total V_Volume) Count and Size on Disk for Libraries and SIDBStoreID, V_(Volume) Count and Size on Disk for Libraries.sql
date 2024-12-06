/* Shows Library, VolumeCount and Data on Disk Size in TB */
SELECT MMV.MediaID, MMLibrary.AliasName AS Library, Count(*) as VolumeCount, SUM(MMV.PhysicalBytesMB/(1024.0*1024.0)) as PhysicalBytesTB
FROM MMVolume as MMV
JOIN MMS2getMountPathNameGUIView ON MMV.MediaSideId=MMS2getMountPathNameGUIView.MediaSideId
JOIN MMLibrary ON MMS2getMountPathNameGUIView.LibraryId=MMLibrary.LibraryId
GROUP BY MMV.MediaID, MMLibrary.AliasName
 
/* Shows SIDBStoreID, Libary, VolumeCount and Data on Disk Size in TB */
SELECT MMV.SIDBStoreId, MMV.MediaID, MMLibrary.AliasName AS Library, Count(*) as VolumeCount, SUM(PhysicalBytesMB/(1024.0*1024.0)) as PhysicalBytesTB
FROM MMVolume as MMV
JOIN MMS2getMountPathNameGUIView ON MMV.MediaSideId=MMS2getMountPathNameGUIView.MediaSideId
JOIN MMLibrary ON MMS2getMountPathNameGUIView.LibraryId=MMLibrary.LibraryId
GROUP BY MMV.SIDBStoreId, MMV.MediaID, MMLibrary.AliasName
ORDER BY MMV.SIDBStoreId
