USE master;
CREATE DATABASE  NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);
GO

USE master;
BACKUP DATABASE NewDatabase
	TO DISK = 'F:\7db\NewDatabase.bak';
GO

DROP DATABASE [NewDatabase]
GO

RESTORE DATABASE [NewDatabase] 
	FROM  DISK = 'F:\7db\NewDatabase.bak';
GO

USE NewDatabase;
GO