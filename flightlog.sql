USE DroneDB;
GO

------------------------------------------------------------
-- TEST 1: FAILED SAFETY CHECK
-- The insert is rolled back.
------------------------------------------------------------

DECLARE @BeforeRollback INT;
DECLARE @AfterRollback INT;

SELECT @BeforeRollback = COUNT(*)
FROM dbo.Flights;

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

SELECT @AfterRollback = COUNT(*)
FROM dbo.Flights;

SELECT
    @BeforeRollback AS CountBeforeRollback,
    @AfterRollback AS CountAfterRollback;
GO


------------------------------------------------------------
-- TEST 2: SUCCESSFUL DELIVERY
-- Exactly one flight is committed.
------------------------------------------------------------

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


------------------------------------------------------------
-- INITIAL FLIGHTS FOR MERGE
------------------------------------------------------------

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
),
(
    N'DRONE-002',
    '2026-10-01T09:00:00',
    N'InFlight',
    1,
    N'DEL-1002'
);
GO


------------------------------------------------------------
-- LOAD STAGING TABLE
------------------------------------------------------------

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
),
(
    1,
    N'DRONE-001',
    '2026-10-01T08:00:00',
    N'Pending',
    1,
    N'DEL-1001'
);
GO


------------------------------------------------------------
-- MERGE
--
-- Existing unfinished flight -> Pending
-- New flight -> Insert
------------------------------------------------------------

MERGE dbo.Flights AS Target
USING dbo.FlightStage AS Source
ON Target.FlightID = Source.FlightID

WHEN MATCHED
     AND Target.Status <> N'Completed'
THEN
    UPDATE SET
        Target.Status = N'Pending',
        Target.DroneID = Source.DroneID,
        Target.FlightDate = Source.FlightDate,
        Target.SafetyCheckPassed = Source.SafetyCheckPassed,
        Target.DeliveryCode = Source.DeliveryCode

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


------------------------------------------------------------
-- DISPLAY FINAL FLIGHT LOG
------------------------------------------------------------

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
