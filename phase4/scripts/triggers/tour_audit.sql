CREATE OR REPLACE FUNCTION fn_trg_audit_tour_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.Price IS DISTINCT FROM NEW.Price OR OLD.GuideID IS DISTINCT FROM NEW.GuideID) THEN
            INSERT INTO TOUR_AUDIT (TourID, Action, OldPrice, NewPrice, OldGuideID, NewGuideID)
            VALUES (NEW.TourID, 'UPDATE', OLD.Price, NEW.Price, OLD.GuideID, NEW.GuideID);
        END IF;
        RETURN NEW;

    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO TOUR_AUDIT (TourID, Action, NewPrice, NewGuideID)
        VALUES (NEW.TourID, 'INSERT', NEW.Price, NEW.GuideID);
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO TOUR_AUDIT (TourID, Action, OldPrice, OldGuideID)
        VALUES (OLD.TourID, 'DELETE', OLD.Price, OLD.GuideID);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_tour_changes ON GUIDEDTOUR;
CREATE TRIGGER trg_audit_tour_changes
AFTER INSERT OR UPDATE OR DELETE
ON GUIDEDTOUR
FOR EACH ROW
EXECUTE FUNCTION fn_trg_audit_tour_changes();