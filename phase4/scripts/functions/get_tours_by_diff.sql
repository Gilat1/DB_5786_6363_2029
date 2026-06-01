CREATE OR REPLACE FUNCTION fn_get_route_tour_details_by_difficulty(
    p_difficulty_name VARCHAR
)
RETURNS refcursor AS $$
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
$$ LANGUAGE plpgsql;