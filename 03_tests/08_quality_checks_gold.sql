-- PostgreSQL Version: 08_quality_checks_gold.sql
-- Gold Layer Data Quality Checks

\echo '========================================'
\echo 'Running Gold Layer Quality Checks'
\echo '========================================'

-- 1. Duplicate dimension keys
SELECT cst_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY cst_key
HAVING COUNT(*) > 1;

SELECT prd_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- 2. Fact table orphan records
SELECT COUNT(*) AS orphan_customer_records
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.cst_key = c.cst_key
WHERE f.cst_key IS NOT NULL
  AND c.cst_key IS NULL;

SELECT COUNT(*) AS orphan_product_records
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.prd_key = p.prd_key
WHERE f.prd_key IS NOT NULL
  AND p.prd_key IS NULL;

-- 3. Sales validation
SELECT COUNT(*) AS null_sales_amount
FROM gold.fact_sales
WHERE sls_sales IS NULL;

SELECT COUNT(*) AS negative_sales_amount
FROM gold.fact_sales
WHERE COALESCE(sls_sales,0) < 0;

-- 4. Date validation
SELECT COUNT(*) AS future_sales_dates
FROM gold.fact_sales
WHERE sls_order_dt > CURRENT_DATE;

-- 5. Record counts
SELECT 'dim_customers' AS object_name, COUNT(*) AS row_count
FROM gold.dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*)
FROM gold.dim_products
UNION ALL
SELECT 'fact_sales', COUNT(*)
FROM gold.fact_sales;

\echo 'Gold quality checks completed.'
