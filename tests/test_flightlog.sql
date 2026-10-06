USE DroneDB;
GO

------------------------------------------------------------
-- TEST 1
-- Failed safety check must have been rolled back.
------------------------------------------------------------

IF EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode = N'TEST-FAILED-SAFETY'
)
BEGIN
    THROW 50001, 'FAILED: safety-check rollback did not work.', 1;
END;

PRINT 'PASS: failed safety check was rolled back.';
GO


------------------------------------------------------------
-- TEST 2
-- Successful delivery must exist exactly once.
------------------------------------------------------------

IF
(
    SELECT COUNT(*)
    FROM dbo.Flights
    WHERE DeliveryCode = N'DELIVERY-001'
) <> 1
BEGIN
    THROW 50002, 'FAILED: committed delivery is not present exactly once.', 1;
END;

PRINT 'PASS: committed delivery exists exactly once.';
GO


------------------------------------------------------------
-- TEST 3
-- MERGE must insert DEL-1003.
------------------------------------------------------------

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode = N'DEL-1003'
)
BEGIN
    THROW 50003, 'FAILED: MERGE did not insert DEL-1003.', 1;
END;

PRINT 'PASS: MERGE inserted DEL-1003.';
GO


------------------------------------------------------------
-- TEST 4
-- MERGE must insert DEL-1004.
------------------------------------------------------------

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode = N'DEL-1004'
)
BEGIN
    THROW 50004, 'FAILED: MERGE did not insert DEL-1004.', 1;
END;

PRINT 'PASS: MERGE inserted DEL-1004.';
GO


------------------------------------------------------------
-- TEST 5
-- Existing unfinished flight must become Pending.
------------------------------------------------------------

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.Flights
    WHERE DeliveryCode = N'DEL-1001'
      AND Status = N'Pending'
)
BEGIN
    THROW 50005, 'FAILED: unfinished flight was not changed to Pending.', 1;
END;

PRINT 'PASS: unfinished flight was changed to Pending.';
GO


------------------------------------------------------------
-- FINAL RESULT
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

PRINT '============================================';
PRINT 'ALL SKYDROP FLIGHT LOG TESTS PASSED';
PRINT '============================================';
GO
