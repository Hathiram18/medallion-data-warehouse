-- PostgreSQL Version: proc_load_silver.sql
CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_start_time TIMESTAMP;
    start_time TIMESTAMP;
BEGIN
    batch_start_time := clock_timestamp();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '========================================';

    -- CRM Customer
    start_time := clock_timestamp();
    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info(
        cst_id,cst_key,cst_firstname,cst_lastname,
        cst_marital_status,cst_gndr,cst_create_date)
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE
            WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE
            WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM (
        SELECT *,
               ROW_NUMBER() OVER(
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS rn
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE rn=1;

    RAISE NOTICE 'crm_cust_info loaded in %',
      clock_timestamp()-start_time;

    -- NOTE:
    -- Apply the same conversion pattern to the remaining loads:
    -- crm_prd_info:
    --   ISNULL() -> COALESCE()
    --   LEN() -> LENGTH()
    --   SUBSTRING() -> SUBSTRING(text FROM start)
    --   LEAD() window function remains supported.
    --
    -- crm_sales_details:
    --   Convert date functions to PostgreSQL syntax.
    --
    -- ERP tables:
    --   Keep transformation logic unchanged except replacing
    --   SQL Server-specific functions with PostgreSQL equivalents.

    RAISE NOTICE 'Silver load finished in %',
        clock_timestamp()-batch_start_time;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Silver load failed: %', SQLERRM;
END;
$$;

-- Execute:
-- CALL silver.load_silver();
