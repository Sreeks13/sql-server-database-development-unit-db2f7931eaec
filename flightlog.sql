USE DroneDB;
GO

SET NOCOUNT ON;
GO

/* Failed safety check -> ROLLBACK */

BEGIN TRANSACTION;

INSERT INTO dbo.Flights
(
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
)
VALUES
(
    N'DRONE-FAIL-001',
    SYSUTCDATETIME(),
    N'InFlight',
    0,
    N'TEST-FAILED-SAFETY'
);

ROLLBACK TRANSACTION;
GO

/* Successful delivery -> COMMIT */

BEGIN TRANSACTION;

INSERT INTO dbo.Flights
(
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
)
VALUES
(
    N'DRONE-DELIVERY-001',
    SYSUTCDATETIME(),
    N'Completed',
    1,
    N'DELIVERY-001'
);

COMMIT TRANSACTION;
GO

/* Existing unfinished flight */

INSERT INTO dbo.Flights
(
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
)
VALUES
(
    N'DRONE-001',
    '2026-10-01T08:00:00',
    N'InFlight',
    1,
    N'DEL-1001'
);
GO

/* Staging data */

TRUNCATE TABLE dbo.FlightStage;
GO

INSERT INTO dbo.FlightStage
(
    FlightID,
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
)
VALUES
(
    NULL,
    N'DRONE-003',
    '2026-10-02T10:00:00',
    N'Completed',
    1,
    N'DEL-1003'
),
(
    NULL,
    N'DRONE-004',
    '2026-10-02T11:00:00',
    N'Completed',
    1,
    N'DEL-1004'
);
GO

INSERT INTO dbo.FlightStage
(
    FlightID,
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
)
SELECT
    FlightID,
    DroneID,
    FlightDate,
    N'Pending',
    SafetyCheckPassed,
    DeliveryCode
FROM dbo.Flights
WHERE DeliveryCode=N'DEL-1001';
GO

/* MERGE */

MERGE dbo.Flights AS Target
USING dbo.FlightStage AS Source
ON Target.FlightID=Source.FlightID

WHEN MATCHED
     AND Target.Status<>N'Completed'
THEN
UPDATE SET
    Target.DroneID=Source.DroneID,
    Target.FlightDate=Source.FlightDate,
    Target.Status=N'Pending',
    Target.SafetyCheckPassed=Source.SafetyCheckPassed,
    Target.DeliveryCode=Source.DeliveryCode

WHEN NOT MATCHED BY TARGET
THEN
INSERT
(
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
)
VALUES
(
    Source.DroneID,
    Source.FlightDate,
    Source.Status,
    Source.SafetyCheckPassed,
    Source.DeliveryCode
);
GO

SELECT
    FlightID,
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode,
    CreatedAt
FROM dbo.Flights
ORDER BY FlightID;
GO
