DO $$
DECLARE
    v_cursor REFCURSOR;
    v_rec RECORD;
    -- שינוי מ-'Medium' ל-'Moderate' הקיים בטבלת הנתונים שלכם
    v_difficulty VARCHAR := 'Moderate'; 
    v_test_tour_id INT := 2;
    v_expertise VARCHAR := 'Desert Hiking';
BEGIN
    RAISE NOTICE '===========================================================';
    RAISE NOTICE '                RUNNING MAIN PROGRAM 2                     ';
    RAISE NOTICE '===========================================================';

    RAISE NOTICE '>>> Step 1: Fetching tours for difficulty: %...', v_difficulty;
    
    -- עטיפת שלב 1 בבלוק מוגן כדי למנוע קריסה מוחלטת במקרה של חוסר בנתונים
    BEGIN
        v_cursor := fn_get_route_tour_details_by_difficulty(v_difficulty);
        
        LOOP
            FETCH v_cursor INTO v_rec;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE 'Tour Found - ID: %, Route: %, Price: %, Guide: %', 
                v_rec.TourID, v_rec.RouteName, v_rec.Price, v_rec.AssignedGuide;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Notice: Could not complete step 1 data fetch: %', SQLERRM;
    END;
    
    RAISE NOTICE '-----------------------------------------------------------';

    RAISE NOTICE '>>> Step 2: Auto-assigning optimal guide to Tour ID % (Expertise: %)...', v_test_tour_id, v_expertise;
    BEGIN
        CALL pr_assign_optimal_guide_to_tour(v_test_tour_id, v_expertise);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Could not assign guide automatically: %', SQLERRM;
    END;
    RAISE NOTICE '-----------------------------------------------------------';

    BEGIN
        RAISE NOTICE '>>> Step 3: Testing exception handling with non-existent Tour ID (99999)...';
        CALL pr_assign_optimal_guide_to_tour(99999, v_expertise);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Exception system successfully caught the error and prevented a crash!';
            RAISE NOTICE 'Message: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
    END;

    RAISE NOTICE '===========================================================';
END;
$$;