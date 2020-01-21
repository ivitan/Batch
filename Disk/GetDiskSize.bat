@echo off
TITLE 查看磁盘大小
wmic DiskDrive get Size /value
::查看C盘
wmic LogicalDisk where "Caption='C:'" get FreeSpace,Size /value
::查看D盘
wmic LogicalDisk where "Caption='D:'" get FreeSpace,Size /value
wmic LogicalDisk where "Caption='D:'" get Size /value
pause