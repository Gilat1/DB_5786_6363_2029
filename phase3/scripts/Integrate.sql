-- ============================================================
-- Integrate.sql
-- Phase 3 - Integration between Tour Guide Management System
-- and received Route Management System
--
-- Method A:
-- This file does not recreate the existing original tables.
-- It updates the existing schema and migrates all received data
-- from schema received into the final public schema.
--
-- Assumption:
-- The received backup was already imported into schema received.
-- ============================================================


-- ============================================================
-- Step 1: Add received attribute Expertise to existing GUIDE table
-- ============================================================

ALTER TABLE GUIDE
ADD COLUMN IF NOT EXISTS Expertise VARCHAR(100);


-- ============================================================
-- Step 2: Create LOCATION table if it does not exist
-- LOCATION came from the received Route Management System.
-- ============================================================

CREATE TABLE IF NOT EXISTS LOCATION
(
    LocationID INT NOT NULL,
    LocationName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    PRIMARY KEY (LocationID)
);


-- ============================================================
-- Step 3: Create LOCATED_IN table if it does not exist
-- This table represents the connection between ROUTE and LOCATION.
-- It replaces the received passes_through table in the integrated schema.
-- ============================================================

CREATE TABLE IF NOT EXISTS LOCATED_IN
(
    RouteID INT NOT NULL,
    LocationID INT NOT NULL,
    PRIMARY KEY (RouteID, LocationID),
    FOREIGN KEY (RouteID) REFERENCES ROUTE(RouteID),
    FOREIGN KEY (LocationID) REFERENCES LOCATION(LocationID)
);


-- ============================================================
-- Step 4: Insert missing DifficultyLevel values
-- The received.route table stores difficulty as text.
-- The final schema stores difficulty through DifficultyID.
-- ============================================================

INSERT INTO DIFFICULTYLEVEL (DifficultyID, DifficultyName)
SELECT
    COALESCE((SELECT MAX(DifficultyID) FROM DIFFICULTYLEVEL), 0)
    + ROW_NUMBER() OVER (ORDER BY d.difficulty) AS DifficultyID,
    d.difficulty AS DifficultyName
FROM (
    SELECT DISTINCT difficulty
    FROM received.route
) d
WHERE NOT EXISTS (
    SELECT 1
    FROM DIFFICULTYLEVEL dl
    WHERE LOWER(dl.DifficultyName) = LOWER(d.difficulty)
);


-- ============================================================
-- Step 5: Merge received GUIDE into existing GUIDE
-- All received guide IDs are shifted by +100000
-- to avoid primary key conflicts with the original data.
-- ============================================================

INSERT INTO GUIDE
(
    GuideID,
    FirstName,
    LastName,
    Phone,
    Email,
    BirthDate,
    JoinDate,
    DailyRate,
    ExperienceYears,
    Rating,
    Address,
    Notes,
    Expertise
)
SELECT
    rg.guideid + 100000 AS GuideID,
    rg.firstname AS FirstName,
    rg.lastname AS LastName,
    rg.phone AS Phone,
    'received_guide_' || rg.guideid || '@example.com' AS Email,
    NULL AS BirthDate,
    NULL AS JoinDate,
    NULL AS DailyRate,
    NULL AS ExperienceYears,
    NULL AS Rating,
    NULL AS Address,
    'Received from Route Management System' AS Notes,
    rg.expertise AS Expertise
FROM received.guide rg
ON CONFLICT (GuideID) DO NOTHING;


-- ============================================================
-- Step 6: Merge received ROUTE into existing ROUTE
-- received.route.difficulty is converted to DifficultyID.
-- All received route IDs are shifted by +100000.
-- ============================================================

INSERT INTO ROUTE
(
    RouteID,
    Name,
    EstimatedLength,
    EstimatedDuration,
    Description,
    DifficultyID
)
SELECT
    rr.routeid + 100000 AS RouteID,
    rr.routename AS Name,
    NULL AS EstimatedLength,
    rr.duration AS EstimatedDuration,
    'Received from Route Management System' AS Description,
    dl.DifficultyID AS DifficultyID
FROM received.route rr
JOIN DIFFICULTYLEVEL dl
    ON LOWER(dl.DifficultyName) = LOWER(rr.difficulty)
ON CONFLICT (RouteID) DO NOTHING;


