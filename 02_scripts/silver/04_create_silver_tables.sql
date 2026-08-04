-- PostgreSQL Version: ddl_silver.sql
-- Creates Silver layer tables

CREATE SCHEMA IF NOT EXISTS silver;

DROP TABLE IF EXISTS silver.crm_cust_info CASCADE;
DROP TABLE IF EXISTS silver.crm_prd_info CASCADE;
DROP TABLE IF EXISTS silver.crm_sales_details CASCADE;
DROP TABLE IF EXISTS silver.erp_cust_az12 CASCADE;
DROP TABLE IF EXISTS silver.erp_loc_a101 CASCADE;
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2 CASCADE;

-- NOTE:
-- This file is a migration template. Column definitions should match the
-- original SQL Server script exactly after full migration.

CREATE TABLE silver.crm_cust_info (LIKE bronze.crm_cust_info INCLUDING ALL);
CREATE TABLE silver.crm_prd_info (LIKE bronze.crm_prd_info INCLUDING ALL);
CREATE TABLE silver.crm_sales_details (LIKE bronze.crm_sales_details INCLUDING ALL);
CREATE TABLE silver.erp_cust_az12 (LIKE bronze.erp_cust_az12 INCLUDING ALL);
CREATE TABLE silver.erp_loc_a101 (LIKE bronze.erp_loc_a101 INCLUDING ALL);
CREATE TABLE silver.erp_px_cat_g1v2 (LIKE bronze.erp_px_cat_g1v2 INCLUDING ALL);

COMMENT ON SCHEMA silver IS 'Silver layer: cleaned and standardized data.';
