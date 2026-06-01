CREATE OR REPLACE FUNCTION fn_trg_update_registration_payment_status()
RETURNS TRIGGER AS $$
DECLARE
    v_amount_to_pay NUMERIC(10,2);
    v_total_paid NUMERIC(10,2) := 0.00;
    v_new_status_id INT;
BEGIN
    SELECT AmountToPay INTO v_amount_to_pay
    FROM REGISTRATION
    WHERE RegistrationID = NEW.RegistrationID;
    
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;

    SELECT COALESCE(SUM(Amount), 0.00) INTO v_total_paid
    FROM PAYMENT
    WHERE RegistrationID = NEW.RegistrationID
      AND PaymentStatusID = 3;

    IF v_total_paid >= v_amount_to_pay AND v_amount_to_pay > 0.00 THEN
        v_new_status_id := 2;
    ELSIF v_total_paid > 0.00 AND v_total_paid < v_amount_to_pay THEN
        v_new_status_id := 8;
    ELSE
        v_new_status_id := 7;
    END IF;

    UPDATE REGISTRATION
    SET RegistrationStatusID = v_new_status_id
    WHERE RegistrationID = NEW.RegistrationID;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_registration_payment_status ON PAYMENT;
CREATE TRIGGER trg_update_registration_payment_status
AFTER INSERT OR UPDATE OF PaymentStatusID, Amount
ON PAYMENT
FOR EACH ROW
EXECUTE FUNCTION fn_trg_update_registration_payment_status();