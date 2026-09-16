-- Check 1 — NULL primary/business keys
SELECT 'crm_cust_info: NULL cst_id' AS check_name,
       COUNT(*) AS issue_count
FROM silver.crm_cust_info
WHERE cst_id IS NULL

UNION ALL

SELECT 'crm_prd_info: NULL prd_key',
       COUNT(*)
FROM silver.crm_prd_info
WHERE prd_key IS NULL;

-- Check duplicate customer IDs
SELECT
    cst_id,
    COUNT(*) AS occurrences
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Check duplicate product keys
SELECT
    prd_key,
    COUNT(*) AS occurrences
FROM silver.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1;

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE prd_key = 'CO_RF_FR-R38B'
ORDER BY prd_start_dt;

-- Duplicating product versions
SELECT
    prd_key,
    prd_start_dt,
    COUNT(*) AS occurrences
FROM silver.crm_prd_info
GROUP BY
    prd_key,
    prd_start_dt
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT
    prd_id,
    COUNT(*) AS occurrences
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

SELECT
    prd_id,
    prd_key AS original_prd_key,
    prd_start_dt,
    prd_end_dt AS original_end_dt,

    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - 1 AS calculated_end_dt

FROM bronze.crm_prd_info
WHERE prd_key = 'CO-RF-FR-R38B-58'
ORDER BY prd_start_dt;

SELECT
    prd_id,

    -- Transform product key
    SPLIT_PART(prd_key, '-', 1)
    || '_'
    || SPLIT_PART(prd_key, '-', 2)
    || '_'
    || SPLIT_PART(prd_key, '-', 3)
    || '-'
    || SPLIT_PART(prd_key, '-', 4) AS prd_key,

    -- Clean product name
    TRIM(prd_nm) AS prd_nm,

    -- Replace NULL cost with 0
    COALESCE(prd_cost, 0) AS prd_cost,

    -- Standardize product line
    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,

    -- Keep original start date
    prd_start_dt,

    -- Calculate correct end date
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - 1 AS prd_end_dt

FROM bronze.crm_prd_info
ORDER BY prd_id;

SELECT *
FROM (
    SELECT
        prd_id,
        prd_key,
        prd_start_dt,
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - 1 AS calculated_end_dt
    FROM bronze.crm_prd_info
) t
WHERE calculated_end_dt IS NOT NULL
  AND calculated_end_dt < prd_start_dt;

-- Reinserting the crm_prd_info table
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

    -- Transform product key
    SPLIT_PART(prd_key, '-', 1)
    || '_'
    || SPLIT_PART(prd_key, '-', 2)
    || '_'
    || SPLIT_PART(prd_key, '-', 3)
    || '-'
    || SPLIT_PART(prd_key, '-', 4),

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

SELECT COUNT(*) AS silver_product_count
FROM silver.crm_prd_info;

-- Let's quickly check the actual Silver data rather than only checking the row count.
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
ORDER BY prd_id
LIMIT 20;

-- Invalid Sales References
-- Check 1: Sales referring to non-existent customers
-- SELECT COUNT(*) AS invalid_customer_refs
-- FROM silver.crm_sales_details s
-- LEFT JOIN silver.crm_cust_info c
--     ON s.sls_cust_id = c.cst_id
-- WHERE s.sls_cust_id IS NOT NULL
--   AND c.cst_id IS NULL;


-- Check 2: Sales referring to non-existent products
SELECT COUNT(*) AS invalid_product_refs
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p
    ON s.sls_prd_key = SPLIT_PART(p.prd_key, '_', 3)
WHERE s.sls_prd_key IS NOT NULL
  AND p.prd_key IS NULL;

SELECT
    s.sls_prd_key,
    COUNT(*) AS sales_rows
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p
    ON s.sls_prd_key = SPLIT_PART(p.prd_key, '_', 3)
WHERE s.sls_prd_key IS NOT NULL
  AND p.prd_key IS NULL
GROUP BY s.sls_prd_key
ORDER BY sales_rows DESC
LIMIT 30;  

SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line
FROM bronze.crm_prd_info
WHERE prd_key LIKE '%HL-U509%';

SELECT
    prd_id,
    prd_key AS original_prd_key,
    regexp_replace(prd_key, '-', '_', 1, 2) AS corrected_prd_key
FROM bronze.crm_prd_info
WHERE prd_key LIKE '%HL-U509%'
ORDER BY prd_id;

-- Reload Product Silver correctly
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

-- Verify the corrected Product keys
SELECT
    prd_id,
    prd_key,
    prd_nm
