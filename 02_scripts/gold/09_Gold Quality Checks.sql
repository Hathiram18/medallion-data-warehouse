-- Are the dimension keys unique?
SELECT
    product_number,
    COUNT(*) AS product_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

SELECT
    customer_id,
    COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    product_key,
    COUNT(*) AS key_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

SELECT
    customer_key,
    COUNT(*) AS key_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Final GOLD quality checks
-- 1. Check for orphan foreign keys
SELECT COUNT(*) AS orphan_product_rows
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

SELECT COUNT(*) AS orphan_customer_rows
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

-- 2. Check sales measures
SELECT
    COUNT(*) FILTER (WHERE sales_amount IS NULL) AS null_sales,
    COUNT(*) FILTER (WHERE sales_amount <= 0) AS non_positive_sales,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity,
    COUNT(*) FILTER (WHERE quantity <= 0) AS non_positive_quantity,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE price <= 0) AS non_positive_price
FROM gold.fact_sales;

-- 3. Check future sales dates
SELECT
    COUNT(*) AS future_order_dates
FROM gold.fact_sales
WHERE order_date > CURRENT_DATE;

SELECT COUNT(*) AS invalid_date_sequence
FROM gold.fact_sales
WHERE shipping_date < order_date
   OR due_date < order_date;

-- 4. Final row count reconciliation
SELECT
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_sales_rows,
    (SELECT COUNT(*) FROM gold.fact_sales) AS gold_fact_rows;