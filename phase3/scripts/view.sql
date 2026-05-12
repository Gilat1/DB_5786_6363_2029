from pathlib import Path

sql = """-- Views.sql
-- Stage 3 - Integration Views
-- Tour Guide Management System + Route Management System

-- ============================================================
-- View 1: Full guided tour details
-- Combines guided tours with routes, guides, difficulty levels, and locations.
-- ============================================================

CREATE OR REPLACE VIEW vw_full_guided_tour_details AS
SELECT
    gt.TourID,
    gt.StartDate,
    gt.EndDate,
    gt.StartTime,
    gt.EndTime,
    gt.MeetingPoint,
    gt.Price,
    gt.MaxParticipants,
    gt.Notes AS TourNotes,
    r.RouteID,
    r.Name AS RouteName,
    r.Description AS RouteDescription,
    r.EstimatedLength,
    r.EstimatedDuration,
    dl.DifficultyName,
    l.LocationID,
    l.LocationName,
    l.Category AS LocationCategory,
    g.GuideID,
    g.FirstName AS GuideFirstName,
    g.LastName AS GuideLastName,
    g.Phone AS GuidePhone,
    g.Email AS GuideEmail,
    g.Expertise
FROM GUIDEDTOUR gt
JOIN ROUTE r ON gt.RouteID = r.RouteID
JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
JOIN GUIDE g ON gt.GuideID = g.GuideID
LEFT JOIN LOCATED_IN li ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l ON li.LocationID = l.LocationID;

-- Query 1 for View 1
SELECT *
FROM vw_full_guided_tour_details
LIMIT 10;

-- Query 2 for View 1
SELECT
    TourID,
    RouteName,
    LocationName,
    DifficultyName,
    GuideFirstName,
    GuideLastName,
    StartDate,
    Price
FROM vw_full_guided_tour_details
WHERE DifficultyName = 'Easy'
ORDER BY StartDate;


-- ============================================================
-- View 2: Customer registration details
-- Combines customers, registrations, guided tours, routes, and registration status.
-- ============================================================

CREATE OR REPLACE VIEW vw_customer_registration_details AS
SELECT
    c.CustomerID,
    c.FullName AS CustomerName,
    c.Phone AS CustomerPhone,
    c.Email AS CustomerEmail,
    reg.RegistrationID,
    reg.RegistrationDate,
    reg.AmountToPay,
    reg.Notes AS RegistrationNotes,
    rs.StatusName AS RegistrationStatus,
    gt.TourID,
    gt.StartDate,
    gt.StartTime,
    r.RouteID,
    r.Name AS RouteName,
    l.LocationName
FROM REGISTRATION reg
JOIN CUSTOMER c ON reg.CustomerID = c.CustomerID
JOIN GUIDEDTOUR gt ON reg.TourID = gt.TourID
JOIN ROUTE r ON gt.RouteID = r.RouteID
JOIN REGISTRATIONSTATUS rs ON reg.RegistrationStatusID = rs.RegistrationStatusID
LEFT JOIN LOCATED_IN li ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l ON li.LocationID = l.LocationID;

-- Query 1 for View 2
SELECT *
FROM vw_customer_registration_details
LIMIT 10;

-- Query 2 for View 2
SELECT
    CustomerName,
    RouteName,
    LocationName,
    RegistrationDate,
    RegistrationStatus,
    AmountToPay
FROM vw_customer_registration_details
WHERE RegistrationStatus = 'Confirmed'
ORDER BY RegistrationDate DESC;


-- ============================================================
-- View 3: Payment summary details
-- Combines payments, registrations, customers, tours, routes, and payment status.
-- ============================================================

CREATE OR REPLACE VIEW vw_payment_summary_details AS
SELECT
    p.PaymentID,
    p.PaymentDate,
    p.Amount,
    p.PaymentMethod,
    p.ReferenceNumber,
    ps.StatusName AS PaymentStatus,
    reg.RegistrationID,
    c.CustomerID,
    c.FullName AS CustomerName,
    gt.TourID,
    r.RouteID,
    r.Name AS RouteName,
    gt.StartDate AS TourStartDate
FROM PAYMENT p
JOIN PAYMENTSTATUS ps ON p.PaymentStatusID = ps.PaymentStatusID
JOIN REGISTRATION reg ON p.RegistrationID = reg.RegistrationID
JOIN CUSTOMER c ON reg.CustomerID = c.CustomerID
JOIN GUIDEDTOUR gt ON reg.TourID = gt.TourID
JOIN ROUTE r ON gt.RouteID = r.RouteID;

-- Query 1 for View 3
SELECT *
FROM vw_payment_summary_details
LIMIT 10;

-- Query 2 for View 3
SELECT
    RouteName,
    PaymentStatus,
    COUNT(PaymentID) AS NumberOfPayments,
    SUM(Amount) AS TotalAmount
FROM vw_payment_summary_details
GROUP BY RouteName, PaymentStatus
ORDER BY TotalAmount DESC;
"""

path = Path("/mnt/data/Views.sql")
path.write_text(sql, encoding="utf-8")
path.as_posix()
