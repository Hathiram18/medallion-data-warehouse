CREATE TABLE bronze.crm_cust_info (
    cst_id             INTEGER,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE
);

CREATE TABLE bronze.crm_prd_info (
    prd_id       INTEGER,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     NUMERIC(10,2),
    prd_line     VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt   DATE
);

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INTEGER,
    sls_order_dt DATE,
    sls_ship_dt  DATE,
    sls_due_dt   DATE,
    sls_sales     NUMERIC(10,2),
    sls_quantity  INTEGER,
    sls_price     NUMERIC(10,2)
);

CREATE TABLE bronze.erp_cust_az12 (
    cid       VARCHAR(50),
    bdate     DATE,
    gen       VARCHAR(20)
);

CREATE TABLE bronze.erp_loc_a101 (
    cid      VARCHAR(50),
    cntry    VARCHAR(100)
);

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id          VARCHAR(50),
    cat         VARCHAR(100),
    subcat      VARCHAR(100),
    maintenance VARCHAR(100)
);