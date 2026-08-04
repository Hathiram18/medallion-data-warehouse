
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_start_time TIMESTAMP;
    start_time TIMESTAMP;
BEGIN
    batch_start_time := clock_timestamp();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '========================================';

    -- CRM
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE 'Loading bronze.crm_cust_info';
    EXECUTE $$COPY bronze.crm_cust_info FROM '/path/to/datasets/source_crm/cust_info.csv'
            WITH (FORMAT csv, HEADER true)$$;

    TRUNCATE TABLE bronze.crm_prd_info;
    EXECUTE $$COPY bronze.crm_prd_info FROM '/path/to/datasets/source_crm/prd_info.csv'
            WITH (FORMAT csv, HEADER true)$$;

    TRUNCATE TABLE bronze.crm_sales_details;
    EXECUTE $$COPY bronze.crm_sales_details FROM '/path/to/datasets/source_crm/sales_details.csv'
            WITH (FORMAT csv, HEADER true)$$;

    -- ERP
    TRUNCATE TABLE bronze.erp_loc_a101;
    EXECUTE $$COPY bronze.erp_loc_a101 FROM '/path/to/datasets/source_erp/loc_a101.csv'
            WITH (FORMAT csv, HEADER true)$$;

    TRUNCATE TABLE bronze.erp_cust_az12;
    EXECUTE $$COPY bronze.erp_cust_az12 FROM '/path/to/datasets/source_erp/cust_az12.csv'
            WITH (FORMAT csv, HEADER true)$$;

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    EXECUTE $$COPY bronze.erp_px_cat_g1v2 FROM '/path/to/datasets/source_erp/px_cat_g1v2.csv'
            WITH (FORMAT csv, HEADER true)$$;

    RAISE NOTICE 'Bronze load completed in % seconds',
        EXTRACT(EPOCH FROM (clock_timestamp()-batch_start_time));

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Bronze load failed: %', SQLERRM;
END;
$$;

-- If using psql, you may replace COPY with \copy for client-side loading.
-- Execute:
-- CALL bronze.load_bronze();
