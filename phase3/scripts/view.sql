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

-- Query 1.1
SELECT *
FROM vw_tour_guide_department_view
LIMIT 10;

-- Query 1.2
SELECT
    TourID,
    RouteName,
    GuideFirstName,
    GuideLastName,
    StartDate,
    Price,
    NumberOfRegistrations
FROM vw_tour_guide_department_view
ORDER BY NumberOfRegistrations DESC;


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

-- Query 2.1
SELECT *
FROM vw_route_management_department_view
LIMIT 10;

-- Query 2.2
SELECT
    RouteName,
    DifficultyName,
    LocationName,
    NumberOfGuidedTours,
    ROUND(AverageTourPrice, 2) AS AverageTourPrice
FROM vw_route_management_department_view
ORDER BY NumberOfGuidedTours DESC;