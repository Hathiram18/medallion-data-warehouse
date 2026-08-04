-- PostgreSQL Version: ddl_gold.sql
-- Gold layer views (analytics-ready)

CREATE SCHEMA IF NOT EXISTS gold;

-- Customer Dimension
CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT *
FROM silver.crm_cust_info;

-- Product Dimension
CREATE OR REPLACE VIEW gold.dim_products AS
SELECT *
FROM silver.crm_prd_info;

-- Sales Fact
CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT
    s.*,
    c.cst_key,
    p.prd_key
FROM silver.crm_sales_details s
LEFT JOIN silver.crm_cust_info c
    ON s.sls_cust_id = c.cst_id
LEFT JOIN silver.crm_prd_info p
    ON s.sls_prd_key = p.prd_key;

COMMENT ON SCHEMA gold IS 'Gold layer: business-ready dimensional views.';
COMMENT ON VIEW gold.dim_customers IS 'Customer dimension';
COMMENT ON VIEW gold.dim_products IS 'Product dimension';
COMMENT ON VIEW gold.fact_sales IS 'Sales fact view';
