-- Create Silver Table Structure using Bronze Table Structure...
-- Create Silver schema
CREATE SCHEMA IF NOT EXISTS silver;

-- Remove old Silver tables if they exist
DROP TABLE IF EXISTS silver.crm_cust_info CASCADE;
DROP TABLE IF EXISTS silver.crm_prd_info CASCADE;
DROP TABLE IF EXISTS silver.crm_sales_details CASCADE;
DROP TABLE IF EXISTS silver.erp_cust_az12 CASCADE;
DROP TABLE IF EXISTS silver.erp_loc_a101 CASCADE;
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2 CASCADE;

-- Create Silver tables using Bronze table structures
CREATE TABLE silver.crm_cust_info
(LIKE bronze.crm_cust_info INCLUDING ALL);

CREATE TABLE silver.crm_prd_info
(LIKE bronze.crm_prd_info INCLUDING ALL);

CREATE TABLE silver.crm_sales_details
(LIKE bronze.crm_sales_details INCLUDING ALL);

CREATE TABLE silver.erp_cust_az12
(LIKE bronze.erp_cust_az12 INCLUDING ALL);

CREATE TABLE silver.erp_loc_a101
(LIKE bronze.erp_loc_a101 INCLUDING ALL);

CREATE TABLE silver.erp_px_cat_g1v2
(LIKE bronze.erp_px_cat_g1v2 INCLUDING ALL);

-- Description
COMMENT ON SCHEMA silver
IS 'Silver layer: cleaned and standardized data.';