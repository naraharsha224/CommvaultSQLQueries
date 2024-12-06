-- Select columns to display Library name, Total Capacity, Total Free Space, Used Capacity, and Percentage of Used Capacity
SELECT LibraryName,
       FORMAT(SUM(TotalSpaceTB), 'N2') AS 'TotalCapacity(TB)',  -- Total library capacity in TB, formatted to 2 decimal places
       FORMAT(SUM(FreeSizeTB), 'N2') AS 'TotalFreeSpace(TB)',  -- Total free space in TB, formatted to 2 decimal places
       FORMAT(SUM(TotalSpaceTB) - SUM(FreeSizeTB), 'N2') AS 'UsedCapacity(TB)',  -- Used capacity in TB, calculated and formatted
       FORMAT((SUM(TotalSpaceTB) - SUM(FreeSizeTB)) / (SUM(TotalSpaceTB)) * 100, 'N2') AS 'UsedCapacity(%)'  -- Used capacity as a percentage, formatted
FROM (
    -- Subquery to retrieve relevant data from library and storage tables
    SELECT DISTINCT
           ml.AliasName AS LibraryName,  -- Library alias name for identification
           1.0 * ms.TotalSpaceMB / (1024 * 1024) AS TotalSpaceTB,  -- Convert Total Space from MB to TB
           ABS((1.0 * ms.FreeBytesMB / (1024 * 1024) - mp.MagneticSpaceRsrvInMB / (1024 * 1024))) AS FreeSizeTB  -- Convert Free Space from MB to TB
    FROM MMLibrary ml
    JOIN MMMountPath mp ON mp.LibraryId = ml.LibraryID  -- Join to match libraries with their mount paths
    JOIN MMMediaSide ms ON mp.MediaSideId = ms.MediaSideId  -- Join to get media side details for storage capacity
    JOIN MMMountPathToStorageDevice mpd ON mp.MountPathId = mpd.MountPathId  -- Join to map mount paths to storage devices
    JOIN MMDeviceController mdc ON mpd.DeviceId = mdc.DeviceId  -- Join to link storage devices to their controllers
    WHERE mdc.Folder != '' AND mp.IsOffline = 0 AND mp.IsEnabled = 1  -- Filter to include only online and enabled libraries
) A
WHERE LibraryName NOT LIKE 'CCM%'  -- Exclude libraries starting with 'CCM' (CommCell Migration)
GROUP BY LibraryName  -- Group results by library name to calculate aggregated values
-- HAVING (SUM(TotalSpaceTB) - SUM(FreeSizeTB)) / (SUM(TotalSpaceTB)) * 100 > 90  -- Uncomment to show libraries with >90% used capacity
ORDER BY 'UsedCapacity(%)' DESC  -- Order results by Used Capacity Percentage in descending order
