--
-- PostgreSQL database dump
--

\restrict 1yVkmVHmPcV0aVBrdYmTSEfKNQlweApDmk3hhLPCOhgOhSGSmCkk45bzT82Xqhm

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.3

-- Started on 2026-05-28 09:35:27 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 32771)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 242 (class 1255 OID 33326)
-- Name: fn_calculate_customer_payment_status(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_calculate_customer_payment_status(p_customer_id integer, OUT o_customer_name character varying, OUT o_total_registered numeric, OUT o_total_paid numeric, OUT o_debt numeric, OUT o_status_description character varying) RETURNS record
    LANGUAGE plpgsql
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
$$;


--
-- TOC entry 243 (class 1255 OID 33328)
-- Name: fn_get_route_tour_details_by_difficulty(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_get_route_tour_details_by_difficulty(p_difficulty_name character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
    ref_result refcursor := 'tours_cursor';
    
    cur_difficulty CURSOR FOR 
        SELECT DifficultyID 
        FROM DIFFICULTYLEVEL 
        WHERE LOWER(DifficultyName) = LOWER(p_difficulty_name);
        
    cur_tour_summary CURSOR FOR
        SELECT gt.Price, gt.MaxParticipants
        FROM GUIDEDTOUR gt
        JOIN ROUTE r ON gt.RouteID = r.RouteID
        JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
        WHERE LOWER(dl.DifficultyName) = LOWER(p_difficulty_name);
        
    v_difficulty_id INT;
    v_tour_record RECORD;
    v_tour_count INT := 0;
    v_total_price NUMERIC(12,2) := 0.00;
    v_avg_price NUMERIC(10,2) := 0.00;
    v_max_revenue_potential NUMERIC(12,2) := 0.00;
BEGIN
    RAISE NOTICE '--- Starting fn_get_route_tour_details_by_difficulty for: % ---', p_difficulty_name;

    OPEN cur_difficulty;
    FETCH cur_difficulty INTO v_difficulty_id;
    
    IF NOT FOUND THEN
        CLOSE cur_difficulty;
        RAISE EXCEPTION 'Error: Difficulty level (%) not found!', p_difficulty_name
            USING ERRCODE = 'invalid_parameter_value';
    END IF;
    CLOSE cur_difficulty;

    OPEN cur_tour_summary;
    LOOP
        FETCH cur_tour_summary INTO v_tour_record;
        EXIT WHEN NOT FOUND;
        
        v_tour_count := v_tour_count + 1;
        v_total_price := v_total_price + v_tour_record.Price;
        v_max_revenue_potential := v_max_revenue_potential + (v_tour_record.Price * v_tour_record.MaxParticipants);
    END LOOP;
    CLOSE cur_tour_summary;

    IF v_tour_count > 0 THEN
        v_avg_price := v_total_price / v_tour_count;
    ELSE
        v_avg_price := 0.00;
    END IF;

    RAISE NOTICE 'Difficulty Name: % (ID: %)', p_difficulty_name, v_difficulty_id;
    RAISE NOTICE 'Total Tours Found: %', v_tour_count;
    RAISE NOTICE 'Average Tour Price: %', v_avg_price;
    RAISE NOTICE 'Max Revenue Potential: %', v_max_revenue_potential;

    OPEN ref_result FOR
        SELECT 
            gt.TourID,
            r.Name AS RouteName,
            gt.StartDate,
            gt.MeetingPoint,
            gt.Price,
            gt.MaxParticipants,
            g.FirstName || ' ' || g.LastName AS AssignedGuide
        FROM GUIDEDTOUR gt
        JOIN ROUTE r ON gt.RouteID = r.RouteID
        JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
        JOIN GUIDE g ON gt.GuideID = g.GuideID
        WHERE LOWER(dl.DifficultyName) = LOWER(p_difficulty_name)
        ORDER BY gt.StartDate;
        
    RETURN ref_result;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Exception caught in fn_get_route_tour_details_by_difficulty: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
        RAISE;
END;
$$;


--
-- TOC entry 246 (class 1255 OID 33343)
-- Name: fn_trg_audit_tour_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_trg_audit_tour_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- TOC entry 247 (class 1255 OID 33345)
-- Name: fn_trg_update_registration_payment_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_trg_update_registration_payment_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- TOC entry 244 (class 1255 OID 33327)
-- Name: pr_apply_discount_to_tour_participants(integer, numeric); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.pr_apply_discount_to_tour_participants(IN p_tour_id integer, IN p_discount_percent numeric)
    LANGUAGE plpgsql
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
$$;


--
-- TOC entry 245 (class 1255 OID 33329)
-- Name: pr_assign_optimal_guide_to_tour(integer, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.pr_assign_optimal_guide_to_tour(IN p_tour_id integer, IN p_preferred_expertise character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tour_start DATE;
    v_tour_end DATE;
    
    cur_available_guides CURSOR (c_start_date DATE, c_end_date DATE, c_expertise VARCHAR) FOR
        SELECT g.GuideID, g.FirstName, g.LastName, g.Rating, g.ExperienceYears
        FROM GUIDE g
        WHERE LOWER(g.Expertise) = LOWER(c_expertise)
          AND g.Rating >= 4.0
          AND NOT EXISTS (
              SELECT 1 
              FROM GUIDEDTOUR gt
              WHERE gt.GuideID = g.GuideID
                AND gt.TourID != p_tour_id
                AND gt.TourStatusID != 5 
                AND (gt.StartDate <= c_end_date AND gt.EndDate >= c_start_date)
          )
        ORDER BY g.Rating DESC, g.ExperienceYears DESC;

    v_best_guide_id INT := NULL;
    v_best_guide_name VARCHAR;
    v_best_guide_rating NUMERIC(3,2) := 0.00;
    v_guide_record RECORD;
BEGIN
    RAISE NOTICE '--- Starting pr_assign_optimal_guide_to_tour for Tour ID: %, Expertise: % ---', p_tour_id, p_preferred_expertise;

    SELECT StartDate, EndDate INTO v_tour_start, v_tour_end
    FROM GUIDEDTOUR
    WHERE TourID = p_tour_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: Tour ID % not found in the system!', p_tour_id
            USING ERRCODE = 'no_data_found';
    END IF;

    OPEN cur_available_guides(v_tour_start, v_tour_end, p_preferred_expertise);
    FETCH cur_available_guides INTO v_guide_record;
    
    IF FOUND THEN
        v_best_guide_id := v_guide_record.GuideID;
        v_best_guide_name := v_guide_record.FirstName || ' ' || v_guide_record.LastName;
        v_best_guide_rating := v_guide_record.Rating;
    END IF;
    CLOSE cur_available_guides;

    IF v_best_guide_id IS NOT NULL THEN
        UPDATE GUIDEDTOUR
        SET 
            GuideID = v_best_guide_id,
            TourStatusID = CASE WHEN TourStatusID = 11 THEN 1 ELSE TourStatusID END -- עדכון סטטוס במידת הצורך
        WHERE TourID = p_tour_id;
        
        RAISE NOTICE 'Guide % (ID %) successfully assigned to Tour ID %.', v_best_guide_name, v_best_guide_id, p_tour_id;
    ELSE
        RAISE EXCEPTION 'Error: No available guide with expertise "%" and rating >= 4.0 found for these dates!', p_preferred_expertise
            USING ERRCODE = 'check_violation';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during guide assignment: %', SQLERRM;
        RAISE;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 33014)
-- Name: customer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer (
    customerid integer NOT NULL,
    fullname character varying(100) NOT NULL,
    phone character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    joindate date
);


--
-- TOC entry 220 (class 1259 OID 32952)
-- Name: difficultylevel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.difficultylevel (
    difficultyid integer NOT NULL,
    difficultyname character varying(50) NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 32935)
-- Name: guide; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guide (
    guideid integer NOT NULL,
    firstname character varying(50) NOT NULL,
    lastname character varying(50) NOT NULL,
    phone character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    birthdate date,
    joindate date,
    dailyrate numeric(8,2),
    experienceyears integer,
    rating numeric(3,2),
    address character varying(200),
    notes character varying(500),
    expertise character varying(100),
    CONSTRAINT guide_dailyrate_check CHECK ((dailyrate >= (0)::numeric)),
    CONSTRAINT guide_experienceyears_check CHECK ((experienceyears >= 0)),
    CONSTRAINT guide_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);


--
-- TOC entry 223 (class 1259 OID 32983)
-- Name: guidedtour; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guidedtour (
    tourid integer NOT NULL,
    startdate date NOT NULL,
    enddate date,
    starttime character varying(10),
    endtime character varying(10),
    meetingpoint character varying(200) NOT NULL,
    price numeric(8,2),
    maxparticipants integer,
    notes character varying(500),
    tourstatusid integer NOT NULL,
    guideid integer NOT NULL,
    routeid integer NOT NULL,
    CONSTRAINT guidedtour_check CHECK (((enddate IS NULL) OR (enddate >= startdate))),
    CONSTRAINT guidedtour_maxparticipants_check CHECK ((maxparticipants > 0)),
    CONSTRAINT guidedtour_price_check CHECK ((price >= (0)::numeric))
);


--
-- TOC entry 228 (class 1259 OID 33067)
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    paymentid integer NOT NULL,
    paymentdate date NOT NULL,
    amount numeric(8,2),
    notes character varying(500),
    paymentmethod character varying(50) NOT NULL,
    referencenumber character varying(50),
    registrationid integer NOT NULL,
    paymentstatusid integer NOT NULL,
    CONSTRAINT payment_amount_check CHECK ((amount >= (0)::numeric))
);


--
-- TOC entry 227 (class 1259 OID 33060)
-- Name: paymentstatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paymentstatus (
    paymentstatusid integer NOT NULL,
    statusname character varying(50) NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 33032)
-- Name: registration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registration (
    registrationid integer NOT NULL,
    registrationdate date NOT NULL,
    amounttopay numeric(8,2),
    notes character varying(500),
    tourid integer NOT NULL,
    registrationstatusid integer NOT NULL,
    customerid integer NOT NULL,
    CONSTRAINT registration_amounttopay_check CHECK ((amounttopay >= (0)::numeric))
);


--
-- TOC entry 225 (class 1259 OID 33025)
-- Name: registrationstatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registrationstatus (
    registrationstatusid integer NOT NULL,
    statusname character varying(50) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 32959)
-- Name: route; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.route (
    routeid integer NOT NULL,
    name character varying(100) NOT NULL,
    estimatedlength numeric(8,2),
    estimatedduration integer,
    description character varying(500),
    difficultyid integer NOT NULL,
    CONSTRAINT route_estimatedduration_check CHECK ((estimatedduration > 0)),
    CONSTRAINT route_estimatedlength_check CHECK ((estimatedlength >= (0)::numeric))
);


--
-- TOC entry 230 (class 1259 OID 33331)
-- Name: tour_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_audit (
    auditid integer NOT NULL,
    tourid integer NOT NULL,
    action character varying(10) NOT NULL,
    oldprice numeric(10,2),
    newprice numeric(10,2),
    oldguideid integer,
    newguideid integer,
    changedby character varying(100) DEFAULT CURRENT_USER,
    changedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE tour_audit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tour_audit IS 'Audit table for tracking DML actions on the guided tours table';


--
-- TOC entry 229 (class 1259 OID 33330)
-- Name: tour_audit_auditid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tour_audit_auditid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 229
-- Name: tour_audit_auditid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tour_audit_auditid_seq OWNED BY public.tour_audit.auditid;


--
-- TOC entry 222 (class 1259 OID 32976)
-- Name: tourstatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tourstatus (
    tourstatusid integer NOT NULL,
    statusname character varying(50) NOT NULL
);


--
-- TOC entry 3335 (class 2604 OID 33334)
-- Name: tour_audit auditid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_audit ALTER COLUMN auditid SET DEFAULT nextval('public.tour_audit_auditid_seq'::regclass);


--
-- TOC entry 3540 (class 0 OID 33014)
-- Dependencies: 224
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.customer VALUES (1, 'Moshe Levi', '054-1234567', 'moshe@gmail.com', '2023-01-10');
INSERT INTO public.customer VALUES (2, 'Rivka Dayan', '054-2345678', 'rivka@gmail.com', '2023-02-15');
INSERT INTO public.customer VALUES (3, 'Yosi Amar', '054-3456789', 'yosi_a@gmail.com', '2023-03-20');
INSERT INTO public.customer VALUES (4, 'Liora Peretz', '054-4567890', 'liora@gmail.com', '2023-04-05');
INSERT INTO public.customer VALUES (5, 'Eyal Biton', '054-5678901', 'eyal@gmail.com', '2023-05-12');
INSERT INTO public.customer VALUES (6, 'Dorit Gabbay', '054-6789012', 'dorit@gmail.com', '2023-06-18');
INSERT INTO public.customer VALUES (7, 'Sharon Sabag', '054-7890123', 'sharon@gmail.com', '2023-07-22');
INSERT INTO public.customer VALUES (8, 'Guy Ohayon', '054-8901234', 'guy@gmail.com', '2023-08-30');
INSERT INTO public.customer VALUES (9, 'Tali Vaknin', '054-9012345', 'tali@gmail.com', '2023-09-14');
INSERT INTO public.customer VALUES (10, 'Ben Hazan', '054-0123456', 'ben@gmail.com', '2023-10-10');
INSERT INTO public.customer VALUES (11, 'Orit Elbaz', '058-1111111', 'orit@gmail.com', '2023-11-11');
INSERT INTO public.customer VALUES (12, 'Ilan Melamed', '058-2222222', 'ilan@gmail.com', '2023-12-01');
INSERT INTO public.customer VALUES (13, 'Hila Naveh', '058-3333333', 'hila@gmail.com', '2024-01-05');
INSERT INTO public.customer VALUES (14, 'Niv Golan', '058-4444444', 'niv@gmail.com', '2024-01-20');
INSERT INTO public.customer VALUES (15, 'Sapir Shani', '058-5555555', 'sapir@gmail.com', '2024-02-10');
INSERT INTO public.customer VALUES (16, 'Roei Sagy', '058-6666666', 'roei@gmail.com', '2024-02-15');
INSERT INTO public.customer VALUES (17, 'Maya Roz', '058-7777777', 'maya_r@gmail.com', '2024-02-28');
INSERT INTO public.customer VALUES (18, 'Dan Arad', '058-8888888', 'dan@gmail.com', '2024-03-01');
INSERT INTO public.customer VALUES (19, 'Ziv Alon', '058-9999999', 'ziv@gmail.com', '2024-03-05');
INSERT INTO public.customer VALUES (20, 'Gali Koren', '053-3333333', 'gali@gmail.com', '2024-03-10');
INSERT INTO public.customer VALUES (500, 'Bethanne', '220-646-4672', 'bdicken0@1und1.de', '2025-07-29');
INSERT INTO public.customer VALUES (501, 'Berkie', '406-221-2651', 'bsmedmoor1@deliciousdays.com', '2025-12-13');
INSERT INTO public.customer VALUES (502, 'Dallas', '439-731-4429', 'dsmalles2@businessinsider.com', '2025-10-12');
INSERT INTO public.customer VALUES (503, 'Robinia', '195-663-9729', 'rwigelsworth3@google.co.jp', '2025-10-09');
INSERT INTO public.customer VALUES (504, 'Timotheus', '473-239-3857', 'tstorey4@aboutads.info', '2025-09-20');
INSERT INTO public.customer VALUES (505, 'Gerhard', '630-868-7794', 'groderighi5@economist.com', '2025-08-31');
INSERT INTO public.customer VALUES (506, 'Cthrine', '933-595-6783', 'cilyenko6@army.mil', '2025-10-09');
INSERT INTO public.customer VALUES (507, 'Hilly', '172-655-8150', 'hstow7@privacy.gov.au', '2026-04-28');
INSERT INTO public.customer VALUES (508, 'Kingston', '601-227-7290', 'kaveries8@unblog.fr', '2026-02-11');
INSERT INTO public.customer VALUES (509, 'Nydia', '315-912-5265', 'ntebbett9@mtv.com', '2025-12-03');
INSERT INTO public.customer VALUES (510, 'Abagael', '384-792-3814', 'adicarlia@examiner.com', '2025-10-31');
INSERT INTO public.customer VALUES (511, 'Danya', '969-660-6469', 'dtuminib@army.mil', '2026-02-11');
INSERT INTO public.customer VALUES (512, 'Leo', '704-304-8726', 'ledwickc@istockphoto.com', '2026-01-02');
INSERT INTO public.customer VALUES (513, 'Natalina', '746-936-1909', 'ncurstond@blogger.com', '2025-11-27');
INSERT INTO public.customer VALUES (514, 'Rosalia', '743-111-3744', 'rryleye@earthlink.net', '2026-02-09');
INSERT INTO public.customer VALUES (515, 'Hynda', '470-387-2459', 'hcarslawf@myspace.com', '2025-11-28');
INSERT INTO public.customer VALUES (516, 'Violette', '749-940-3479', 'vspittleg@arizona.edu', '2025-07-12');
INSERT INTO public.customer VALUES (517, 'Lisa', '127-124-2577', 'lcourageh@cnn.com', '2025-09-22');
INSERT INTO public.customer VALUES (518, 'Zorina', '236-927-2263', 'zbanticki@google.es', '2025-11-26');
INSERT INTO public.customer VALUES (519, 'Victoria', '884-348-2201', 'vclaypoolj@google.co.jp', '2026-01-07');
INSERT INTO public.customer VALUES (520, 'Kai', '680-464-1400', 'kgurleyk@walmart.com', '2025-07-11');
INSERT INTO public.customer VALUES (521, 'Catherina', '455-284-9198', 'cpaddemorel@upenn.edu', '2026-01-09');
INSERT INTO public.customer VALUES (522, 'Godard', '889-129-6412', 'gverbrugghenm@github.com', '2026-03-15');
INSERT INTO public.customer VALUES (523, 'Simmonds', '241-311-3438', 'smarcroftn@utexas.edu', '2026-01-27');
INSERT INTO public.customer VALUES (524, 'Beatrisa', '281-418-0270', 'bproudlero@bbb.org', '2025-12-10');
INSERT INTO public.customer VALUES (525, 'Ashia', '621-692-3000', 'astrydep@ehow.com', '2026-02-04');
INSERT INTO public.customer VALUES (526, 'Giselle', '735-365-4884', 'gloramq@mozilla.com', '2025-08-22');
INSERT INTO public.customer VALUES (527, 'Alma', '229-912-5715', 'achurchingr@domainmarket.com', '2026-02-20');
INSERT INTO public.customer VALUES (528, 'Morrie', '835-733-9488', 'mkurtiss@youku.com', '2026-03-28');
INSERT INTO public.customer VALUES (529, 'Shannah', '733-225-4656', 'sfloatt@bloglines.com', '2026-02-13');
INSERT INTO public.customer VALUES (530, 'Salmon', '995-885-1599', 'sbrecheru@cdc.gov', '2025-12-04');
INSERT INTO public.customer VALUES (531, 'Keary', '547-957-4197', 'kstainbridgev@vistaprint.com', '2025-08-11');
INSERT INTO public.customer VALUES (532, 'Olivette', '600-343-8154', 'ogerkensw@miitbeian.gov.cn', '2025-11-18');
INSERT INTO public.customer VALUES (533, 'Dosi', '367-408-0615', 'dmccurtinx@discuz.net', '2026-01-14');
INSERT INTO public.customer VALUES (534, 'Christiana', '405-326-8720', 'cgarnhamy@jiathis.com', '2025-09-08');
INSERT INTO public.customer VALUES (535, 'Lorin', '358-895-8190', 'lseagoz@uol.com.br', '2026-01-27');
INSERT INTO public.customer VALUES (536, 'Aidan', '918-177-8716', 'athorrington10@multiply.com', '2025-09-28');
INSERT INTO public.customer VALUES (537, 'Edouard', '401-302-6107', 'eparriss11@lulu.com', '2025-07-01');
INSERT INTO public.customer VALUES (538, 'Desmund', '777-620-8156', 'dmcvane12@earthlink.net', '2025-12-16');
INSERT INTO public.customer VALUES (539, 'Darlleen', '531-647-9700', 'dprobets13@miibeian.gov.cn', '2026-04-13');
INSERT INTO public.customer VALUES (540, 'Broddie', '325-459-0790', 'bjessup14@stanford.edu', '2025-09-25');
INSERT INTO public.customer VALUES (541, 'Mureil', '300-542-2153', 'mblaydes15@theatlantic.com', '2026-01-18');
INSERT INTO public.customer VALUES (542, 'Steffie', '990-148-4210', 'sbark16@ucsd.edu', '2026-02-08');
INSERT INTO public.customer VALUES (543, 'Meade', '801-168-1941', 'mhawler17@dyndns.org', '2025-10-14');
INSERT INTO public.customer VALUES (544, 'Reena', '669-106-6652', 'rcordall18@example.com', '2025-12-05');
INSERT INTO public.customer VALUES (545, 'Killian', '915-350-5529', 'kkitchen19@i2i.jp', '2026-02-04');
INSERT INTO public.customer VALUES (546, 'Ira', '224-138-8847', 'iholttom1a@archive.org', '2026-04-08');
INSERT INTO public.customer VALUES (547, 'Karel', '474-346-9137', 'kdelorenzo1b@friendfeed.com', '2025-10-13');
INSERT INTO public.customer VALUES (548, 'Neda', '654-555-1776', 'nfolger1c@buzzfeed.com', '2026-03-26');
INSERT INTO public.customer VALUES (549, 'Dominica', '730-932-3906', 'dfenney1d@t.co', '2025-10-15');
INSERT INTO public.customer VALUES (550, 'Janot', '894-940-8817', 'jrandall1e@bing.com', '2025-09-03');
INSERT INTO public.customer VALUES (551, 'Melly', '816-547-0277', 'mliebrecht1f@economist.com', '2025-06-08');
INSERT INTO public.customer VALUES (552, 'Roley', '590-689-0462', 'rfice1g@blog.com', '2025-07-19');
INSERT INTO public.customer VALUES (553, 'Ozzie', '948-521-5483', 'olindner1h@bloglines.com', '2026-03-14');
INSERT INTO public.customer VALUES (554, 'Ernst', '371-976-7420', 'efollos1i@barnesandnoble.com', '2026-02-18');
INSERT INTO public.customer VALUES (555, 'Barnett', '495-682-8382', 'bdungee1j@rakuten.co.jp', '2026-02-15');
INSERT INTO public.customer VALUES (556, 'Aryn', '253-790-5391', 'amaunders1k@creativecommons.org', '2025-09-16');
INSERT INTO public.customer VALUES (557, 'Lydon', '811-830-7713', 'lmedlicott1l@diigo.com', '2026-02-18');
INSERT INTO public.customer VALUES (558, 'Marcello', '662-192-0994', 'mrehme1m@feedburner.com', '2025-06-23');
INSERT INTO public.customer VALUES (559, 'Bernhard', '770-606-5348', 'bfortey1n@paypal.com', '2026-02-02');
INSERT INTO public.customer VALUES (560, 'Carce', '882-321-3624', 'ccoppenhall1o@chicagotribune.com', '2025-08-08');
INSERT INTO public.customer VALUES (561, 'Bastien', '444-768-6848', 'bsaer1p@ca.gov', '2026-01-14');
INSERT INTO public.customer VALUES (562, 'Ingra', '827-765-2331', 'ibernardeau1q@sciencedirect.com', '2025-12-20');
INSERT INTO public.customer VALUES (563, 'Luella', '962-991-2428', 'lgrimoldby1r@yelp.com', '2025-09-22');
INSERT INTO public.customer VALUES (564, 'Berti', '385-943-6883', 'bfettes1s@youtu.be', '2026-04-04');
INSERT INTO public.customer VALUES (565, 'Berky', '490-903-6421', 'bgodilington1t@pbs.org', '2026-02-01');
INSERT INTO public.customer VALUES (566, 'Marion', '433-379-5012', 'mhanhart1u@deviantart.com', '2026-03-23');
INSERT INTO public.customer VALUES (567, 'Paola', '305-234-0687', 'pwoollard1v@so-net.ne.jp', '2025-11-24');
INSERT INTO public.customer VALUES (568, 'Jan', '694-266-6286', 'jteape1w@answers.com', '2026-04-30');
INSERT INTO public.customer VALUES (569, 'Lenard', '634-872-1714', 'lingledow1x@etsy.com', '2026-03-13');
INSERT INTO public.customer VALUES (570, 'Alexina', '580-569-9695', 'aslyman1y@fema.gov', '2025-12-10');
INSERT INTO public.customer VALUES (571, 'Konstanze', '123-523-8986', 'kbootman1z@tinyurl.com', '2025-09-02');
INSERT INTO public.customer VALUES (572, 'Freeland', '852-892-4988', 'fmacrory20@google.fr', '2026-04-14');
INSERT INTO public.customer VALUES (573, 'Bonnie', '732-963-8358', 'bbracco21@wix.com', '2026-04-26');
INSERT INTO public.customer VALUES (574, 'Adora', '214-180-6500', 'abaudi22@nationalgeographic.com', '2025-10-25');
INSERT INTO public.customer VALUES (575, 'Delphinia', '495-588-3261', 'divakhin23@disqus.com', '2026-04-20');
INSERT INTO public.customer VALUES (576, 'Keith', '696-280-9327', 'kdury24@amazon.co.uk', '2025-09-08');
INSERT INTO public.customer VALUES (577, 'Salaidh', '486-755-7018', 'sebdon25@dion.ne.jp', '2025-09-03');
INSERT INTO public.customer VALUES (578, 'Leela', '970-406-9297', 'lhargey26@free.fr', '2025-12-15');
INSERT INTO public.customer VALUES (579, 'Franz', '454-951-8477', 'frumming27@marketwatch.com', '2026-01-13');
INSERT INTO public.customer VALUES (580, 'Doug', '517-838-6864', 'dtemprell28@last.fm', '2025-12-28');
INSERT INTO public.customer VALUES (581, 'Eveline', '893-656-1051', 'ekyncl29@artisteer.com', '2026-04-06');
INSERT INTO public.customer VALUES (582, 'Hillard', '181-777-1046', 'hharg2a@tumblr.com', '2025-11-27');
INSERT INTO public.customer VALUES (583, 'Alexandr', '831-476-4697', 'abarlas2b@state.tx.us', '2025-06-03');
INSERT INTO public.customer VALUES (584, 'Sean', '623-771-8329', 'sstannus2c@typepad.com', '2025-09-06');
INSERT INTO public.customer VALUES (585, 'Pauline', '912-327-7178', 'pdeeming2d@nationalgeographic.com', '2026-01-11');
INSERT INTO public.customer VALUES (586, 'Jacquelyn', '701-465-0174', 'jsacco2e@dot.gov', '2026-04-03');
INSERT INTO public.customer VALUES (587, 'Daisey', '237-412-6098', 'dclarson2f@cnet.com', '2026-04-05');
INSERT INTO public.customer VALUES (588, 'Alejoa', '348-713-6538', 'ascrafton2g@salon.com', '2025-09-03');
INSERT INTO public.customer VALUES (589, 'Nannie', '439-210-1610', 'nbygott2h@eventbrite.com', '2025-11-14');
INSERT INTO public.customer VALUES (590, 'Nicolette', '550-859-1004', 'nlamplugh2i@time.com', '2025-12-09');
INSERT INTO public.customer VALUES (591, 'Haskel', '967-584-5341', 'hfendlen2j@shareasale.com', '2026-02-07');
INSERT INTO public.customer VALUES (592, 'Nicolina', '194-806-9517', 'nwildt2k@cmu.edu', '2025-12-22');
INSERT INTO public.customer VALUES (593, 'Crosby', '183-292-5021', 'cenderby2l@microsoft.com', '2025-09-07');
INSERT INTO public.customer VALUES (594, 'Ilyse', '206-999-4103', 'ivedntyev2m@dmoz.org', '2025-12-19');
INSERT INTO public.customer VALUES (595, 'Delilah', '672-615-3185', 'dwillgoss2n@un.org', '2025-06-15');
INSERT INTO public.customer VALUES (596, 'Giacomo', '300-221-1141', 'gkildea2o@blogspot.com', '2026-05-08');
INSERT INTO public.customer VALUES (597, 'Jory', '565-675-6030', 'jshilliday2p@hugedomains.com', '2025-12-11');
INSERT INTO public.customer VALUES (598, 'Avrom', '124-241-1233', 'areichartz2q@wp.com', '2025-12-05');
INSERT INTO public.customer VALUES (599, 'Lona', '188-196-7882', 'ljosebury2r@nba.com', '2025-12-11');
INSERT INTO public.customer VALUES (600, 'Granthem', '978-193-3723', 'gprecious2s@goo.gl', '2025-09-22');
INSERT INTO public.customer VALUES (601, 'Michele', '461-145-0338', 'mspincke2t@businessweek.com', '2026-01-23');
INSERT INTO public.customer VALUES (602, 'Cherin', '789-827-6269', 'cgudger2u@army.mil', '2025-09-15');
INSERT INTO public.customer VALUES (603, 'Tommie', '216-986-5549', 'tkingsnode2v@businessinsider.com', '2026-04-27');
INSERT INTO public.customer VALUES (604, 'Edgard', '630-970-0032', 'emacadie2w@admin.ch', '2025-05-26');
INSERT INTO public.customer VALUES (605, 'Katharyn', '406-268-2995', 'ksmither2x@harvard.edu', '2025-12-18');
INSERT INTO public.customer VALUES (606, 'Andrei', '668-549-5167', 'abartosek2y@meetup.com', '2025-09-10');
INSERT INTO public.customer VALUES (607, 'Gilbert', '516-583-6508', 'ghearmon2z@hibu.com', '2025-12-08');
INSERT INTO public.customer VALUES (608, 'Cornelius', '682-191-9369', 'cboag30@guardian.co.uk', '2025-06-11');
INSERT INTO public.customer VALUES (609, 'Kenn', '302-715-4061', 'kion31@independent.co.uk', '2026-04-11');
INSERT INTO public.customer VALUES (610, 'Christiano', '974-947-8740', 'ccausley32@is.gd', '2025-10-02');
INSERT INTO public.customer VALUES (611, 'Gerianna', '602-840-6503', 'gbenbow33@answers.com', '2026-05-03');
INSERT INTO public.customer VALUES (612, 'Hermann', '753-439-7059', 'htaudevin34@statcounter.com', '2025-06-30');
INSERT INTO public.customer VALUES (613, 'Selinda', '687-577-2320', 'svolett35@java.com', '2025-06-18');
INSERT INTO public.customer VALUES (614, 'Marsiella', '284-626-6240', 'mdoogood36@sciencedaily.com', '2025-08-30');
INSERT INTO public.customer VALUES (615, 'Fayina', '632-939-1327', 'fhirsch37@surveymonkey.com', '2025-10-11');
INSERT INTO public.customer VALUES (616, 'Jolynn', '430-432-2733', 'jtams38@reddit.com', '2026-04-08');
INSERT INTO public.customer VALUES (617, 'Myca', '165-905-6052', 'mbottrell39@columbia.edu', '2025-12-19');
INSERT INTO public.customer VALUES (618, 'Channa', '682-750-8825', 'cbreakey3a@studiopress.com', '2026-04-07');
INSERT INTO public.customer VALUES (619, 'Moore', '980-401-4852', 'melement3b@phpbb.com', '2025-08-30');
INSERT INTO public.customer VALUES (620, 'Darda', '477-936-4112', 'dlux3c@comcast.net', '2025-12-24');
INSERT INTO public.customer VALUES (621, 'Ad', '915-511-8602', 'agard3d@thetimes.co.uk', '2025-11-02');
INSERT INTO public.customer VALUES (622, 'Cornela', '704-996-2357', 'cfrancello3e@homestead.com', '2026-03-19');
INSERT INTO public.customer VALUES (623, 'Hy', '969-971-5508', 'hcremer3f@uol.com.br', '2025-09-12');
INSERT INTO public.customer VALUES (624, 'Kristal', '876-393-1417', 'kekins3g@nature.com', '2026-03-27');
INSERT INTO public.customer VALUES (625, 'Andriette', '981-810-4153', 'akeay3h@howstuffworks.com', '2025-07-16');
INSERT INTO public.customer VALUES (626, 'Kattie', '329-874-7507', 'ksellor3i@bigcartel.com', '2026-05-24');
INSERT INTO public.customer VALUES (627, 'Mirna', '567-601-1576', 'mlettuce3j@twitpic.com', '2025-10-21');
INSERT INTO public.customer VALUES (628, 'Emmott', '847-179-4430', 'esantos3k@nba.com', '2025-10-20');
INSERT INTO public.customer VALUES (629, 'Paula', '367-390-6059', 'praccio3l@alibaba.com', '2025-11-25');
INSERT INTO public.customer VALUES (630, 'Nataniel', '855-950-4440', 'nblench3m@blogger.com', '2025-08-04');
INSERT INTO public.customer VALUES (631, 'Mufi', '673-445-4927', 'mtumilty3n@mashable.com', '2025-11-27');
INSERT INTO public.customer VALUES (632, 'Charlena', '113-213-7716', 'cscotland3o@weather.com', '2026-03-20');
INSERT INTO public.customer VALUES (633, 'Christalle', '596-479-8305', 'cparton3p@naver.com', '2025-10-06');
INSERT INTO public.customer VALUES (634, 'Brig', '107-161-6265', 'bgrzelczyk3q@biglobe.ne.jp', '2026-02-25');
INSERT INTO public.customer VALUES (635, 'Bancroft', '710-417-5490', 'bvandriel3r@unesco.org', '2025-11-11');
INSERT INTO public.customer VALUES (636, 'Dorthy', '216-537-1100', 'dglave3s@purevolume.com', '2026-01-02');
INSERT INTO public.customer VALUES (637, 'Edvard', '230-477-8594', 'ehallagan3t@google.com', '2025-08-13');
INSERT INTO public.customer VALUES (638, 'Clemens', '196-204-0150', 'cstoppard3u@theatlantic.com', '2025-08-07');
INSERT INTO public.customer VALUES (639, 'Gypsy', '856-166-2797', 'gleakner3v@mac.com', '2025-11-15');
INSERT INTO public.customer VALUES (640, 'Claudius', '270-991-7099', 'cvittle3w@odnoklassniki.ru', '2025-10-04');
INSERT INTO public.customer VALUES (641, 'Stan', '830-329-7463', 'selkington3x@surveymonkey.com', '2025-09-07');
INSERT INTO public.customer VALUES (642, 'Eleonore', '791-839-2673', 'ehirsch3y@issuu.com', '2025-12-12');
INSERT INTO public.customer VALUES (643, 'Olga', '343-633-3003', 'obasillon3z@toplist.cz', '2025-09-20');
INSERT INTO public.customer VALUES (644, 'Claudie', '682-945-4578', 'cghost40@amazon.co.uk', '2025-11-10');
INSERT INTO public.customer VALUES (645, 'Margaret', '119-895-1490', 'mmcvane41@smugmug.com', '2025-09-10');
INSERT INTO public.customer VALUES (646, 'Walsh', '397-976-3871', 'wmaxwaile42@icq.com', '2026-03-06');
INSERT INTO public.customer VALUES (647, 'Sisile', '634-444-6143', 'sriglesford43@reuters.com', '2025-08-22');
INSERT INTO public.customer VALUES (648, 'Keir', '152-276-4267', 'kgreenfield44@hatena.ne.jp', '2026-02-23');
INSERT INTO public.customer VALUES (649, 'Leonid', '221-261-4027', 'lleckey45@fc2.com', '2026-04-24');
INSERT INTO public.customer VALUES (650, 'Spence', '390-528-6480', 'sshipp46@biglobe.ne.jp', '2025-12-05');
INSERT INTO public.customer VALUES (651, 'Ivory', '376-198-9472', 'iharpur47@etsy.com', '2025-08-31');
INSERT INTO public.customer VALUES (652, 'Latisha', '812-262-2206', 'lstaining48@networkadvertising.org', '2026-05-11');
INSERT INTO public.customer VALUES (653, 'Marleen', '366-370-9176', 'mditer49@fc2.com', '2025-09-09');
INSERT INTO public.customer VALUES (654, 'Sylvester', '881-620-3056', 'stodor4a@deviantart.com', '2025-08-05');
INSERT INTO public.customer VALUES (655, 'Georges', '198-442-9081', 'gboorn4b@aol.com', '2025-10-15');
INSERT INTO public.customer VALUES (656, 'Consuelo', '359-743-1944', 'cmostin4c@washington.edu', '2026-01-19');
INSERT INTO public.customer VALUES (657, 'Alexina', '125-767-7744', 'acescot4d@eepurl.com', '2026-03-16');
INSERT INTO public.customer VALUES (658, 'Klemens', '589-642-8851', 'krolfini4e@infoseek.co.jp', '2026-05-14');
INSERT INTO public.customer VALUES (659, 'Ashley', '528-450-9535', 'ainnis4f@cnet.com', '2025-08-31');
INSERT INTO public.customer VALUES (660, 'Cyril', '274-894-1101', 'cglinde4g@cafepress.com', '2025-10-03');
INSERT INTO public.customer VALUES (661, 'Ashil', '963-947-3887', 'atarrier4h@google.com.hk', '2026-02-02');
INSERT INTO public.customer VALUES (662, 'Webb', '169-946-6424', 'warenson4i@mtv.com', '2025-12-03');
INSERT INTO public.customer VALUES (663, 'Ramon', '618-353-2558', 'rbockett4j@biblegateway.com', '2025-09-19');
INSERT INTO public.customer VALUES (664, 'Erminie', '813-948-1936', 'erome4k@icio.us', '2025-12-03');
INSERT INTO public.customer VALUES (665, 'Jenni', '301-229-3901', 'jborleace4l@mayoclinic.com', '2026-04-01');
INSERT INTO public.customer VALUES (666, 'Iggy', '984-432-9840', 'iboyett4m@mac.com', '2025-07-12');
INSERT INTO public.customer VALUES (667, 'Berny', '126-820-9415', 'bvolette4n@plala.or.jp', '2026-04-13');
INSERT INTO public.customer VALUES (668, 'Juanita', '521-208-8272', 'jlinggood4o@cnbc.com', '2025-07-09');
INSERT INTO public.customer VALUES (669, 'Amalea', '758-994-1132', 'abielby4p@1und1.de', '2025-12-17');
INSERT INTO public.customer VALUES (670, 'Modestine', '182-845-8878', 'mguitt4q@youtube.com', '2026-04-18');
INSERT INTO public.customer VALUES (671, 'Pauly', '326-691-5121', 'pdennehy4r@ca.gov', '2025-09-09');
INSERT INTO public.customer VALUES (672, 'Robinia', '551-668-0102', 'rbenian4s@etsy.com', '2025-12-04');
INSERT INTO public.customer VALUES (673, 'Tiphany', '346-136-3496', 'tsanders4t@unicef.org', '2026-02-09');
INSERT INTO public.customer VALUES (674, 'Gwenora', '994-804-5837', 'gbasilio4u@woothemes.com', '2026-01-01');
INSERT INTO public.customer VALUES (675, 'Lilly', '257-702-7850', 'lthomtson4v@wiley.com', '2026-04-23');
INSERT INTO public.customer VALUES (676, 'Vern', '266-664-3358', 'vox4w@sogou.com', '2025-12-06');
INSERT INTO public.customer VALUES (677, 'Holt', '175-782-9173', 'hkondratyuk4x@163.com', '2026-03-04');
INSERT INTO public.customer VALUES (678, 'Kalina', '393-344-7562', 'ktewkesberrie4y@cmu.edu', '2025-06-04');
INSERT INTO public.customer VALUES (679, 'Korey', '141-969-6144', 'kwheelwright4z@ebay.co.uk', '2025-06-20');
INSERT INTO public.customer VALUES (680, 'Gavrielle', '242-250-4610', 'gheinlein50@smugmug.com', '2025-12-10');
INSERT INTO public.customer VALUES (681, 'Domingo', '866-510-7531', 'dfarfoot51@china.com.cn', '2025-08-27');
INSERT INTO public.customer VALUES (682, 'Yance', '648-421-5930', 'ygovett52@topsy.com', '2025-07-14');
INSERT INTO public.customer VALUES (683, 'Elvira', '779-588-1128', 'ehurburt53@home.pl', '2025-06-12');
INSERT INTO public.customer VALUES (684, 'Cordy', '601-642-5721', 'ceccott54@blinklist.com', '2025-09-12');
INSERT INTO public.customer VALUES (685, 'Finlay', '403-270-5988', 'fstitson55@unblog.fr', '2025-07-08');
INSERT INTO public.customer VALUES (686, 'Clywd', '592-738-4215', 'cmcsperron56@com.com', '2026-05-01');
INSERT INTO public.customer VALUES (687, 'Stephi', '402-411-1783', 'spasque57@go.com', '2025-09-10');
INSERT INTO public.customer VALUES (688, 'Maude', '931-886-2036', 'mpedrielli58@yahoo.com', '2025-12-23');
INSERT INTO public.customer VALUES (689, 'Gorden', '872-605-5672', 'gosgorby59@cloudflare.com', '2025-12-05');
INSERT INTO public.customer VALUES (690, 'Leena', '391-993-0953', 'lbirdsey5a@g.co', '2025-12-26');
INSERT INTO public.customer VALUES (691, 'Alexandrina', '229-988-8504', 'agonsalvo5b@oracle.com', '2026-02-08');
INSERT INTO public.customer VALUES (692, 'Gretna', '563-604-3611', 'gpeteri5c@xing.com', '2025-12-14');
INSERT INTO public.customer VALUES (693, 'Free', '532-639-1717', 'fdomb5d@redcross.org', '2026-02-16');
INSERT INTO public.customer VALUES (694, 'Vannie', '204-711-4307', 'vbaumford5e@smh.com.au', '2026-05-21');
INSERT INTO public.customer VALUES (695, 'Simonette', '352-694-4700', 'scasari5f@slideshare.net', '2025-09-19');
INSERT INTO public.customer VALUES (696, 'Kathleen', '233-837-3241', 'kleleu5g@smh.com.au', '2025-06-22');
INSERT INTO public.customer VALUES (697, 'Elianora', '662-238-4667', 'emaccole5h@techcrunch.com', '2025-06-21');
INSERT INTO public.customer VALUES (698, 'Horatio', '541-192-7005', 'hbarzen5i@icq.com', '2026-04-20');
INSERT INTO public.customer VALUES (699, 'Gilly', '310-347-2274', 'ggorsse5j@1688.com', '2025-10-23');
INSERT INTO public.customer VALUES (700, 'Cozmo', '303-400-2368', 'cbolam5k@auda.org.au', '2026-01-07');
INSERT INTO public.customer VALUES (701, 'Bianca', '250-722-5967', 'bodney5l@msu.edu', '2025-12-31');
INSERT INTO public.customer VALUES (702, 'Helyn', '241-955-1444', 'hyouings5m@google.ru', '2026-02-06');
INSERT INTO public.customer VALUES (703, 'Mirabella', '845-636-6108', 'mwilliamson5n@de.vu', '2025-10-05');
INSERT INTO public.customer VALUES (704, 'Meier', '454-205-2668', 'mmowat5o@etsy.com', '2026-03-13');
INSERT INTO public.customer VALUES (705, 'Ondrea', '528-546-7461', 'ocumberlidge5p@spiegel.de', '2025-07-03');
INSERT INTO public.customer VALUES (706, 'Lena', '796-248-4552', 'lharriss5q@sogou.com', '2026-03-06');
INSERT INTO public.customer VALUES (707, 'Fulvia', '620-597-9073', 'fgullick5r@ycombinator.com', '2025-11-28');
INSERT INTO public.customer VALUES (708, 'Charisse', '570-724-9256', 'cburfoot5s@etsy.com', '2025-09-11');
INSERT INTO public.customer VALUES (709, 'Faustina', '140-652-8309', 'fklaussen5t@mediafire.com', '2025-11-18');
INSERT INTO public.customer VALUES (710, 'Valentina', '611-539-4662', 'vpyer5u@scribd.com', '2026-01-10');
INSERT INTO public.customer VALUES (711, 'Frannie', '163-300-4687', 'fleyrroyd5v@slate.com', '2025-07-27');
INSERT INTO public.customer VALUES (712, 'Ethelyn', '166-738-9254', 'efoston5w@wiley.com', '2026-05-17');
INSERT INTO public.customer VALUES (713, 'Myrvyn', '910-757-2997', 'mpurvis5x@scribd.com', '2025-06-14');
INSERT INTO public.customer VALUES (714, 'Cecelia', '231-652-4115', 'crackstraw5y@princeton.edu', '2025-09-24');
INSERT INTO public.customer VALUES (715, 'Demetria', '950-366-8292', 'dcammish5z@51.la', '2026-01-13');
INSERT INTO public.customer VALUES (716, 'Morissa', '136-249-2672', 'mportwaine60@msu.edu', '2025-08-08');
INSERT INTO public.customer VALUES (717, 'Beale', '519-251-1548', 'bizkovicz61@slate.com', '2025-12-23');
INSERT INTO public.customer VALUES (718, 'Wade', '216-172-1525', 'wbeecham62@ucla.edu', '2026-03-06');
INSERT INTO public.customer VALUES (719, 'Valera', '565-814-5537', 'vlarrett63@fotki.com', '2026-01-08');
INSERT INTO public.customer VALUES (720, 'Kelsy', '605-764-3594', 'kbrettor64@irs.gov', '2026-02-11');
INSERT INTO public.customer VALUES (721, 'Nanni', '701-257-4682', 'nwellbeloved65@bloomberg.com', '2026-02-11');
INSERT INTO public.customer VALUES (722, 'Veronica', '878-679-2641', 'vbouzek66@artisteer.com', '2025-09-15');
INSERT INTO public.customer VALUES (723, 'Ilka', '294-519-3165', 'iroderham67@hostgator.com', '2025-09-01');
INSERT INTO public.customer VALUES (724, 'Cicely', '470-781-6778', 'cocurrane68@seesaa.net', '2025-09-04');
INSERT INTO public.customer VALUES (725, 'Orsola', '124-576-5336', 'ocarayol69@sourceforge.net', '2026-01-03');
INSERT INTO public.customer VALUES (726, 'Jessica', '926-302-9599', 'jslade6a@cpanel.net', '2025-06-10');
INSERT INTO public.customer VALUES (727, 'Collete', '781-431-7393', 'chedderly6b@ca.gov', '2026-01-15');
INSERT INTO public.customer VALUES (728, 'Wheeler', '916-113-2680', 'wminter6c@weebly.com', '2025-10-10');
INSERT INTO public.customer VALUES (729, 'Sabra', '235-705-6672', 'smachans6d@hexun.com', '2025-10-23');
INSERT INTO public.customer VALUES (730, 'Darcey', '850-926-3755', 'dbrayson6e@msu.edu', '2026-03-24');
INSERT INTO public.customer VALUES (731, 'Kelley', '729-442-2397', 'kgeraghty6f@google.es', '2025-10-31');
INSERT INTO public.customer VALUES (732, 'Arlin', '743-894-2210', 'acapponeer6g@sogou.com', '2025-12-10');
INSERT INTO public.customer VALUES (733, 'Grissel', '434-570-3034', 'gmurtagh6h@deliciousdays.com', '2025-07-03');
INSERT INTO public.customer VALUES (734, 'Brooke', '462-749-2482', 'bslewcock6i@bbc.co.uk', '2025-11-04');
INSERT INTO public.customer VALUES (735, 'Selie', '490-451-7706', 'stomich6j@umich.edu', '2026-04-06');
INSERT INTO public.customer VALUES (736, 'Lonnie', '929-990-1562', 'lsmedmore6k@squidoo.com', '2025-08-25');
INSERT INTO public.customer VALUES (737, 'Karon', '476-268-0039', 'kpache6l@so-net.ne.jp', '2026-02-16');
INSERT INTO public.customer VALUES (738, 'Evania', '314-294-2728', 'elanyon6m@seesaa.net', '2026-01-25');
INSERT INTO public.customer VALUES (739, 'Lilly', '130-235-0408', 'lmorshead6n@google.cn', '2025-06-19');
INSERT INTO public.customer VALUES (740, 'Meaghan', '880-125-6155', 'mocuddie6o@alibaba.com', '2025-12-13');
INSERT INTO public.customer VALUES (741, 'Cassey', '637-649-8222', 'csherborne6p@cdbaby.com', '2026-01-06');
INSERT INTO public.customer VALUES (742, 'Coreen', '222-301-7479', 'cellacott6q@msn.com', '2025-12-22');
INSERT INTO public.customer VALUES (743, 'Willetta', '130-685-5932', 'wmccarrell6r@google.com.au', '2025-11-27');
INSERT INTO public.customer VALUES (744, 'Lorettalorna', '524-227-5727', 'lhitchens6s@dell.com', '2026-03-16');
INSERT INTO public.customer VALUES (745, 'Priscella', '948-954-5312', 'ppea6t@myspace.com', '2025-08-24');
INSERT INTO public.customer VALUES (746, 'Enoch', '359-390-9863', 'emcginnell6u@i2i.jp', '2026-03-12');
INSERT INTO public.customer VALUES (747, 'Bernetta', '252-332-3354', 'beaston6v@symantec.com', '2025-09-19');
INSERT INTO public.customer VALUES (748, 'Rudolph', '542-987-9067', 'rfulford6w@alexa.com', '2025-11-04');
INSERT INTO public.customer VALUES (749, 'Pietrek', '671-733-8916', 'phouten6x@wiley.com', '2025-05-28');
INSERT INTO public.customer VALUES (750, 'Adey', '218-430-4293', 'ajest6y@slashdot.org', '2025-07-06');
INSERT INTO public.customer VALUES (751, 'Dallon', '492-671-7503', 'dcarnie6z@ft.com', '2025-10-15');
INSERT INTO public.customer VALUES (752, 'Krystalle', '318-343-0084', 'kcraigs70@weibo.com', '2025-09-27');
INSERT INTO public.customer VALUES (753, 'Barnie', '655-857-5228', 'bskotcher71@geocities.com', '2026-03-22');
INSERT INTO public.customer VALUES (754, 'Brittan', '866-954-2308', 'bdanielian72@upenn.edu', '2025-08-31');
INSERT INTO public.customer VALUES (755, 'Wynn', '703-147-0617', 'whanscomb73@nature.com', '2025-12-14');
INSERT INTO public.customer VALUES (756, 'Dicky', '433-292-0796', 'dloveday74@umn.edu', '2025-08-09');
INSERT INTO public.customer VALUES (757, 'Cornela', '652-876-4441', 'cdumpleton75@mail.ru', '2025-09-12');
INSERT INTO public.customer VALUES (758, 'Gus', '551-901-6678', 'ghacquard76@sohu.com', '2026-03-31');
INSERT INTO public.customer VALUES (759, 'Birgitta', '601-693-1570', 'btupling77@freewebs.com', '2026-04-20');
INSERT INTO public.customer VALUES (760, 'Rossy', '118-477-3992', 'ralfonzo78@squidoo.com', '2025-09-05');
INSERT INTO public.customer VALUES (761, 'Ashli', '346-232-5161', 'acaneo79@ycombinator.com', '2025-12-18');
INSERT INTO public.customer VALUES (762, 'Janel', '890-223-9056', 'jkordt7a@hibu.com', '2025-07-16');
INSERT INTO public.customer VALUES (763, 'Urban', '173-430-3671', 'udennis7b@cnet.com', '2026-03-31');
INSERT INTO public.customer VALUES (764, 'Brena', '421-948-3930', 'browantree7c@dropbox.com', '2026-03-25');
INSERT INTO public.customer VALUES (765, 'Lelah', '353-708-1185', 'ljedrys7d@ameblo.jp', '2026-05-03');
INSERT INTO public.customer VALUES (766, 'Kimbell', '333-499-6045', 'kpahl7e@hc360.com', '2025-06-13');
INSERT INTO public.customer VALUES (767, 'Galven', '552-349-4818', 'gdefew7f@statcounter.com', '2026-04-13');
INSERT INTO public.customer VALUES (768, 'Byrom', '891-773-7243', 'bolagene7g@chicagotribune.com', '2025-12-24');
INSERT INTO public.customer VALUES (769, 'Baxy', '384-990-6898', 'bdyball7h@ox.ac.uk', '2025-09-11');
INSERT INTO public.customer VALUES (770, 'Liana', '692-648-5257', 'lvonhagt7i@shutterfly.com', '2026-03-30');
INSERT INTO public.customer VALUES (771, 'Llewellyn', '377-287-0663', 'ltreby7j@blinklist.com', '2026-05-20');
INSERT INTO public.customer VALUES (772, 'Gard', '339-624-9884', 'gchurchman7k@netvibes.com', '2026-01-27');
INSERT INTO public.customer VALUES (773, 'Ayn', '761-158-5246', 'adilkes7l@comcast.net', '2026-04-25');
INSERT INTO public.customer VALUES (774, 'Gare', '852-737-6032', 'gheustace7m@theglobeandmail.com', '2026-04-22');
INSERT INTO public.customer VALUES (775, 'Vita', '793-114-8048', 'vfenning7n@typepad.com', '2025-06-10');
INSERT INTO public.customer VALUES (776, 'Robbie', '348-950-7153', 'rroly7o@kickstarter.com', '2025-08-23');
INSERT INTO public.customer VALUES (777, 'Annissa', '914-101-5629', 'astileman7p@bigcartel.com', '2026-04-18');
INSERT INTO public.customer VALUES (778, 'Howey', '596-361-4501', 'hgedge7q@chronoengine.com', '2025-09-07');
INSERT INTO public.customer VALUES (779, 'Neron', '407-507-0421', 'njimmison7r@bluehost.com', '2025-08-16');
INSERT INTO public.customer VALUES (780, 'Truda', '641-381-1689', 'tmccrow7s@so-net.ne.jp', '2026-04-27');
INSERT INTO public.customer VALUES (781, 'Cathryn', '933-986-6763', 'cbizley7t@posterous.com', '2025-08-27');
INSERT INTO public.customer VALUES (782, 'Lenna', '806-944-7314', 'lchaloner7u@flickr.com', '2025-12-20');
INSERT INTO public.customer VALUES (783, 'Wat', '994-449-6256', 'whembrow7v@artisteer.com', '2025-07-28');
INSERT INTO public.customer VALUES (784, 'Artus', '951-807-5011', 'akepp7w@slideshare.net', '2025-11-23');
INSERT INTO public.customer VALUES (785, 'Gretna', '368-500-5432', 'gralfe7x@php.net', '2026-03-28');
INSERT INTO public.customer VALUES (786, 'Sara', '893-203-9988', 'sbenedettini7y@instagram.com', '2025-08-28');
INSERT INTO public.customer VALUES (787, 'Rodrique', '300-523-6001', 'rcoppard7z@buzzfeed.com', '2025-08-25');
INSERT INTO public.customer VALUES (788, 'Calvin', '499-262-0742', 'cjumeau80@github.com', '2025-10-18');
INSERT INTO public.customer VALUES (789, 'Giraldo', '808-612-5815', 'gwastling81@mlb.com', '2025-08-25');
INSERT INTO public.customer VALUES (790, 'Melisenda', '568-971-8733', 'mtym82@mayoclinic.com', '2025-06-25');
INSERT INTO public.customer VALUES (791, 'Bearnard', '564-631-6861', 'bdanilewicz83@clickbank.net', '2025-08-22');
INSERT INTO public.customer VALUES (792, 'Bradney', '549-275-2343', 'bpirot84@a8.net', '2026-04-15');
INSERT INTO public.customer VALUES (793, 'Durand', '909-599-3373', 'dcohane85@amazonaws.com', '2026-01-23');
INSERT INTO public.customer VALUES (794, 'Selby', '257-736-6357', 'shawkings86@arizona.edu', '2026-05-10');
INSERT INTO public.customer VALUES (795, 'Muhammad', '935-488-9390', 'mduchasteau87@discuz.net', '2025-11-26');
INSERT INTO public.customer VALUES (796, 'Stella', '666-341-2307', 'sord88@shutterfly.com', '2025-12-06');
INSERT INTO public.customer VALUES (797, 'Bonny', '689-600-5222', 'bdarton89@nymag.com', '2025-07-31');
INSERT INTO public.customer VALUES (798, 'Maynord', '605-365-3296', 'mjeroch8a@tinyurl.com', '2025-09-08');
INSERT INTO public.customer VALUES (799, 'Carney', '641-917-8179', 'cjepperson8b@soup.io', '2026-01-08');
INSERT INTO public.customer VALUES (800, 'Audre', '567-393-6973', 'agulleford8c@upenn.edu', '2025-11-26');
INSERT INTO public.customer VALUES (801, 'Rosina', '556-730-9218', 'rhoofe8d@scribd.com', '2025-07-13');
INSERT INTO public.customer VALUES (802, 'Kimberlee', '991-501-0491', 'ksanchiz8e@seattletimes.com', '2025-10-16');
INSERT INTO public.customer VALUES (803, 'Brandtr', '642-904-1957', 'brubbens8f@bizjournals.com', '2025-12-01');
INSERT INTO public.customer VALUES (804, 'Elvis', '999-695-5944', 'etuckett8g@ovh.net', '2026-01-29');
INSERT INTO public.customer VALUES (805, 'Cassaundra', '871-884-2860', 'cattridge8h@theatlantic.com', '2025-06-30');
INSERT INTO public.customer VALUES (806, 'Bibbie', '168-797-6735', 'bkliche8i@joomla.org', '2026-04-02');
INSERT INTO public.customer VALUES (807, 'Robers', '145-775-9896', 'ribell8j@geocities.jp', '2025-07-16');
INSERT INTO public.customer VALUES (808, 'Shaughn', '131-190-1338', 'smaletratt8k@go.com', '2025-11-30');
INSERT INTO public.customer VALUES (809, 'Devonna', '363-858-3152', 'djorgensen8l@weather.com', '2025-11-13');
INSERT INTO public.customer VALUES (810, 'Gustav', '213-414-0051', 'gpfaff8m@bravesites.com', '2026-04-19');
INSERT INTO public.customer VALUES (811, 'Austine', '195-790-7757', 'aridgwell8n@clickbank.net', '2026-02-23');
INSERT INTO public.customer VALUES (812, 'Thedric', '391-880-0313', 'tvanyushin8o@wisc.edu', '2025-12-01');
INSERT INTO public.customer VALUES (813, 'Ethel', '547-924-7209', 'ecarman8p@sbwire.com', '2025-06-19');
INSERT INTO public.customer VALUES (814, 'Shana', '465-624-1858', 'slogsdale8q@harvard.edu', '2025-10-23');
INSERT INTO public.customer VALUES (815, 'Laura', '523-433-1283', 'lkaines8r@tripadvisor.com', '2025-11-30');
INSERT INTO public.customer VALUES (816, 'Beret', '169-407-8502', 'bhackney8s@prnewswire.com', '2026-01-10');
INSERT INTO public.customer VALUES (817, 'Jamey', '757-432-7830', 'jsimao8t@blogs.com', '2025-11-13');
INSERT INTO public.customer VALUES (818, 'Coleman', '570-929-7085', 'cmanagh8u@japanpost.jp', '2025-10-01');
INSERT INTO public.customer VALUES (819, 'Freddie', '112-803-6177', 'fkippins8v@tamu.edu', '2026-03-16');
INSERT INTO public.customer VALUES (820, 'Veronique', '828-907-9891', 'vmandres8w@clickbank.net', '2026-03-03');
INSERT INTO public.customer VALUES (821, 'Tadeas', '458-568-4770', 'tmaher8x@sfgate.com', '2025-08-18');
INSERT INTO public.customer VALUES (822, 'Shelden', '470-491-0076', 'sringrose8y@imdb.com', '2025-06-15');
INSERT INTO public.customer VALUES (823, 'Pat', '159-487-7055', 'pmcnea8z@cbslocal.com', '2026-05-16');
INSERT INTO public.customer VALUES (824, 'Beatrisa', '606-753-5758', 'bcoggell90@mlb.com', '2025-07-05');
INSERT INTO public.customer VALUES (825, 'Myrtice', '103-228-3062', 'mtorbeck91@bbc.co.uk', '2026-03-14');
INSERT INTO public.customer VALUES (826, 'Elinor', '453-744-0193', 'efraniak92@yellowpages.com', '2026-01-05');
INSERT INTO public.customer VALUES (827, 'Marina', '852-812-8704', 'myurmanovev93@bluehost.com', '2025-11-13');
INSERT INTO public.customer VALUES (828, 'Nealon', '611-329-2954', 'nteliga94@whitehouse.gov', '2026-04-01');
INSERT INTO public.customer VALUES (829, 'Yolane', '461-282-9700', 'yglencrash95@imageshack.us', '2025-06-17');
INSERT INTO public.customer VALUES (830, 'Danyelle', '643-169-1712', 'dousley96@microsoft.com', '2026-02-20');
INSERT INTO public.customer VALUES (831, 'Melody', '949-459-4908', 'mrosenblatt97@gnu.org', '2025-09-09');
INSERT INTO public.customer VALUES (832, 'Simmonds', '562-123-9627', 'slenney98@state.tx.us', '2025-10-08');
INSERT INTO public.customer VALUES (833, 'Ryley', '716-617-2722', 'rbull99@hibu.com', '2026-05-23');
INSERT INTO public.customer VALUES (834, 'Gay', '472-979-7106', 'gsparshutt9a@state.tx.us', '2025-12-03');
INSERT INTO public.customer VALUES (835, 'Ulrich', '300-343-2669', 'uimlaw9b@i2i.jp', '2025-06-25');
INSERT INTO public.customer VALUES (836, 'Chlo', '351-730-0195', 'crilton9c@exblog.jp', '2025-10-15');
INSERT INTO public.customer VALUES (837, 'Cherilynn', '715-250-4835', 'cpridden9d@sohu.com', '2026-03-05');
INSERT INTO public.customer VALUES (838, 'Corbett', '794-159-7552', 'clindholm9e@multiply.com', '2025-12-31');
INSERT INTO public.customer VALUES (839, 'Cozmo', '943-258-4563', 'cdammarell9f@earthlink.net', '2026-04-16');
INSERT INTO public.customer VALUES (840, 'Carlotta', '745-473-4147', 'cwagnerin9g@digg.com', '2025-06-06');
INSERT INTO public.customer VALUES (841, 'Niki', '257-119-6588', 'nmackneis9h@nbcnews.com', '2026-05-13');
INSERT INTO public.customer VALUES (842, 'Vale', '724-863-1470', 'vcoskerry9i@icq.com', '2026-02-05');
INSERT INTO public.customer VALUES (843, 'Ivett', '907-779-7846', 'ishoulder9j@phoca.cz', '2026-03-13');
INSERT INTO public.customer VALUES (844, 'Grace', '171-479-7792', 'gbustin9k@smugmug.com', '2025-08-24');
INSERT INTO public.customer VALUES (845, 'Lavena', '795-236-7989', 'ltutill9l@imdb.com', '2026-05-07');
INSERT INTO public.customer VALUES (846, 'Bradan', '856-140-8898', 'btommasi9m@t-online.de', '2025-10-13');
INSERT INTO public.customer VALUES (847, 'Benni', '381-529-1598', 'brailton9n@statcounter.com', '2026-03-01');
INSERT INTO public.customer VALUES (848, 'Homere', '984-175-9267', 'hdowyer9o@constantcontact.com', '2025-11-16');
INSERT INTO public.customer VALUES (849, 'Pepito', '335-707-0301', 'pfountain9p@lycos.com', '2026-02-15');
INSERT INTO public.customer VALUES (850, 'Huntley', '915-569-9754', 'htamlett9q@nsw.gov.au', '2026-03-09');
INSERT INTO public.customer VALUES (851, 'Jenda', '704-967-0168', 'jmontgomery9r@w3.org', '2026-04-21');
INSERT INTO public.customer VALUES (852, 'Shelby', '978-317-3135', 'sdeaves9s@tumblr.com', '2026-05-22');
INSERT INTO public.customer VALUES (853, 'Sisile', '759-826-8828', 'sstidworthy9t@earthlink.net', '2026-03-13');
INSERT INTO public.customer VALUES (854, 'Yanaton', '201-719-4524', 'ysanches9u@addthis.com', '2025-07-11');
INSERT INTO public.customer VALUES (855, 'Beltran', '176-149-5209', 'bhorburgh9v@bloglines.com', '2025-09-20');
INSERT INTO public.customer VALUES (856, 'Teresita', '469-725-6126', 'tpinnell9w@irs.gov', '2025-10-22');
INSERT INTO public.customer VALUES (857, 'Milzie', '249-466-8771', 'mkeener9x@cbsnews.com', '2026-01-21');
INSERT INTO public.customer VALUES (858, 'Donielle', '862-119-9602', 'dmelchior9y@mozilla.com', '2026-05-07');
INSERT INTO public.customer VALUES (859, 'Levy', '418-870-3410', 'lgrishagin9z@fda.gov', '2026-05-24');
INSERT INTO public.customer VALUES (860, 'Shandy', '896-671-3096', 'sparisa0@stanford.edu', '2025-06-24');
INSERT INTO public.customer VALUES (861, 'Francisco', '621-121-2563', 'fparsalla1@pcworld.com', '2025-07-08');
INSERT INTO public.customer VALUES (862, 'Gal', '127-232-1539', 'ginnetta2@pen.io', '2026-03-06');
INSERT INTO public.customer VALUES (863, 'Ky', '388-571-0266', 'ktreffrya3@nasa.gov', '2025-07-13');
INSERT INTO public.customer VALUES (864, 'Ashlie', '760-465-8952', 'amoncarra4@usa.gov', '2025-08-03');
INSERT INTO public.customer VALUES (865, 'Leigh', '360-170-3149', 'lstilesa5@fc2.com', '2025-06-16');
INSERT INTO public.customer VALUES (866, 'Titus', '507-367-0915', 'teptona6@oracle.com', '2026-01-08');
INSERT INTO public.customer VALUES (867, 'Pedro', '159-436-1078', 'prubartellia7@bing.com', '2025-10-11');
INSERT INTO public.customer VALUES (868, 'Ricki', '345-124-1264', 'rbrilla8@abc.net.au', '2026-01-19');
INSERT INTO public.customer VALUES (869, 'Burke', '833-615-1485', 'bferria9@abc.net.au', '2025-11-25');
INSERT INTO public.customer VALUES (870, 'Ivette', '712-271-1799', 'idumbrallaa@reddit.com', '2025-07-30');
INSERT INTO public.customer VALUES (871, 'Germain', '633-101-1098', 'gjukubczakab@addtoany.com', '2025-08-26');
INSERT INTO public.customer VALUES (872, 'Bambi', '850-684-6606', 'bbuntenac@hostgator.com', '2026-01-30');
INSERT INTO public.customer VALUES (873, 'Sioux', '546-921-6069', 'sstapleyad@zimbio.com', '2025-12-13');
INSERT INTO public.customer VALUES (874, 'Virgie', '275-853-4296', 'varnetae@miitbeian.gov.cn', '2026-02-16');
INSERT INTO public.customer VALUES (875, 'Kristel', '391-781-1100', 'kmosdellaf@cbc.ca', '2025-10-02');
INSERT INTO public.customer VALUES (876, 'Uri', '354-346-6744', 'utewkesberryag@redcross.org', '2025-09-17');
INSERT INTO public.customer VALUES (877, 'Babbie', '216-416-2246', 'bhowisah@weibo.com', '2025-07-27');
INSERT INTO public.customer VALUES (878, 'Abram', '615-943-9844', 'agillianai@miibeian.gov.cn', '2025-06-09');
INSERT INTO public.customer VALUES (879, 'Katina', '878-875-6216', 'kponnsettaj@jugem.jp', '2025-11-19');
INSERT INTO public.customer VALUES (880, 'Wallas', '441-252-9221', 'wsommerak@bing.com', '2025-08-02');
INSERT INTO public.customer VALUES (881, 'Prissie', '354-925-0396', 'preubelal@blogger.com', '2026-03-23');
INSERT INTO public.customer VALUES (882, 'Wald', '993-721-8772', 'wsnellmanam@jiathis.com', '2025-11-24');
INSERT INTO public.customer VALUES (883, 'Persis', '813-463-2897', 'pmcgillivriean@dagondesign.com', '2025-05-26');
INSERT INTO public.customer VALUES (884, 'Wilmette', '596-210-5957', 'wradbornao@bandcamp.com', '2026-04-05');
INSERT INTO public.customer VALUES (885, 'Burlie', '664-576-5367', 'baikenheadap@github.com', '2025-08-11');
INSERT INTO public.customer VALUES (886, 'Paul', '158-768-1879', 'pgreallyaq@t.co', '2025-07-21');
INSERT INTO public.customer VALUES (887, 'Ambrosi', '403-539-0773', 'abeamondar@businessinsider.com', '2026-01-14');
INSERT INTO public.customer VALUES (888, 'Ezmeralda', '398-388-8658', 'esymonesas@quantcast.com', '2025-12-30');
INSERT INTO public.customer VALUES (889, 'Karlene', '221-716-7051', 'kmardellat@multiply.com', '2025-08-24');
INSERT INTO public.customer VALUES (890, 'Marcello', '133-611-7441', 'mcayfordau@is.gd', '2026-01-10');
INSERT INTO public.customer VALUES (891, 'Haze', '823-851-2504', 'hrosav@cpanel.net', '2025-10-13');
INSERT INTO public.customer VALUES (892, 'Kalindi', '749-337-5940', 'kportingaleaw@washington.edu', '2025-08-08');
INSERT INTO public.customer VALUES (893, 'Anstice', '615-899-7281', 'aodowlingax@biglobe.ne.jp', '2025-06-18');
INSERT INTO public.customer VALUES (894, 'Nefen', '318-818-1270', 'nrubinowiczay@geocities.jp', '2026-04-24');
INSERT INTO public.customer VALUES (895, 'Sylvia', '839-936-2797', 'stithecoteaz@businessweek.com', '2026-04-07');
INSERT INTO public.customer VALUES (896, 'Clary', '534-843-7065', 'calldisb0@prlog.org', '2025-11-05');
INSERT INTO public.customer VALUES (897, 'Gilles', '624-498-3937', 'gtwineb1@webeden.co.uk', '2025-11-07');
INSERT INTO public.customer VALUES (898, 'Avis', '319-581-4483', 'awholesworthb2@disqus.com', '2026-04-16');
INSERT INTO public.customer VALUES (899, 'Barthel', '532-186-4658', 'bdanzeyb3@ucoz.ru', '2025-06-22');
INSERT INTO public.customer VALUES (900, 'Tammie', '558-294-9027', 'tyepiskopovb4@uol.com.br', '2026-03-26');
INSERT INTO public.customer VALUES (901, 'Alix', '894-850-8100', 'abarrsb5@dmoz.org', '2025-08-18');
INSERT INTO public.customer VALUES (902, 'Leese', '213-147-7481', 'lbaileyb6@hc360.com', '2026-02-28');
INSERT INTO public.customer VALUES (903, 'Jeremias', '122-524-7635', 'jsevilleb7@w3.org', '2026-01-29');
INSERT INTO public.customer VALUES (904, 'Millicent', '654-136-3677', 'mdeathb8@alexa.com', '2026-02-15');
INSERT INTO public.customer VALUES (905, 'Lacey', '311-822-5646', 'lpellingb9@geocities.jp', '2025-12-30');
INSERT INTO public.customer VALUES (906, 'Mikkel', '368-231-3106', 'mharmarba@github.io', '2026-05-22');
INSERT INTO public.customer VALUES (907, 'Claire', '898-840-7648', 'cbirtonshawbb@reference.com', '2025-11-20');
INSERT INTO public.customer VALUES (908, 'Conan', '669-757-1842', 'cwrettumbc@domainmarket.com', '2026-04-14');
INSERT INTO public.customer VALUES (909, 'Myra', '868-517-0104', 'mgudyerbd@walmart.com', '2026-04-01');
INSERT INTO public.customer VALUES (910, 'Tammie', '537-314-6044', 'tmacgallbe@archive.org', '2026-05-08');
INSERT INTO public.customer VALUES (911, 'Quentin', '613-502-0783', 'qjewerbf@dell.com', '2026-05-02');
INSERT INTO public.customer VALUES (912, 'Sheree', '757-370-9268', 'socurrinebg@ucoz.ru', '2026-03-23');
INSERT INTO public.customer VALUES (913, 'Fanya', '985-329-9051', 'fgrisleybh@usda.gov', '2026-05-04');
INSERT INTO public.customer VALUES (914, 'Ario', '650-817-3026', 'arodderbi@dot.gov', '2025-08-25');
INSERT INTO public.customer VALUES (915, 'Peria', '938-321-8395', 'palldisbj@usgs.gov', '2026-05-21');
INSERT INTO public.customer VALUES (916, 'Halley', '669-862-8636', 'hanniesbk@bbc.co.uk', '2025-06-30');
INSERT INTO public.customer VALUES (917, 'Tate', '422-367-7915', 'trutiglianobl@google.co.jp', '2026-01-05');
INSERT INTO public.customer VALUES (918, 'Marti', '789-358-3236', 'mormesherbm@google.de', '2025-08-31');
INSERT INTO public.customer VALUES (919, 'Cirillo', '135-813-1486', 'ctegellerbn@bluehost.com', '2025-12-31');
INSERT INTO public.customer VALUES (920, 'Cull', '490-918-2788', 'cmcneilbo@princeton.edu', '2025-07-21');
INSERT INTO public.customer VALUES (921, 'Teodora', '315-831-2294', 'thurrionbp@eventbrite.com', '2026-03-11');
INSERT INTO public.customer VALUES (922, 'Tarrah', '817-204-6606', 'tamissbq@chronoengine.com', '2025-09-09');
INSERT INTO public.customer VALUES (923, 'Casey', '818-201-8715', 'cfinlaterbr@reference.com', '2025-09-28');
INSERT INTO public.customer VALUES (924, 'Jasper', '812-264-3251', 'jspourebs@ca.gov', '2025-06-06');
INSERT INTO public.customer VALUES (925, 'Minor', '603-340-5082', 'mscutterbt@hc360.com', '2025-11-04');
INSERT INTO public.customer VALUES (926, 'Claudette', '722-392-5454', 'ctaguebu@indiatimes.com', '2025-09-26');
INSERT INTO public.customer VALUES (927, 'Gerri', '911-685-0392', 'glongbonebv@simplemachines.org', '2025-07-05');
INSERT INTO public.customer VALUES (928, 'Alice', '333-344-9435', 'afautleybw@slate.com', '2026-01-12');
INSERT INTO public.customer VALUES (929, 'Hally', '393-329-6059', 'hteapebx@mac.com', '2026-03-19');
INSERT INTO public.customer VALUES (930, 'Ronda', '559-504-2510', 'rmcginnellby@about.me', '2025-10-13');
INSERT INTO public.customer VALUES (931, 'Dosi', '941-632-4368', 'dbaggarleybz@com.com', '2026-03-15');
INSERT INTO public.customer VALUES (932, 'Janey', '325-133-1278', 'jcockliec0@google.it', '2026-03-24');
INSERT INTO public.customer VALUES (933, 'Karalee', '612-679-1696', 'ksouthernwoodc1@yandex.ru', '2026-05-01');
INSERT INTO public.customer VALUES (934, 'Norean', '209-840-7817', 'nrenonc2@cpanel.net', '2026-01-07');
INSERT INTO public.customer VALUES (935, 'Roda', '492-120-4266', 'rturbaynec3@about.com', '2025-06-02');
INSERT INTO public.customer VALUES (936, 'Virgina', '280-599-9379', 'vskiplornec4@woothemes.com', '2025-08-21');
INSERT INTO public.customer VALUES (937, 'Ambur', '300-386-3752', 'amondayc5@hatena.ne.jp', '2025-12-08');
INSERT INTO public.customer VALUES (938, 'Yuri', '278-146-8956', 'yalthropec6@sbwire.com', '2025-09-24');
INSERT INTO public.customer VALUES (939, 'Ivie', '715-706-5332', 'ipickupc7@amazon.de', '2026-04-30');
INSERT INTO public.customer VALUES (940, 'Carlie', '515-708-5632', 'cbartolaccic8@godaddy.com', '2025-09-30');
INSERT INTO public.customer VALUES (941, 'Pierce', '693-551-4777', 'ppeasegodc9@themeforest.net', '2025-07-09');
INSERT INTO public.customer VALUES (942, 'Anita', '861-523-1392', 'asackeyca@hc360.com', '2025-11-18');
INSERT INTO public.customer VALUES (943, 'Faber', '875-905-4134', 'fpaalcb@furl.net', '2025-12-04');
INSERT INTO public.customer VALUES (944, 'Orlando', '376-527-1206', 'okauschercc@tuttocitta.it', '2025-07-24');
INSERT INTO public.customer VALUES (945, 'Marisa', '540-653-0561', 'mwoodwardcd@hatena.ne.jp', '2026-05-15');
INSERT INTO public.customer VALUES (946, 'Lyda', '206-814-4580', 'lmccrackance@columbia.edu', '2025-10-24');
INSERT INTO public.customer VALUES (947, 'Marven', '842-844-9126', 'mheusticecf@geocities.com', '2026-02-04');
INSERT INTO public.customer VALUES (948, 'Tallou', '871-636-6564', 'tgreatrakescg@miitbeian.gov.cn', '2026-02-13');
INSERT INTO public.customer VALUES (949, 'Kala', '198-737-0170', 'kdeakinsch@army.mil', '2025-06-14');
INSERT INTO public.customer VALUES (950, 'Panchito', '127-618-5485', 'pnieseci@csmonitor.com', '2026-02-04');
INSERT INTO public.customer VALUES (951, 'Alexandra', '302-880-5984', 'arouchcj@si.edu', '2025-09-09');
INSERT INTO public.customer VALUES (952, 'Byron', '848-570-5450', 'bporsonck@nyu.edu', '2026-02-05');
INSERT INTO public.customer VALUES (953, 'Appolonia', '856-525-1505', 'ahelecl@go.com', '2025-11-03');
INSERT INTO public.customer VALUES (954, 'Prudy', '346-817-7366', 'pmallowscm@free.fr', '2025-11-28');
INSERT INTO public.customer VALUES (955, 'Quinn', '739-861-4404', 'qhamberscn@ning.com', '2026-03-16');
INSERT INTO public.customer VALUES (956, 'Remington', '365-644-0266', 'rmcorkilco@istockphoto.com', '2026-05-18');
INSERT INTO public.customer VALUES (957, 'Ulick', '858-480-1899', 'ufettiplacecp@xing.com', '2025-09-26');
INSERT INTO public.customer VALUES (958, 'Rodina', '386-853-7481', 'rjacmarcq@slate.com', '2025-11-19');
INSERT INTO public.customer VALUES (959, 'Dukey', '567-667-8584', 'dparisocr@digg.com', '2025-10-26');
INSERT INTO public.customer VALUES (960, 'Irena', '178-698-5993', 'itroddencs@bandcamp.com', '2026-01-09');
INSERT INTO public.customer VALUES (961, 'Burty', '208-149-2051', 'bivanikovct@fc2.com', '2025-11-02');
INSERT INTO public.customer VALUES (962, 'Tammy', '995-792-3170', 'thullycu@wp.com', '2026-04-18');
INSERT INTO public.customer VALUES (963, 'Hanan', '195-856-3156', 'hbalfrecv@wufoo.com', '2026-04-29');
INSERT INTO public.customer VALUES (964, 'Tracee', '978-630-0541', 'tumbertcw@google.co.uk', '2025-08-21');
INSERT INTO public.customer VALUES (965, 'Nels', '598-405-3364', 'nrudgardcx@so-net.ne.jp', '2025-06-10');
INSERT INTO public.customer VALUES (966, 'Bentley', '807-711-3009', 'bdurdlecy@sciencedaily.com', '2025-07-30');
INSERT INTO public.customer VALUES (967, 'Aggie', '115-189-6578', 'asutworthcz@dmoz.org', '2025-06-28');
INSERT INTO public.customer VALUES (968, 'Harriette', '610-684-2979', 'hvaled0@diigo.com', '2025-06-03');
INSERT INTO public.customer VALUES (969, 'Millisent', '977-590-2846', 'malyokhind1@flavors.me', '2025-10-07');
INSERT INTO public.customer VALUES (970, 'Dorie', '468-309-3959', 'dtoftsd2@businessweek.com', '2026-02-07');
INSERT INTO public.customer VALUES (971, 'Mikol', '951-367-2202', 'mbowied3@webeden.co.uk', '2026-01-23');
INSERT INTO public.customer VALUES (972, 'Roderigo', '244-330-7944', 'rluxend4@blogtalkradio.com', '2025-07-07');
INSERT INTO public.customer VALUES (973, 'Tressa', '845-385-8069', 'tdiperausd5@mtv.com', '2026-04-16');
INSERT INTO public.customer VALUES (974, 'Nadine', '694-110-3409', 'nwellandd6@homestead.com', '2025-06-10');
INSERT INTO public.customer VALUES (975, 'Westley', '202-245-3647', 'wbelmontd7@unblog.fr', '2025-07-25');
INSERT INTO public.customer VALUES (976, 'Kora', '689-714-1097', 'kmutimerd8@slate.com', '2026-02-28');
INSERT INTO public.customer VALUES (977, 'Findlay', '581-818-9010', 'fkilbeed9@dailymotion.com', '2025-11-26');
INSERT INTO public.customer VALUES (978, 'Emmet', '557-485-5708', 'etollandda@opera.com', '2026-05-11');
INSERT INTO public.customer VALUES (979, 'Addy', '934-855-8165', 'amcdaiddb@who.int', '2026-05-24');
INSERT INTO public.customer VALUES (980, 'Bettye', '805-940-9131', 'blinseydc@sakura.ne.jp', '2025-10-21');
INSERT INTO public.customer VALUES (981, 'Catie', '220-889-3754', 'cschoolcroftdd@blog.com', '2025-07-24');
INSERT INTO public.customer VALUES (982, 'Adamo', '389-557-6184', 'avedeneevde@wordpress.org', '2025-08-09');
INSERT INTO public.customer VALUES (983, 'Glenda', '599-253-4017', 'gcoltondf@moonfruit.com', '2025-09-10');
INSERT INTO public.customer VALUES (984, 'Demott', '241-611-1342', 'djillinsdg@rediff.com', '2025-12-14');
INSERT INTO public.customer VALUES (985, 'Kassia', '368-877-3933', 'kdaveydh@epa.gov', '2025-09-05');
INSERT INTO public.customer VALUES (986, 'Vally', '532-530-3625', 'vgreenhousedi@nifty.com', '2025-09-29');
INSERT INTO public.customer VALUES (987, 'Prue', '255-256-8225', 'pjeroschdj@patch.com', '2025-07-26');
INSERT INTO public.customer VALUES (988, 'Laverna', '905-681-1298', 'lmacnaughtondk@acquirethisname.com', '2026-01-04');
INSERT INTO public.customer VALUES (989, 'Alma', '735-385-8838', 'adodmandl@odnoklassniki.ru', '2025-12-13');
INSERT INTO public.customer VALUES (990, 'Siouxie', '256-728-9634', 'sgarcidm@theglobeandmail.com', '2026-04-29');
INSERT INTO public.customer VALUES (991, 'Barnie', '925-544-3248', 'bdrewesdn@godaddy.com', '2025-11-28');
INSERT INTO public.customer VALUES (992, 'Marquita', '313-384-3963', 'mspurrittdo@blogger.com', '2025-07-07');
INSERT INTO public.customer VALUES (993, 'Kayla', '794-320-0504', 'kpetrikdp@mtv.com', '2026-02-11');
INSERT INTO public.customer VALUES (994, 'Jessi', '194-431-3063', 'jrappaportdq@ifeng.com', '2025-09-07');
INSERT INTO public.customer VALUES (995, 'Kerrill', '452-367-8730', 'ktreverdr@digg.com', '2025-07-24');
INSERT INTO public.customer VALUES (996, 'Homer', '248-513-4927', 'heyckelbergds@elegantthemes.com', '2025-06-16');
INSERT INTO public.customer VALUES (997, 'Xylia', '173-932-1582', 'xscrivenordt@addthis.com', '2025-05-30');
INSERT INTO public.customer VALUES (998, 'Adella', '975-904-9137', 'abartolozzidu@sina.com.cn', '2025-05-26');
INSERT INTO public.customer VALUES (999, 'Garvy', '927-502-0608', 'gvanderstraatendv@wisc.edu', '2026-05-15');


--
-- TOC entry 3536 (class 0 OID 32952)
-- Dependencies: 220
-- Data for Name: difficultylevel; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.difficultylevel VALUES (1, 'Easy');
INSERT INTO public.difficultylevel VALUES (2, 'Moderate');
INSERT INTO public.difficultylevel VALUES (3, 'Challenging');
INSERT INTO public.difficultylevel VALUES (4, 'Hard');
INSERT INTO public.difficultylevel VALUES (5, 'Extreme');
INSERT INTO public.difficultylevel VALUES (6, 'Family Friendly');
INSERT INTO public.difficultylevel VALUES (7, 'Beginner');
INSERT INTO public.difficultylevel VALUES (8, 'Intermediate');
INSERT INTO public.difficultylevel VALUES (9, 'Advanced');
INSERT INTO public.difficultylevel VALUES (10, 'Expert');
INSERT INTO public.difficultylevel VALUES (11, 'Toddler Safe');
INSERT INTO public.difficultylevel VALUES (12, 'Senior Friendly');
INSERT INTO public.difficultylevel VALUES (13, 'Technical');
INSERT INTO public.difficultylevel VALUES (14, 'Professional');
INSERT INTO public.difficultylevel VALUES (15, 'Level 1');
INSERT INTO public.difficultylevel VALUES (16, 'Level 2');
INSERT INTO public.difficultylevel VALUES (17, 'Level 3');
INSERT INTO public.difficultylevel VALUES (18, 'Level 4');
INSERT INTO public.difficultylevel VALUES (19, 'Level 5');
INSERT INTO public.difficultylevel VALUES (20, 'Master');


--
-- TOC entry 3535 (class 0 OID 32935)
-- Dependencies: 219
-- Data for Name: guide; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.guide VALUES (3, 'David', 'Israeli', '050-3333333', 'david@gmail.com', '1978-11-20', '2010-02-25', 600.00, 15, 5.00, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (4, 'Sarah', 'Blau', '050-4444444', 'sarah@gmail.com', '1992-07-30', '2020-09-01', 400.00, 3, 4.20, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (5, 'Ron', 'Shahar', '050-5555555', 'ron@gmail.com', '1988-01-05', '2016-04-10', 520.00, 8, 4.70, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (6, 'Dana', 'Tal', '050-6666666', 'dana@gmail.com', '1995-12-12', '2021-01-15', 380.00, 2, 4.00, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (7, 'Avi', 'Mizrahi', '050-7777777', 'avi@gmail.com', '1982-08-08', '2012-05-05', 550.00, 12, 4.90, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (8, 'Noa', 'Katz', '050-8888888', 'noa@gmail.com', '1991-04-22', '2019-02-28', 430.00, 5, 4.40, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (9, 'Itay', 'Barak', '050-9999999', 'itay@gmail.com', '1980-02-14', '2011-11-11', 580.00, 13, 4.80, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (10, 'Maya', 'Golan', '052-1111111', 'maya@gmail.com', '1993-10-10', '2022-03-01', 350.00, 1, 3.90, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (11, 'Erez', 'Harel', '052-2222222', 'erez@gmail.com', '1984-06-06', '2014-07-07', 510.00, 10, 4.60, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (12, 'Adi', 'Friedman', '052-3333333', 'adi@gmail.com', '1989-09-09', '2017-08-08', 470.00, 7, 4.50, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (13, 'Omer', 'Dahan', '052-4444444', 'omer@gmail.com', '1986-05-25', '2015-12-12', 490.00, 9, 4.30, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (14, 'Gal', 'Avni', '052-5555555', 'gal@gmail.com', '1994-01-20', '2020-05-05', 410.00, 4, 4.10, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (15, 'Amit', 'Sela', '052-6666666', 'amit@gmail.com', '1981-12-30', '2013-02-02', 560.00, 11, 4.90, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (16, 'Shir', 'Agmon', '052-7777777', 'shir@gmail.com', '1996-03-03', '2022-11-11', 360.00, 1, 4.00, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (17, 'Nir', 'Bassan', '052-8888888', 'nir@gmail.com', '1975-04-18', '2005-06-01', 700.00, 20, 5.00, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (18, 'Liat', 'Ziv', '052-9999999', 'liat@gmail.com', '1987-07-07', '2016-10-10', 500.00, 8, 4.60, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (19, 'Tomer', 'Ben-Ari', '053-1111111', 'tomer@gmail.com', '1990-08-15', '2018-01-01', 440.00, 6, 4.40, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (20, 'Roni', 'Erez', '053-2222222', 'roni@gmail.com', '1993-02-02', '2021-09-09', 390.00, 3, 4.20, NULL, NULL, 'General Hiking');
INSERT INTO public.guide VALUES (2, 'Michal', 'Levi', '050-2222222', 'michal@gmail.com', '1990-03-15', '2018-06-12', 450.00, 6, 4.50, NULL, NULL, 'Desert Hiking');
INSERT INTO public.guide VALUES (1, 'Yossi', 'Cohen', '050-1111111', 'yossi@gmail.com', '1985-05-10', '2015-01-01', 500.00, 10, 4.80, NULL, NULL, 'Desert Hiking');


--
-- TOC entry 3539 (class 0 OID 32983)
-- Dependencies: 223
-- Data for Name: guidedtour; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.guidedtour VALUES (1, '2024-05-01', NULL, NULL, NULL, 'Masada Entrance', 150.00, 20, NULL, 1, 1, 1);
INSERT INTO public.guidedtour VALUES (3, '2024-05-10', NULL, NULL, NULL, 'Haifa University', 100.00, 25, NULL, 1, 3, 3);
INSERT INTO public.guidedtour VALUES (4, '2024-05-12', NULL, NULL, NULL, 'Habima Square', 80.00, 30, NULL, 1, 4, 4);
INSERT INTO public.guidedtour VALUES (5, '2024-05-15', NULL, NULL, NULL, 'Eilat Canyon Site', 200.00, 10, NULL, 1, 5, 5);
INSERT INTO public.guidedtour VALUES (6, '2024-06-01', NULL, NULL, NULL, 'Majdal Shams', 250.00, 12, NULL, 1, 6, 6);
INSERT INTO public.guidedtour VALUES (7, '2024-06-02', NULL, NULL, NULL, 'Jaffa Gate', 90.00, 40, NULL, 1, 7, 7);
INSERT INTO public.guidedtour VALUES (8, '2024-06-03', NULL, NULL, NULL, 'Ein Gedi Kiosk', 110.00, 20, NULL, 1, 8, 8);
INSERT INTO public.guidedtour VALUES (9, '2024-06-05', NULL, NULL, NULL, 'Migdal Village', 140.00, 15, NULL, 1, 9, 9);
INSERT INTO public.guidedtour VALUES (10, '2024-06-07', NULL, NULL, NULL, 'Mount Tabor Base', 130.00, 18, NULL, 1, 10, 10);
INSERT INTO public.guidedtour VALUES (11, '2024-06-10', NULL, NULL, NULL, 'Banias Springs', 115.00, 22, NULL, 1, 11, 11);
INSERT INTO public.guidedtour VALUES (12, '2024-06-15', NULL, NULL, NULL, 'Visitor Center Ramon', 180.00, 14, NULL, 1, 12, 12);
INSERT INTO public.guidedtour VALUES (13, '2024-06-20', NULL, NULL, NULL, 'Hula Main Gate', 95.00, 35, NULL, 1, 13, 13);
INSERT INTO public.guidedtour VALUES (14, '2024-06-25', NULL, NULL, NULL, 'Mitzpe Hila', 160.00, 20, NULL, 1, 14, 14);
INSERT INTO public.guidedtour VALUES (15, '2024-07-01', NULL, NULL, NULL, 'Sataf Parking', 105.00, 25, NULL, 1, 15, 15);
INSERT INTO public.guidedtour VALUES (16, '2024-07-05', NULL, NULL, NULL, 'Hermon Lower Base', 300.00, 8, NULL, 1, 16, 16);
INSERT INTO public.guidedtour VALUES (17, '2024-07-10', NULL, NULL, NULL, 'National Park Entrance', 125.00, 30, NULL, 1, 17, 17);
INSERT INTO public.guidedtour VALUES (18, '2024-07-15', NULL, NULL, NULL, 'Kibbutz Yehiam', 135.00, 15, NULL, 1, 18, 18);
INSERT INTO public.guidedtour VALUES (19, '2024-07-20', NULL, NULL, NULL, 'Turtle Bridge', 85.00, 40, NULL, 1, 19, 19);
INSERT INTO public.guidedtour VALUES (20, '2024-07-25', NULL, NULL, NULL, 'Beit Jann', 155.00, 18, NULL, 1, 20, 20);
INSERT INTO public.guidedtour VALUES (2, '2024-05-05', NULL, NULL, NULL, 'Ein Gedi Parking', 120.00, 15, NULL, 1, 1, 2);
INSERT INTO public.guidedtour VALUES (999, '2026-06-01', '2026-06-05', NULL, NULL, 'Main Gate', 450.00, 20, NULL, 1, 1, 1);


--
-- TOC entry 3544 (class 0 OID 33067)
-- Dependencies: 228
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.payment VALUES (1, '2024-04-01', 150.00, NULL, 'Credit Card', NULL, 1, 3);
INSERT INTO public.payment VALUES (2, '2024-04-02', 120.00, NULL, 'PayPal', NULL, 2, 3);
INSERT INTO public.payment VALUES (3, '2024-04-03', 100.00, NULL, 'Cash', NULL, 3, 3);
INSERT INTO public.payment VALUES (4, '2024-04-04', 40.00, NULL, 'Credit Card', NULL, 4, 2);
INSERT INTO public.payment VALUES (5, '2024-04-05', 200.00, NULL, 'Bank Transfer', NULL, 5, 3);
INSERT INTO public.payment VALUES (6, '2024-04-10', 250.00, NULL, 'Credit Card', NULL, 6, 3);
INSERT INTO public.payment VALUES (7, '2024-04-11', 90.00, NULL, 'PayPal', NULL, 7, 3);
INSERT INTO public.payment VALUES (8, '2024-04-12', 110.00, NULL, 'Cash', NULL, 8, 3);
INSERT INTO public.payment VALUES (9, '2024-04-15', 0.00, NULL, 'Credit Card', NULL, 9, 1);
INSERT INTO public.payment VALUES (10, '2024-04-16', 130.00, NULL, 'Bank Transfer', NULL, 10, 3);
INSERT INTO public.payment VALUES (11, '2024-04-17', 115.00, NULL, 'Credit Card', NULL, 11, 3);
INSERT INTO public.payment VALUES (12, '2024-04-18', 0.00, NULL, 'PayPal', NULL, 12, 1);
INSERT INTO public.payment VALUES (13, '2024-04-19', 95.00, NULL, 'Cash', NULL, 13, 3);
INSERT INTO public.payment VALUES (14, '2024-04-20', 160.00, NULL, 'Credit Card', NULL, 14, 3);
INSERT INTO public.payment VALUES (15, '2024-04-21', 105.00, NULL, 'PayPal', NULL, 15, 3);
INSERT INTO public.payment VALUES (16, '2024-04-22', 300.00, NULL, 'Bank Transfer', NULL, 16, 3);
INSERT INTO public.payment VALUES (17, '2024-04-23', 125.00, NULL, 'Credit Card', NULL, 17, 3);
INSERT INTO public.payment VALUES (18, '2024-04-24', 0.00, NULL, 'Cash', NULL, 18, 1);
INSERT INTO public.payment VALUES (19, '2024-04-25', 85.00, NULL, 'Credit Card', NULL, 19, 3);
INSERT INTO public.payment VALUES (20, '2024-04-26', 155.00, NULL, 'PayPal', NULL, 20, 3);
INSERT INTO public.payment VALUES (999, '2026-05-28', 400.00, NULL, 'Credit Card', NULL, 1, 3);


--
-- TOC entry 3543 (class 0 OID 33060)
-- Dependencies: 227
-- Data for Name: paymentstatus; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.paymentstatus VALUES (1, 'Unpaid');
INSERT INTO public.paymentstatus VALUES (2, 'Partial');
INSERT INTO public.paymentstatus VALUES (3, 'Paid In Full');
INSERT INTO public.paymentstatus VALUES (4, 'Refunded');
INSERT INTO public.paymentstatus VALUES (5, 'Declined');
INSERT INTO public.paymentstatus VALUES (6, 'Processing');
INSERT INTO public.paymentstatus VALUES (7, 'Voided');
INSERT INTO public.paymentstatus VALUES (8, 'Chargeback');
INSERT INTO public.paymentstatus VALUES (9, 'Authorized');
INSERT INTO public.paymentstatus VALUES (10, 'Cash Pending');
INSERT INTO public.paymentstatus VALUES (11, 'Bank Transfer Sent');
INSERT INTO public.paymentstatus VALUES (12, 'Overpaid');
INSERT INTO public.paymentstatus VALUES (13, 'Awaiting Verification');
INSERT INTO public.paymentstatus VALUES (14, 'Credit Issued');
INSERT INTO public.paymentstatus VALUES (15, 'Bad Debt');
INSERT INTO public.paymentstatus VALUES (16, 'Written Off');
INSERT INTO public.paymentstatus VALUES (17, 'Disputed');
INSERT INTO public.paymentstatus VALUES (18, 'Installments');
INSERT INTO public.paymentstatus VALUES (19, 'Gift Card');
INSERT INTO public.paymentstatus VALUES (20, 'Comped');


--
-- TOC entry 3542 (class 0 OID 33032)
-- Dependencies: 226
-- Data for Name: registration; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.registration VALUES (2, '2024-04-02', 120.00, NULL, 2, 2, 2);
INSERT INTO public.registration VALUES (3, '2024-04-03', 100.00, NULL, 3, 2, 3);
INSERT INTO public.registration VALUES (4, '2024-04-04', 80.00, NULL, 4, 1, 4);
INSERT INTO public.registration VALUES (5, '2024-04-05', 200.00, NULL, 5, 2, 5);
INSERT INTO public.registration VALUES (6, '2024-04-10', 250.00, NULL, 6, 2, 6);
INSERT INTO public.registration VALUES (7, '2024-04-11', 90.00, NULL, 7, 2, 7);
INSERT INTO public.registration VALUES (8, '2024-04-12', 110.00, NULL, 8, 2, 8);
INSERT INTO public.registration VALUES (9, '2024-04-15', 140.00, NULL, 9, 1, 9);
INSERT INTO public.registration VALUES (10, '2024-04-16', 130.00, NULL, 10, 2, 10);
INSERT INTO public.registration VALUES (11, '2024-04-17', 115.00, NULL, 11, 2, 11);
INSERT INTO public.registration VALUES (12, '2024-04-18', 180.00, NULL, 12, 1, 12);
INSERT INTO public.registration VALUES (13, '2024-04-19', 95.00, NULL, 13, 2, 13);
INSERT INTO public.registration VALUES (14, '2024-04-20', 160.00, NULL, 14, 2, 14);
INSERT INTO public.registration VALUES (15, '2024-04-21', 105.00, NULL, 15, 2, 15);
INSERT INTO public.registration VALUES (16, '2024-04-22', 300.00, NULL, 16, 2, 16);
INSERT INTO public.registration VALUES (17, '2024-04-23', 125.00, NULL, 17, 2, 17);
INSERT INTO public.registration VALUES (18, '2024-04-24', 135.00, NULL, 18, 1, 18);
INSERT INTO public.registration VALUES (19, '2024-04-25', 85.00, NULL, 19, 2, 19);
INSERT INTO public.registration VALUES (20, '2024-04-26', 155.00, NULL, 20, 2, 20);
INSERT INTO public.registration VALUES (1, '2024-04-01', 120.00, ' [Discount of 20.00% applied on 2026-05-28]', 1, 2, 1);


--
-- TOC entry 3541 (class 0 OID 33025)
-- Dependencies: 225
-- Data for Name: registrationstatus; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.registrationstatus VALUES (1, 'Registered');
INSERT INTO public.registrationstatus VALUES (2, 'Confirmed');
INSERT INTO public.registrationstatus VALUES (3, 'Waitlist');
INSERT INTO public.registrationstatus VALUES (4, 'Cancelled');
INSERT INTO public.registrationstatus VALUES (5, 'Refunded');
INSERT INTO public.registrationstatus VALUES (6, 'No Show');
INSERT INTO public.registrationstatus VALUES (7, 'Pending Payment');
INSERT INTO public.registrationstatus VALUES (8, 'Partial Deposit');
INSERT INTO public.registrationstatus VALUES (9, 'Interested');
INSERT INTO public.registrationstatus VALUES (10, 'Invitation Sent');
INSERT INTO public.registrationstatus VALUES (11, 'Approved');
INSERT INTO public.registrationstatus VALUES (12, 'Rejected');
INSERT INTO public.registrationstatus VALUES (13, 'Expired');
INSERT INTO public.registrationstatus VALUES (14, 'Review Needed');
INSERT INTO public.registrationstatus VALUES (15, 'Rebooked');
INSERT INTO public.registrationstatus VALUES (16, 'Group Hold');
INSERT INTO public.registrationstatus VALUES (17, 'Completed');
INSERT INTO public.registrationstatus VALUES (18, 'VIP Pending');
INSERT INTO public.registrationstatus VALUES (19, 'Voucher Used');
INSERT INTO public.registrationstatus VALUES (20, 'Locked');


--
-- TOC entry 3537 (class 0 OID 32959)
-- Dependencies: 221
-- Data for Name: route; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.route VALUES (1, 'Masada Sunrise', 5.50, 180, NULL, 4);
INSERT INTO public.route VALUES (2, 'Nahal Arugot', 4.00, 120, NULL, 2);
INSERT INTO public.route VALUES (3, 'Mount Carmel Forest', 10.20, 240, NULL, 3);
INSERT INTO public.route VALUES (4, 'Tel Aviv Urban Walk', 3.00, 90, NULL, 1);
INSERT INTO public.route VALUES (5, 'Eilat Red Canyon', 2.50, 60, NULL, 2);
INSERT INTO public.route VALUES (6, 'Golan Heights Trail', 15.00, 360, NULL, 5);
INSERT INTO public.route VALUES (7, 'Jerusalem Old City', 2.00, 120, NULL, 1);
INSERT INTO public.route VALUES (8, 'Ein Gedi Waterfall', 1.50, 45, NULL, 1);
INSERT INTO public.route VALUES (9, 'Arbel Cliff Hike', 4.50, 150, NULL, 4);
INSERT INTO public.route VALUES (10, 'Mount Tabor Loop', 7.00, 200, NULL, 3);
INSERT INTO public.route VALUES (11, 'Banias River Walk', 3.50, 100, NULL, 2);
INSERT INTO public.route VALUES (12, 'Makhtesh Ramon Rim', 12.00, 300, NULL, 4);
INSERT INTO public.route VALUES (13, 'Agamon Hula Birding', 8.00, 180, NULL, 1);
INSERT INTO public.route VALUES (14, 'Nahal Kziv', 6.00, 180, NULL, 3);
INSERT INTO public.route VALUES (15, 'Sataf Spring Trail', 3.00, 90, NULL, 2);
INSERT INTO public.route VALUES (16, 'Mount Hermon Summit', 5.00, 210, NULL, 5);
INSERT INTO public.route VALUES (17, 'Caesarea Ruins', 2.00, 60, NULL, 1);
INSERT INTO public.route VALUES (18, 'Yehiam Fortress Hike', 4.00, 120, NULL, 2);
INSERT INTO public.route VALUES (19, 'Nahal Alexander', 5.00, 120, NULL, 1);
INSERT INTO public.route VALUES (20, 'Mount Meron Peak', 9.00, 240, NULL, 3);


--
-- TOC entry 3546 (class 0 OID 33331)
-- Dependencies: 230
-- Data for Name: tour_audit; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tour_audit VALUES (1, 999, 'INSERT', NULL, 500.00, NULL, 1, 'shirelnk', '2026-05-28 08:58:08.2');
INSERT INTO public.tour_audit VALUES (2, 999, 'UPDATE', 500.00, 450.00, 1, 1, 'shirelnk', '2026-05-28 08:58:33.440017');


--
-- TOC entry 3538 (class 0 OID 32976)
-- Dependencies: 222
-- Data for Name: tourstatus; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tourstatus VALUES (1, 'Scheduled');
INSERT INTO public.tourstatus VALUES (2, 'Confirmed');
INSERT INTO public.tourstatus VALUES (3, 'In Progress');
INSERT INTO public.tourstatus VALUES (4, 'Completed');
INSERT INTO public.tourstatus VALUES (5, 'Cancelled');
INSERT INTO public.tourstatus VALUES (6, 'Postponed');
INSERT INTO public.tourstatus VALUES (7, 'Fully Booked');
INSERT INTO public.tourstatus VALUES (8, 'Pending');
INSERT INTO public.tourstatus VALUES (9, 'Draft');
INSERT INTO public.tourstatus VALUES (10, 'On Hold');
INSERT INTO public.tourstatus VALUES (11, 'Awaiting Guide');
INSERT INTO public.tourstatus VALUES (12, 'Closed');
INSERT INTO public.tourstatus VALUES (13, 'Archived');
INSERT INTO public.tourstatus VALUES (14, 'Sold Out');
INSERT INTO public.tourstatus VALUES (15, 'Maintenance');
INSERT INTO public.tourstatus VALUES (16, 'Hidden');
INSERT INTO public.tourstatus VALUES (17, 'Available');
INSERT INTO public.tourstatus VALUES (18, 'Last Minute');
INSERT INTO public.tourstatus VALUES (19, 'Premium Only');
INSERT INTO public.tourstatus VALUES (20, 'Returning Soon');


--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 229
-- Name: tour_audit_auditid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tour_audit_auditid_seq', 2, true);


--
-- TOC entry 3362 (class 2606 OID 33024)
-- Name: customer customer_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_email_key UNIQUE (email);


--
-- TOC entry 3364 (class 2606 OID 33022)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customerid);


--
-- TOC entry 3353 (class 2606 OID 32958)
-- Name: difficultylevel difficultylevel_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.difficultylevel
    ADD CONSTRAINT difficultylevel_pkey PRIMARY KEY (difficultyid);


--
-- TOC entry 3349 (class 2606 OID 32951)
-- Name: guide guide_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guide
    ADD CONSTRAINT guide_email_key UNIQUE (email);


--
-- TOC entry 3351 (class 2606 OID 32949)
-- Name: guide guide_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guide
    ADD CONSTRAINT guide_pkey PRIMARY KEY (guideid);


--
-- TOC entry 3359 (class 2606 OID 32998)
-- Name: guidedtour guidedtour_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guidedtour
    ADD CONSTRAINT guidedtour_pkey PRIMARY KEY (tourid);


--
-- TOC entry 3374 (class 2606 OID 33079)
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (paymentid);


--
-- TOC entry 3371 (class 2606 OID 33066)
-- Name: paymentstatus paymentstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paymentstatus
    ADD CONSTRAINT paymentstatus_pkey PRIMARY KEY (paymentstatusid);


--
-- TOC entry 3369 (class 2606 OID 33044)
-- Name: registration registration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration
    ADD CONSTRAINT registration_pkey PRIMARY KEY (registrationid);


--
-- TOC entry 3366 (class 2606 OID 33031)
-- Name: registrationstatus registrationstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registrationstatus
    ADD CONSTRAINT registrationstatus_pkey PRIMARY KEY (registrationstatusid);


--
-- TOC entry 3355 (class 2606 OID 32970)
-- Name: route route_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT route_pkey PRIMARY KEY (routeid);


--
-- TOC entry 3376 (class 2606 OID 33341)
-- Name: tour_audit tour_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_audit
    ADD CONSTRAINT tour_audit_pkey PRIMARY KEY (auditid);


--
-- TOC entry 3357 (class 2606 OID 32982)
-- Name: tourstatus tourstatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tourstatus
    ADD CONSTRAINT tourstatus_pkey PRIMARY KEY (tourstatusid);


--
-- TOC entry 3360 (class 1259 OID 33092)
-- Name: idx_guidedtour_routeid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_guidedtour_routeid ON public.guidedtour USING btree (routeid);


--
-- TOC entry 3372 (class 1259 OID 33090)
-- Name: idx_payment_paymentdate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_paymentdate ON public.payment USING btree (paymentdate);


--
-- TOC entry 3367 (class 1259 OID 33091)
-- Name: idx_registration_tourid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registration_tourid ON public.registration USING btree (tourid);


--
-- TOC entry 3386 (class 2620 OID 33344)
-- Name: guidedtour trg_audit_tour_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_audit_tour_changes AFTER INSERT OR DELETE OR UPDATE ON public.guidedtour FOR EACH ROW EXECUTE FUNCTION public.fn_trg_audit_tour_changes();


--
-- TOC entry 3387 (class 2620 OID 33346)
-- Name: payment trg_update_registration_payment_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_update_registration_payment_status AFTER INSERT OR UPDATE OF paymentstatusid, amount ON public.payment FOR EACH ROW EXECUTE FUNCTION public.fn_trg_update_registration_payment_status();


--
-- TOC entry 3378 (class 2606 OID 32999)
-- Name: guidedtour guidedtour_guideid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guidedtour
    ADD CONSTRAINT guidedtour_guideid_fkey FOREIGN KEY (guideid) REFERENCES public.guide(guideid);


--
-- TOC entry 3379 (class 2606 OID 33004)
-- Name: guidedtour guidedtour_routeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guidedtour
    ADD CONSTRAINT guidedtour_routeid_fkey FOREIGN KEY (routeid) REFERENCES public.route(routeid);


--
-- TOC entry 3380 (class 2606 OID 33009)
-- Name: guidedtour guidedtour_tourstatusid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guidedtour
    ADD CONSTRAINT guidedtour_tourstatusid_fkey FOREIGN KEY (tourstatusid) REFERENCES public.tourstatus(tourstatusid);


--
-- TOC entry 3384 (class 2606 OID 33085)
-- Name: payment payment_paymentstatusid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_paymentstatusid_fkey FOREIGN KEY (paymentstatusid) REFERENCES public.paymentstatus(paymentstatusid);


--
-- TOC entry 3385 (class 2606 OID 33080)
-- Name: payment payment_registrationid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_registrationid_fkey FOREIGN KEY (registrationid) REFERENCES public.registration(registrationid);


--
-- TOC entry 3381 (class 2606 OID 33045)
-- Name: registration registration_customerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration
    ADD CONSTRAINT registration_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.customer(customerid);


--
-- TOC entry 3382 (class 2606 OID 33055)
-- Name: registration registration_registrationstatusid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration
    ADD CONSTRAINT registration_registrationstatusid_fkey FOREIGN KEY (registrationstatusid) REFERENCES public.registrationstatus(registrationstatusid);


--
-- TOC entry 3383 (class 2606 OID 33050)
-- Name: registration registration_tourid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registration
    ADD CONSTRAINT registration_tourid_fkey FOREIGN KEY (tourid) REFERENCES public.guidedtour(tourid);


--
-- TOC entry 3377 (class 2606 OID 32971)
-- Name: route route_difficultyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT route_difficultyid_fkey FOREIGN KEY (difficultyid) REFERENCES public.difficultylevel(difficultyid);


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2026-05-28 09:35:27 UTC

--
-- PostgreSQL database dump complete
--

\unrestrict 1yVkmVHmPcV0aVBrdYmTSEfKNQlweApDmk3hhLPCOhgOhSGSmCkk45bzT82Xqhm

