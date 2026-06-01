CREATE OR REPLACE PROCEDURE pr_assign_optimal_guide_to_tour(
    p_tour_id INT,
    p_preferred_expertise VARCHAR
)
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
$$ LANGUAGE plpgsql;