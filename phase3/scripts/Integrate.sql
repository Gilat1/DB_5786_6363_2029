-- Integrate.sql
-- Stage 3 - Integration between Tour Guide Management System and Route Management System

-- ============================================================
-- Add new field from the received system into GUIDE
-- ============================================================

ALTER TABLE GUIDE
ADD COLUMN Expertise VARCHAR(100);


-- ============================================================
-- Create LOCATION table from the received Route Management System
-- ============================================================

CREATE TABLE LOCATION
(
    LocationID INT NOT NULL,
    LocationName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    PRIMARY KEY (LocationID)
);


-- ============================================================
-- Create LOCATED_IN table to connect routes and locations
-- ============================================================

CREATE TABLE LOCATED_IN
(
    RouteID INT NOT NULL,
    LocationID INT NOT NULL,
    PRIMARY KEY (RouteID, LocationID),
    FOREIGN KEY (RouteID) REFERENCES ROUTE(RouteID),
    FOREIGN KEY (LocationID) REFERENCES LOCATION(LocationID)
);