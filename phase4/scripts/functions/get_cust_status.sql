CREATE OR REPLACE FUNCTION fn_calculate_customer_payment_status(
    p_customer_id INT,
    OUT o_customer_name VARCHAR,
    OUT o_total_registered NUMERIC(10,2),
    OUT o_total_paid NUMERIC(10,2),
    OUT o_debt NUMERIC(10,2),
    OUT o_status_description VARCHAR
)
AS $$
DECLARE
    v_financials RECORD;
    v_phone VARCHAR;
BEGIN
    RAISE NOTICE '--- Starting fn_calculate_customer_payment_status for Customer ID: % ---', p_customer_id;

    SELECT FullName, Phone INTO o_customer_name, v_phone
    FROM CUSTOMER
    WHERE CustomerID = p_customer_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: Customer ID % not found!', p_customer_id
            USING ERRCODE = 'no_data_found';
    END IF;

    SELECT 
        COALESCE(SUM(reg.AmountToPay), 0.00) AS total_fees,
        COALESCE(SUM(
            (SELECT SUM(p.Amount) 
             FROM PAYMENT p 
             JOIN PAYMENTSTATUS ps ON p.PaymentStatusID = ps.PaymentStatusID
             WHERE p.RegistrationID = reg.RegistrationID 
               AND ps.StatusName = 'Paid In Full')
        ), 0.00) AS total_payments
    INTO v_financials
    FROM REGISTRATION reg
    WHERE reg.CustomerID = p_customer_id;

    o_total_registered := v_financials.total_fees;
    o_total_paid := v_financials.total_payments;
    o_debt := o_total_registered - o_total_paid;

    IF o_total_registered = 0.00 THEN
        o_status_description := 'NO ACTIVITY (No registered tours found)';
    ELSIF o_debt <= 0.00 THEN
        o_status_description := 'SETTLED (Fully paid)';
    ELSIF o_debt > 1000.00 THEN
        o_status_description := 'CRITICAL DEBT (High debt detected! Contact customer immediately at ' || v_phone || ')';
    ELSIF o_debt > 0.00 AND o_debt <= 1000.00 THEN
        o_status_description := 'PARTIALLY PAID (Outstanding minor debt remaining)';
    ELSE
        o_status_description := 'REVIEW REQUIRED';
    END IF;

    RAISE NOTICE 'Customer Name: %, Phone: %', o_customer_name, v_phone;
    RAISE NOTICE 'Total Cost: %, Total Paid: %, Debt Remaining: %', o_total_registered, o_total_paid, o_debt;

EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE 'Exception: Customer ID does not exist in the database.';
        o_customer_name := 'N/A';
        o_total_registered := 0.00;
        o_total_paid := 0.00;
        o_debt := 0.00;
        o_status_description := 'ERROR: CUSTOMER NOT FOUND';
    WHEN OTHERS THEN
        RAISE NOTICE 'General exception caught in customer function: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
        RAISE;
END;
$$ LANGUAGE plpgsql;