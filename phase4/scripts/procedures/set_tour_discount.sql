CREATE OR REPLACE PROCEDURE pr_apply_discount_to_tour_participants(
    p_tour_id INT,
    p_discount_percent NUMERIC
)
AS $$
DECLARE
    cur_registrations CURSOR FOR
        SELECT RegistrationID, AmountToPay, CustomerID, Notes
        FROM REGISTRATION
        WHERE TourID = p_tour_id;

    v_reg_count INT := 0;
    v_discount_amount NUMERIC(10,2);
    v_new_amount NUMERIC(10,2);
    v_tour_exists INT;
    v_reg_record RECORD;
BEGIN
    RAISE NOTICE '--- Starting pr_apply_discount_to_tour_participants for Tour ID: %, Discount: % %% ---', p_tour_id, p_discount_percent;

    IF p_discount_percent <= 0.00 OR p_discount_percent > 100.00 THEN
        RAISE EXCEPTION 'Error: Discount percent (%) must be between 0 and 100!', p_discount_percent
            USING ERRCODE = 'invalid_parameter_value';
    END IF;

    SELECT COUNT(*) INTO v_tour_exists FROM GUIDEDTOUR WHERE TourID = p_tour_id;
    IF v_tour_exists = 0 THEN
        RAISE EXCEPTION 'Error: Tour ID % not found in the system!', p_tour_id
            USING ERRCODE = 'no_data_found';
    END IF;

    FOR v_reg_record IN cur_registrations LOOP
        v_reg_count := v_reg_count + 1;
        
        v_discount_amount := ROUND((v_reg_record.AmountToPay * p_discount_percent) / 100.00, 2);
        v_new_amount := v_reg_record.AmountToPay - v_discount_amount;
        
        IF v_new_amount < 0 THEN
            v_new_amount := 0.00;
        END IF;

        UPDATE REGISTRATION
        SET 
            AmountToPay = v_new_amount,
            Notes = COALESCE(v_reg_record.Notes, '') || ' [Discount of ' || p_discount_percent || '% applied on ' || CURRENT_DATE || ']'
        WHERE RegistrationID = v_reg_record.RegistrationID;

        RAISE NOTICE 'Registration ID %: Price reduced from % to % (Saved: %)', 
            v_reg_record.RegistrationID, v_reg_record.AmountToPay, v_new_amount, v_discount_amount;
    END LOOP;

    IF v_reg_count = 0 THEN
        RAISE NOTICE 'No active registrations found for this tour.';
    ELSE
        RAISE NOTICE 'Discount successfully applied to % registrations for Tour ID %.', v_reg_count, p_tour_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during discount application: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql;