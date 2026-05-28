DO $$
DECLARE
    v_cust_id INT := 1;
    v_cust_name VARCHAR;
    v_registered NUMERIC(10,2);
    v_paid NUMERIC(10,2);
    v_debt NUMERIC(10,2);
    v_status_desc VARCHAR;
    
    v_test_tour_id INT := 1;
    v_discount NUMERIC := 20.00;
BEGIN
    RAISE NOTICE '===========================================================';
    RAISE NOTICE '                RUNNING MAIN PROGRAM 1                     ';
    RAISE NOTICE '===========================================================';

    RAISE NOTICE '>>> Step 1: Checking customer financial status before discount...';
    SELECT * INTO v_cust_name, v_registered, v_paid, v_debt, v_status_desc
    FROM fn_calculate_customer_payment_status(v_cust_id);
    
    RAISE NOTICE 'Before Discount: Customer: %, Total Fees: %, Paid: %, Debt: %', 
        v_cust_name, v_registered, v_paid, v_debt;
    RAISE NOTICE 'Status: %', v_status_desc;
    RAISE NOTICE '-----------------------------------------------------------';

    RAISE NOTICE '>>> Step 2: Applying % %% discount to Tour ID %...', v_discount, v_test_tour_id;
    CALL pr_apply_discount_to_tour_participants(v_test_tour_id, v_discount);
    RAISE NOTICE '-----------------------------------------------------------';

    RAISE NOTICE '>>> Step 3: Checking customer financial status after discount...';
    SELECT * INTO v_cust_name, v_registered, v_paid, v_debt, v_status_desc
    FROM fn_calculate_customer_payment_status(v_cust_id);
    
    RAISE NOTICE 'After Discount: Customer: %, Updated Fees: %, Updated Debt: %', 
        v_cust_name, v_registered, v_debt;
    RAISE NOTICE 'New Status: %', v_status_desc;

    BEGIN
        RAISE NOTICE '-----------------------------------------------------------';
        RAISE NOTICE '>>> Step 4: Testing exception handling with invalid discount percent (-10%%)...';
        CALL pr_apply_discount_to_tour_participants(v_test_tour_id, -10.00);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Exception system successfully caught the error and prevented a crash!';
            RAISE NOTICE 'Message: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
    END;

    RAISE NOTICE '===========================================================';
END;
$$;