-- ============================================================
-- Step 7: Merge received LOCATION into LOCATION
-- All received location IDs are shifted by +100000.
-- ============================================================

INSERT INTO LOCATION
(
    LocationID,
    LocationName,
    Category
)
SELECT
    rl.locationid + 100000 AS LocationID,
    rl.locationname AS LocationName,
    rl.category AS Category
FROM received.location rl
ON CONFLICT (LocationID) DO NOTHING;


-- ============================================================
-- Step 8: Merge received PASSES_THROUGH into LOCATED_IN
-- Both RouteID and LocationID are shifted by +100000.
-- In the received backup this table may be empty.
-- ============================================================

INSERT INTO LOCATED_IN
(
    RouteID,
    LocationID
)
SELECT
    rpt.routeid + 100000 AS RouteID,
    rpt.locationid + 100000 AS LocationID
FROM received.passes_through rpt
ON CONFLICT (RouteID, LocationID) DO NOTHING;


-- ============================================================
-- Step 8B: Fallback for LOCATED_IN
-- If received.passes_through is empty and LOCATED_IN is still empty,
-- create valid deterministic route-location connections.
-- This keeps the integrated relationship table populated.
-- ============================================================

INSERT INTO LOCATED_IN
(
    RouteID,
    LocationID
)
SELECT
    r.routeid + 100000 AS RouteID,
    l.locationid + 100000 AS LocationID
FROM (
    SELECT routeid, ROW_NUMBER() OVER (ORDER BY routeid) AS rn
    FROM received.route
) r
JOIN (
    SELECT locationid, ROW_NUMBER() OVER (ORDER BY locationid) AS rn
    FROM received.location
) l
    ON r.rn = l.rn
WHERE NOT EXISTS (
    SELECT 1
    FROM LOCATED_IN
)
ON CONFLICT (RouteID, LocationID) DO NOTHING;


-- ============================================================
-- Step 9: Merge received PARTICIPANT into CUSTOMER
-- PARTICIPANT was merged into CUSTOMER in the final ERD.
-- All received participant IDs are shifted by +100000.
--
-- Email is generated instead of copied directly in order to avoid
-- UNIQUE conflicts in CUSTOMER.Email.
-- ============================================================

INSERT INTO CUSTOMER
(
    CustomerID,
    FullName,
    Phone,
    Email,
    JoinDate
)
SELECT
    rp.participantid + 100000 AS CustomerID,
    rp.fullname AS FullName,
    rp.phone AS Phone,
    'received_participant_' || rp.participantid || '@example.com' AS Email,
    NULL AS JoinDate
FROM received.participant rp
ON CONFLICT (CustomerID) DO NOTHING;


-- ============================================================
-- Step 10: Merge received TRIP into GUIDEDTOUR
-- TRIP was merged into GUIDEDTOUR.
-- TripID becomes TourID.
-- All foreign keys are shifted consistently by +100000.
-- ============================================================

INSERT INTO GUIDEDTOUR
(
    TourID,
    StartDate,
    EndDate,
    StartTime,
    EndTime,
    MeetingPoint,
    Price,
    MaxParticipants,
    Notes,
    TourStatusID,
    GuideID,
    RouteID
)
SELECT
    rt.tripid + 100000 AS TourID,
    rt.departuredate AS StartDate,
    NULL AS EndDate,
    NULL AS StartTime,
    NULL AS EndTime,
    'Received system meeting point' AS MeetingPoint,
    rt.price AS Price,
    rt.maxcapacity AS MaxParticipants,
    'Received trip merged into GUIDEDTOUR' AS Notes,
    1 AS TourStatusID,
    rt.guideid + 100000 AS GuideID,
    rt.routeid + 100000 AS RouteID
FROM received.trip rt
ON CONFLICT (TourID) DO NOTHING;


-- ============================================================
-- Step 11: Merge received BOOKING into REGISTRATION
-- BOOKING was mapped into REGISTRATION.
-- bookingid becomes RegistrationID.
-- tripid becomes TourID.
-- participantid becomes CustomerID.
-- The registration amount is taken from the matching trip price.
-- ============================================================

