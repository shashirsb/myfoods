-- This needs to run as OADMINUSER

-- DEFINE HANDLER
BEGIN
    ORDS.DEFINE_HANDLER(
        p_module_name => 'com.oracle.myfoods',
        p_pattern => 'frontend',
        p_method => 'GET',
        p_source_type => 'source_type_collection_feed',
        p_source => 'with x as (SELECT
    t1.pk_col,
    t1.pin_code,
    t1.store_address,
    t1.store_name,
    sdo_nn_distance(5)                      distance_m,
    admin.get_geometry(t1.longitude, t1.latitude) geometry
FROM
    ouser.online_stores t1
WHERE
        sdo_nn(admin.get_geometry(t1.longitude, t1.latitude),
               mdsys.sdo_geometry(2001,
                                  4326,
                                  sdo_point_type(:long, :lat, NULL),
                                  NULL,
                                  NULL),
               ''''sdo_batch_size=10 unit=KM'''',
               5) = ''''TRUE''''
    AND ROWNUM <= 10
    )
 SELECT ''''application/json'''' as mediatype, -- for ORDS,
    ''''{"type": "FeatureCollection", "features":''''
    || JSON_ARRAYAGG( 
        ''''{"type": "Feature", "properties": {''''
        || ''''"pk_col":"''''|| pk_col
        ||''''","pin_code":"''''|| pin_code
        ||''''","store_address":"''''|| store_address
        ||''''","store_name":"''''|| store_name
        ||''''","distance_m":"''''|| distance_m
        ||''''"}, "geometry":''''|| SDO_UTIL.TO_GEOJSON(Geometry)
        ||''''}'''' 
       FORMAT JSON RETURNING CLOB) 
    ||''''}''''
    AS GEOJSON
FROM X',
        p_items_per_page=> ,
        p_comments=> ''
    );
    commit;
END;

---

-- DEFINE HANDLER
BEGIN
    ORDS.DEFINE_HANDLER(
        p_module_name => 'com.oracle.myfoods',
        p_pattern => 'frontend',
        p_method => 'POST',
        p_source_type => 'source_type_plsql',
        p_source => 'INSERT INTO ouser.j_onlineorder VALUES (SYS_GUID(),to_date(''''25-OCT-2022''''),:body)',
        p_items_per_page=> ,
        p_comments=> ''
    );
    commit;
END;


---

-- DEFINE HANDLER
BEGIN
    ORDS.DEFINE_HANDLER(
        p_module_name => 'com.oracle.myfoods',
        p_pattern => 'ml',
        p_method => 'GET',
        p_source_type => 'source_type_collection_feed',
        p_source => 'SELECT ROWNUM RANK,
        CONSEQUENT_NAME RECOMMENDATION,
        NUMBER_OF_ITEMS NUM,
        ROUND(RULE_SUPPORT, 3) SUPPORT,
        ROUND(RULE_CONFIDENCE, 3) CONFIDENCE,
        ROUND(RULE_LIFT, 3) LIFT,
        ROUND(RULE_REVCONFIDENCE, 3) REVERSE_CONFIDENCE
        FROM (SELECT * FROM ouser.DM$VRGB_DISH_MB
        WHERE NUMBER_OF_ITEMS = 2
        AND EXTRACT(antecedent, ''''//item[item_name="''''||to_char(:item)||''''"]'''') IS NOT NULL
        ORDER BY NUMBER_OF_ITEMS
        )
        WHERE ROWNUM <= 2',
        p_items_per_page=> 25,
        p_comments=> ''
    );
    commit;
END;

