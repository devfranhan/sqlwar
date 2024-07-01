
USE master
go

-- db offline
ALTER DATABASE dbname SET OFFLINE WITH ROLLBACK IMMEDIATE

-- db online
ALTER DATABASE dbname SET ONLINE
