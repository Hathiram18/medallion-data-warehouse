-- CREATE SCHEMA IF NOT EXISTS gold;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'gold';

-- Step 1 — Create gold.dim_customers (CUSTOMER DIMENSION)
-- customer_key is the 'surrogate key' for gold layer
CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    
    COALESCE(cl.cntry, 'n/a') AS country,
    
    ci.cst_marital_status AS marital_status,
    
    CASE
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 cl
    ON ci.cst_key = cl.cid;

-- Checking
SELECT *
FROM gold.dim_customers
LIMIT 10;

SELECT COUNT(*)
FROM gold.dim_customers;

SELECT
    customer_key,
    COUNT(*) AS count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Step 2 — Create gold.dim_products (PRODUCT DIMENSION)
CREATE OR REPLACE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY p.prd_start_dt, p.prd_id
    ) AS product_key,

    p.prd_id AS product_id,

    -- Keep the original hyphens in the product number
    SPLIT_PART(p.prd_key, '_', 2) AS product_number,

    p.prd_nm AS product_name,

    -- Only the first section represents the category
    REPLACE(
        SPLIT_PART(p.prd_key, '_', 1),
        '-',
        '_'
    ) AS category_id,

    COALESCE(ep.cat, 'n/a') AS category,
    COALESCE(ep.subcat, 'n/a') AS subcategory,
    COALESCE(ep.maintenance, 'n/a') AS maintenance,

    COALESCE(p.prd_cost, 0) AS cost,

    p.prd_line AS product_line,

    p.prd_start_dt AS start_date

FROM silver.crm_prd_info p

LEFT JOIN silver.erp_px_cat_g1v2 ep
    ON REPLACE(
        SPLIT_PART(p.prd_key, '_', 1),
        '-',
        '_'
    ) = ep.id

WHERE p.prd_end_dt IS NULL;

-- Checking
SELECT
    product_id,
    product_number,
    category_id,
    category,
    subcategory,
    maintenance
FROM gold.dim_products
LIMIT 10;

SELECT
    COUNT(*) AS total_products,
    COUNT(product_number) AS products_with_number,
    COUNT(category_id) AS products_with_category_id,
    COUNT(category) AS products_with_category,
    COUNT(subcategory) AS products_with_subcategory,
    COUNT(maintenance) AS products_with_maintenance
FROM gold.dim_products;

-- Step 3 — Create gold.fact_sales (SALES FACT)

-- The purpose of this view is to take each Silver sales transaction 
-- and replace the source-system customer/product identifiers 
-- with the surrogate keys from our Gold dimensions.
-- Conceptually
--Silver Sales
     --│
     --├── sls_cust_id ──► dim_customers ──► customer_key
     --│
     --└── sls_prd_key ──► dim_products  ──► product_key
                                     
                    --↓
               --fact_sales
CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
    s.sls_ord_num AS order_number,

    p.product_key,
    c.customer_key,

    s.sls_order_dt AS order_date,
    s.sls_ship_dt AS shipping_date,
    s.sls_due_dt AS due_date,

    s.sls_sales AS sales_amount,
    s.sls_quantity AS quantity,
    s.sls_price AS price

FROM silver.crm_sales_details s

LEFT JOIN gold.dim_customers c
    ON s.sls_cust_id = c.customer_id

LEFT JOIN gold.dim_products p
    ON s.sls_prd_key = p.product_number;

-- Checking
SELECT *
FROM gold.fact_sales
LIMIT 10;

SELECT COUNT(*) AS fact_sales_rows
FROM gold.fact_sales;

SELECT
    COUNT(*) AS total_rows,
    COUNT(product_key) AS rows_with_product,
    COUNT(customer_key) AS rows_with_customer,
    COUNT(*) - COUNT(product_key) AS missing_product_key,
    COUNT(*) - COUNT(customer_key) AS missing_customer_key
FROM gold.fact_sales;