FROM silver.crm_prd_info
WHERE prd_key LIKE '%HL-U509%'
ORDER BY prd_id;

-- Finally rerun the product-reference check
SELECT COUNT(*) AS invalid_product_refs
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p
    ON s.sls_prd_key = SUBSTRING(p.prd_key FROM 7)
WHERE s.sls_prd_key IS NOT NULL
  AND p.prd_key IS NULL;

-- invalid customer references
SELECT COUNT(*) AS invalid_customer_refs
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c
    ON s.sls_cust_id = c.cst_id
WHERE s.sls_cust_id IS NOT NULL
  AND c.cst_id IS NULL;

-- Gender chaeck
SELECT COUNT(*) AS invalid_gender
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');

-- Marital Status check
SELECT COUNT(*) AS invalid_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Single', 'Married', 'n/a');

-- Negative Sales Check
SELECT COUNT(*) AS negative_sales
FROM silver.crm_sales_details
WHERE COALESCE(sls_sales, 0) < 0;

-- Future customer dates
SELECT COUNT(*) AS future_customer_dates
FROM silver.crm_cust_info
WHERE cst_create_date > CURRENT_DATE;

-- ERP Customer
SELECT
    COUNT(*) AS total_rows,
    COUNT(cid) AS non_null_cid,
    COUNT(bdate) AS non_null_bdate,
    COUNT(gen) AS non_null_gen
FROM silver.erp_cust_az12;

SELECT
    cid,
    COUNT(*) AS occurrences
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT
    gen,
    COUNT(*) AS occurrences
FROM silver.erp_cust_az12
GROUP BY gen
ORDER BY occurrences DESC;

SELECT COUNT(*) AS invalid_gender
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a');

SELECT COUNT(*) AS future_birthdates
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;

SELECT COUNT(*) AS remaining_nas_prefix
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';

-- ERP Location
SELECT
    COUNT(*) AS total_rows,
    COUNT(cid) AS non_null_cid,
    COUNT(cntry) AS non_null_country
FROM silver.erp_loc_a101;

SELECT
    cid,
    COUNT(*) AS occurrences
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT
    cntry,
    COUNT(*) AS occurrences
FROM silver.erp_loc_a101
GROUP BY cntry
ORDER BY occurrences DESC;

SELECT COUNT(*) AS invalid_country
FROM silver.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';

-- the CRM ↔ ERP customer relationship
SELECT COUNT(*) AS unmatched_erp_customers
FROM silver.erp_cust_az12 e
LEFT JOIN silver.crm_cust_info c
    ON e.cid = c.cst_key
WHERE c.cst_key IS NULL;

SELECT COUNT(*) AS unmatched_erp_locations
FROM silver.erp_loc_a101 e
LEFT JOIN silver.crm_cust_info c
    ON e.cid = c.cst_key
WHERE c.cst_key IS NULL;

-- ERP Product category
SELECT
    COUNT(*) AS total_rows,
    COUNT(id) AS non_null_id,
    COUNT(cat) AS non_null_category,
    COUNT(subcat) AS non_null_subcategory,
    COUNT(maintenance) AS non_null_maintenance
FROM silver.erp_px_cat_g1v2;

SELECT
    id,
    COUNT(*) AS occurrences
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

SELECT
    maintenance,
    COUNT(*) AS occurrences
FROM silver.erp_px_cat_g1v2
GROUP BY maintenance
ORDER BY occurrences DESC;

SELECT COUNT(*) AS invalid_maintenance
FROM silver.erp_px_cat_g1v2
WHERE maintenance NOT IN ('Yes', 'No', 'n/a');

-- CRM Product Silver date correction
SELECT
    prd_id,
    prd_key AS original_prd_key,
    prd_start_dt,
    prd_end_dt AS original_end_dt,

    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) - 1 AS calculated_end_dt

FROM bronze.crm_prd_info
WHERE prd_key = 'CO-RF-FR-R38B-58'
ORDER BY prd_start_dt;

SELECT COUNT(*) AS silver_product_rows
FROM silver.crm_prd_info;

SELECT
    sls_order_dt,
    COUNT(*) AS occurrences
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0
   OR LENGTH(sls_order_dt::text) <> 8
GROUP BY sls_order_dt
ORDER BY occurrences DESC;

-- Ship date anomalies
SELECT
    sls_ship_dt,
    COUNT(*) AS occurrences
FROM silver.crm_sales_details
WHERE LENGTH(sls_ship_dt::text) <> 10
GROUP BY sls_ship_dt
ORDER BY occurrences DESC;
