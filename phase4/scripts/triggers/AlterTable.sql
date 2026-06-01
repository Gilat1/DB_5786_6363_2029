CREATE TABLE IF NOT EXISTS TOUR_AUDIT (
    AuditID SERIAL PRIMARY KEY,
    TourID INT NOT NULL,
    Action VARCHAR(10) NOT NULL,
    OldPrice NUMERIC(10,2),
    NewPrice NUMERIC(10,2),
    OldGuideID INT,
    NewGuideID INT,
    ChangedBy VARCHAR(100) DEFAULT CURRENT_USER,
    ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE TOUR_AUDIT IS 'Audit table for tracking DML actions on the guided tours table';