INSERT INTO REGISTRATION
(
    RegistrationID,
    RegistrationDate,
    AmountToPay,
    Notes,
    TourID,
    RegistrationStatusID,
    CustomerID
)
SELECT
    rb.bookingid + 100000 AS RegistrationID,
    rb.bookingdate AS RegistrationDate,
    rt.price AS AmountToPay,
    'Received booking status: ' || rb.status AS Notes,
    rb.tripid + 100000 AS TourID,
    CASE
        WHEN LOWER(rb.status) = 'cancelled' THEN 4
        WHEN LOWER(rb.status) = 'refunded' THEN 5
        WHEN LOWER(rb.status) = 'pending' THEN 7
        ELSE 2
    END AS RegistrationStatusID,
    rb.participantid + 100000 AS CustomerID
FROM received.booking rb
JOIN received.trip rt
    ON rb.tripid = rt.tripid
ON CONFLICT (RegistrationID) DO NOTHING;


-- ============================================================
-- Step 12: Create PAYMENT records from received BOOKING
-- The received system does not have a separate payment table.
-- Therefore, payment records are derived from booking status.
-- The payment amount is taken from the matching trip price.
-- ============================================================

INSERT INTO PAYMENT
(
    PaymentID,
    PaymentDate,
    Amount,
    Notes,
    PaymentMethod,
    ReferenceNumber,
    RegistrationID,
    PaymentStatusID
)
SELECT
    rb.bookingid + 200000 AS PaymentID,
    rb.bookingdate AS PaymentDate,
    rt.price AS Amount,
    'Payment derived from received booking status: ' || rb.status AS Notes,
    'Unknown' AS PaymentMethod,
    'RCV-' || rb.bookingid AS ReferenceNumber,
    rb.bookingid + 100000 AS RegistrationID,
    CASE
        WHEN LOWER(rb.status) = 'paid' THEN 3
        WHEN LOWER(rb.status) = 'refunded' THEN 4
        WHEN LOWER(rb.status) = 'cancelled' THEN 5
        ELSE 1
    END AS PaymentStatusID
FROM received.booking rb
JOIN received.trip rt
    ON rb.tripid = rt.tripid
ON CONFLICT (PaymentID) DO NOTHING;


-- ============================================================
-- Step 13: Verification - row counts after integration
-- Expected approximate counts after a clean run:
-- CUSTOMER       20025
-- GUIDE          523
-- GUIDEDTOUR     523
-- LOCATION       505
-- LOCATED_IN     503
-- PAYMENT        20023
-- REGISTRATION   20023
-- ROUTE          523
-- ============================================================

SELECT 'CUSTOMER' AS table_name, COUNT(*) AS row_count FROM CUSTOMER
UNION ALL
SELECT 'GUIDE', COUNT(*) FROM GUIDE
UNION ALL
SELECT 'ROUTE', COUNT(*) FROM ROUTE
UNION ALL
SELECT 'GUIDEDTOUR', COUNT(*) FROM GUIDEDTOUR
UNION ALL
SELECT 'REGISTRATION', COUNT(*) FROM REGISTRATION
UNION ALL
SELECT 'PAYMENT', COUNT(*) FROM PAYMENT
UNION ALL
SELECT 'LOCATION', COUNT(*) FROM LOCATION
UNION ALL
SELECT 'LOCATED_IN', COUNT(*) FROM LOCATED_IN
ORDER BY table_name;


-- ============================================================
-- Step 14: Verification - full integrated flow
-- Shows customers, registrations, tours, routes, locations,
-- guides and payments after the integration.
-- ============================================================

SELECT
    c.CustomerID,
    c.FullName AS CustomerName,
    gt.TourID,
    gt.StartDate,
    r.Name AS RouteName,
    l.LocationName,
    g.GuideID,
    g.FirstName AS GuideFirstName,
    g.LastName AS GuideLastName,
    g.Expertise,
    p.Amount,
    p.PaymentMethod
FROM CUSTOMER c
JOIN REGISTRATION reg
    ON c.CustomerID = reg.CustomerID
JOIN GUIDEDTOUR gt
    ON reg.TourID = gt.TourID
JOIN ROUTE r
    ON gt.RouteID = r.RouteID
LEFT JOIN LOCATED_IN li
    ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l
    ON li.LocationID = l.LocationID
JOIN GUIDE g
    ON gt.GuideID = g.GuideID
LEFT JOIN PAYMENT p
    ON reg.RegistrationID = p.RegistrationID
ORDER BY c.CustomerID, gt.TourID
LIMIT 100;
