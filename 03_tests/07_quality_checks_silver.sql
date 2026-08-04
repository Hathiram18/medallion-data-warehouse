-- PostgreSQL Version: 07_quality_checks_silver.sql
-- Silver Layer Data Quality Checks

\echo '========================================'
\echo 'Running Silver Layer Quality Checks'
\echo '========================================'

-- 1. Null primary keys
SELECT 'crm_cust_info: NULL cst_id' AS check_name, COUNT(*) AS issue_count
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

SELECT 'crm_prd_info: NULL prd_key' AS check_name, COUNT(*) AS issue_count
FROM silver.crm_prd_info
WHERE prd_key IS NULL;

-- 2. Duplicate business keys
SELECT cst_id, COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

SELECT prd_key, COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- 3. Invalid sales references
SELECT COUNT(*) AS invalid_customer_refs
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c
ON s.sls_cust_id = c.cst_id
WHERE s.sls_cust_id IS NOT NULL
  AND c.cst_id IS NULL;

SELECT COUNT(*) AS invalid_product_refs
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_prd_info p
ON s.sls_prd_key = p.prd_key
WHERE s.sls_prd_key IS NOT NULL
  AND p.prd_key IS NULL;

-- 4. Invalid values
SELECT COUNT(*) AS invalid_gender
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male','Female','n/a');

SELECT COUNT(*) AS invalid_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Single','Married','n/a');

-- 5. Negative amounts
SELECT COUNT(*) AS negative_sales
FROM silver.crm_sales_details
WHERE COALESCE(sls_sales,0) < 0;

-- 6. Future dates
SELECT COUNT(*) AS future_customer_dates
FROM silver.crm_cust_info
WHERE cst_create_date > CURRENT_DATE;

\echo 'Silver quality checks completed.'
