-- Views.sql
-- Stage 3 - Integration Views
-- Tour Guide Management System + Route Management System

-- ============================================================
-- View 1: Original Department View
-- Tour Guide Management System point of view
-- Shows guided tours with guide, route, location, difficulty,
-- and number of registrations.
-- ============================================================

CREATE OR REPLACE VIEW vw_tour_guide_department_view AS
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
    g.GuideID,
    g.FirstName AS GuideFirstName,
    g.LastName AS GuideLastName,
    g.Phone AS GuidePhone,
    g.Email AS GuideEmail,
    r.RouteID,
    r.Name AS RouteName,
    dl.DifficultyName,
    l.LocationName,
    COUNT(reg.RegistrationID) AS NumberOfRegistrations
FROM GUIDEDTOUR gt
JOIN GUIDE g ON gt.GuideID = g.GuideID
JOIN ROUTE r ON gt.RouteID = r.RouteID
JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
LEFT JOIN LOCATED_IN li ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l ON li.LocationID = l.LocationID
LEFT JOIN REGISTRATION reg ON gt.TourID = reg.TourID
GROUP BY
    gt.TourID,
    gt.StartDate,
    gt.EndDate,
    gt.StartTime,
    gt.EndTime,
    gt.MeetingPoint,
    gt.Price,
    gt.MaxParticipants,
    gt.Notes,
    g.GuideID,
    g.FirstName,
    g.LastName,
    g.Phone,
    g.Email,
    r.RouteID,
    r.Name,
    dl.DifficultyName,
    l.LocationName;


SELECT *
FROM vw_tour_guide_department_view
LIMIT 10;

-- ============================================================
-- Query 1.1:
-- Shows tours that still have available seats.
-- This query is useful for the original tour guide department
-- because it helps identify tours that can still accept customers.
-- ============================================================

SELECT
    TourID,
    RouteName,
    LocationName,
    GuideFirstName,
    GuideLastName,
    StartDate,
    MaxParticipants,
    NumberOfRegistrations,
    (MaxParticipants - NumberOfRegistrations) AS AvailableSeats
FROM vw_tour_guide_department_view
WHERE NumberOfRegistrations < MaxParticipants
ORDER BY AvailableSeats DESC;


-- ============================================================
-- Query 1.2:
-- Shows the most popular guided tours by number of registrations.
-- This query helps the original department understand demand.
-- ============================================================

SELECT
    TourID,
    RouteName,
    DifficultyName,
    LocationName,
    StartDate,
    Price,
    NumberOfRegistrations
FROM vw_tour_guide_department_view
WHERE NumberOfRegistrations > 0
ORDER BY NumberOfRegistrations DESC, StartDate;


-- ============================================================
-- View 2: Received Department View
-- Route Management System point of view
-- Shows routes with difficulty, locations,
-- number of guided tours, and average tour price.
-- ============================================================

CREATE OR REPLACE VIEW vw_route_management_department_view AS
SELECT
    r.RouteID,
    r.Name AS RouteName,
    r.Description AS RouteDescription,
    r.EstimatedLength,
    r.EstimatedDuration,
    dl.DifficultyName,
    l.LocationID,
    l.LocationName,
    l.Category AS LocationCategory,
    COUNT(gt.TourID) AS NumberOfGuidedTours,
    AVG(gt.Price) AS AverageTourPrice
FROM ROUTE r
JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
LEFT JOIN LOCATED_IN li ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l ON li.LocationID = l.LocationID
LEFT JOIN GUIDEDTOUR gt ON r.RouteID = gt.RouteID
GROUP BY
    r.RouteID,
    r.Name,
    r.Description,
    r.EstimatedLength,
    r.EstimatedDuration,
    dl.DifficultyName,
    l.LocationID,
    l.LocationName,
    l.Category;

SELECT *
FROM vw_route_management_department_view
LIMIT 10;

-- ============================================================
-- Query 2.1:
-- Shows the most used routes according to the number of guided tours.
-- This query is useful for the received route management department
-- because it helps identify important and active routes.
-- ============================================================

SELECT
    RouteID,
    RouteName,
    LocationName,
    DifficultyName,
    NumberOfGuidedTours
FROM vw_route_management_department_view
WHERE NumberOfGuidedTours > 0
ORDER BY NumberOfGuidedTours DESC, RouteName;


-- ============================================================
-- Query 2.2:
-- Shows long or expensive routes.
-- This query helps the route management department analyze routes
-- that may require more planning, resources, or pricing attention.
-- ============================================================

SELECT
    RouteID,
    RouteName,
    LocationName,
    DifficultyName,
    EstimatedLength,
    EstimatedDuration,
    ROUND(AverageTourPrice::numeric, 2) AS AverageTourPrice
FROM vw_route_management_department_view
WHERE EstimatedLength >= 5
   OR AverageTourPrice >= 150
ORDER BY EstimatedLength DESC, AverageTourPrice DESC;