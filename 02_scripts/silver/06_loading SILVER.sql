-- Loading crm_cust_info table
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S'
            THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M'
            THEN 'Married'
        ELSE 'n/a'
    END,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F'
            THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M'
            THEN 'Male'
        ELSE 'n/a'
    END,

    cst_create_date

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id
               ORDER BY cst_create_date DESC
           ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t

WHERE rn = 1;


-- Loading crm_prd_info table

TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info (
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,

    -- Replace only the first two hyphens
    regexp_replace(prd_key, '-', '_', 1, 2),

    -- Clean product name
    TRIM(prd_nm),

    -- Replace NULL cost with 0
    COALESCE(prd_cost, 0),

    -- Standardize product line
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END,

    -- Start date
    prd_start_dt,

    -- Correct end date
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - 1

FROM bronze.crm_prd_info;


-- Loading crm_sales_details table
ALTER TABLE silver.crm_sales_details
    ALTER COLUMN sls_order_dt TYPE DATE
    USING CASE
        WHEN sls_order_dt = 0
             OR LENGTH(sls_order_dt::text) <> 8
        THEN NULL
        ELSE TO_DATE(sls_order_dt::text, 'YYYYMMDD')
    END;

ALTER TABLE silver.crm_sales_details
    ALTER COLUMN sls_ship_dt TYPE DATE
    USING TO_DATE(sls_ship_dt::text, 'YYYYMMDD');

ALTER TABLE silver.crm_sales_details
    ALTER COLUMN sls_due_dt TYPE DATE
    USING TO_DATE(sls_due_dt::text, 'YYYYMMDD');

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    -- Convert order date
    CASE
        WHEN sls_order_dt = 0
          OR LENGTH(sls_order_dt::text) <> 8
        THEN NULL
        ELSE TO_DATE(sls_order_dt::text, 'YYYYMMDD')
    END AS sls_order_dt,

    -- Convert ship date
    CASE
        WHEN sls_ship_dt = 0
          OR LENGTH(sls_ship_dt::text) <> 8
        THEN NULL
        ELSE TO_DATE(sls_ship_dt::text, 'YYYYMMDD')
    END AS sls_ship_dt,

    -- Convert due date
    CASE
        WHEN sls_due_dt = 0
          OR LENGTH(sls_due_dt::text) <> 8
        THEN NULL
        ELSE TO_DATE(sls_due_dt::text, 'YYYYMMDD')
    END AS sls_due_dt,

    -- Correct sales
    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales <> sls_quantity * sls_price
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    -- Correct price
    CASE
        WHEN sls_price IS NULL
          OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details;	

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'silver'
  AND table_name = 'crm_sales_details'
ORDER BY ordinal_position;

-- Loading erp_cust_az12 table
INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    -- Clean customer ID
    CASE
        WHEN LEFT(TRIM(cid), 3) = 'NAS'
            THEN SUBSTRING(TRIM(cid) FROM 4)
        ELSE TRIM(cid)
    END AS cid,

    -- Remove invalid future birth dates
    CASE
        WHEN bdate > CURRENT_DATE
            THEN NULL
        ELSE bdate
    END AS bdate,

    -- Standardize gender
    CASE
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
            THEN 'Male'
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
            THEN 'Female'
        ELSE 'n/a'
    END AS gen

FROM bronze.erp_cust_az12;

-- Loading erp_loc_a101 table
TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    -- Clean customer ID
    REPLACE(TRIM(cid), '-', '') AS cid,

    -- Standardize country
    CASE
        WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES')
            THEN 'United States'

        WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY')
            THEN 'Germany'

        WHEN TRIM(cntry) = ''
            OR cntry IS NULL
            THEN 'n/a'

        ELSE TRIM(cntry)
    END AS cntry

FROM bronze.erp_loc_a101;

-- Loading erp_px_cat_g1v2 table
TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    TRIM(id) AS id,
    TRIM(cat) AS cat,
    TRIM(subcat) AS subcat,

    CASE
        WHEN UPPER(TRIM(maintenance)) = 'YES'
            THEN 'Yes'

        WHEN UPPER(TRIM(maintenance)) = 'NO'
            THEN 'No'

        ELSE 'n/a'
    END AS maintenance

FROM bronze.erp_px_cat_g1v2;
