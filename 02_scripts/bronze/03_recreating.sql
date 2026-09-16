DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num   VARCHAR(50),
    sls_prd_key   VARCHAR(50),
    sls_cust_id   INTEGER,
    sls_order_dt  INTEGER,
    sls_ship_dt   INTEGER,
    sls_due_dt    INTEGER,
    sls_sales     NUMERIC(10,2),
    sls_quantity  INTEGER,
    sls_price     NUMERIC(10,2)
);