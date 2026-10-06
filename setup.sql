USE master;
GO

IF DB_ID(N'DroneDB') IS NULL
BEGIN
    CREATE DATABASE DroneDB;
END;
GO

USE DroneDB;
GO

IF OBJECT_ID(N'dbo.FlightStage', N'U') IS NOT NULL
    DROP TABLE dbo.FlightStage;
GO

IF OBJECT_ID(N'dbo.Flights', N'U') IS NOT NULL
    DROP TABLE dbo.Flights;
GO

CREATE TABLE dbo.Flights
(
    FlightID INT IDENTITY(1,1) NOT NULL,
    DroneID NVARCHAR(50) NOT NULL,
    FlightDate DATETIME2 NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    SafetyCheckPassed BIT NOT NULL,
    DeliveryCode NVARCHAR(100) NULL,
    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Flights_CreatedAt
        DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Flights
        PRIMARY KEY (FlightID),

    CONSTRAINT CK_Flights_Status
        CHECK
        (
            Status IN
            (
                N'Pending',
                N'InFlight',
                N'Completed',
                N'Cancelled'
            )
        )
);
GO

CREATE TABLE dbo.FlightStage
(
    FlightID INT NULL,
    DroneID NVARCHAR(50) NOT NULL,
    FlightDate DATETIME2 NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    SafetyCheckPassed BIT NOT NULL,
    DeliveryCode NVARCHAR(100) NULL
);
GO
