USE DroneDB;
GO

SET NOCOUNT ON;
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode=N'TEST-FAILED-SAFETY'
)
    THROW 51001,'FAIL: rollback test failed.',1;

PRINT 'PASS: rollback test';

IF
(
    SELECT COUNT(*)
    FROM dbo.Flights
    WHERE DeliveryCode=N'DELIVERY-001'
)<>1
    THROW 51002,'FAIL: commit test failed.',1;

PRINT 'PASS: commit test';

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode=N'DEL-1003'
)
    THROW 51003,'FAIL: MERGE insert DEL-1003 failed.',1;

PRINT 'PASS: MERGE inserted DEL-1003';

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode=N'DEL-1004'
)
    THROW 51004,'FAIL: MERGE insert DEL-1004 failed.',1;

PRINT 'PASS: MERGE inserted DEL-1004';

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode=N'DEL-1001'
      AND Status=N'Pending'
)
    THROW 51005,'FAIL: unfinished flight was not changed to Pending.',1;

PRINT 'PASS: unfinished flight changed to Pending';

SELECT
    FlightID,
    DroneID,
    FlightDate,
    Status,
    SafetyCheckPassed,
    DeliveryCode
FROM dbo.Flights
ORDER BY FlightID;

PRINT '=====================================';
PRINT 'ALL TESTS PASSED';
PRINT '=====================================';
GO
