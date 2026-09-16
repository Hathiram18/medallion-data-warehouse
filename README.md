# medallion-data-warehouse
End-to-end PostgreSQL Data Warehouse implementing a Bronze–Silver–Gold Medallion Architecture with ETL pipelines, PL/pgSQL procedures, dimensional modeling, and data quality validation.


## 🏗️ Data Warehouse Architecture

```mermaid
flowchart TD

    CRM["CRM Source Files<br/><br/>cust_info.csv<br/>prd_info.csv<br/>sales_details.csv"]

    ERP["ERP Source Files<br/><br/>CUST_AZ12.csv<br/>LOC_A101.csv<br/>PX_CAT_G1V2.csv"]

    B["🥉 BRONZE LAYER<br/><br/>Raw Data<br/>6 Source Tables"]

    S["🥈 SILVER LAYER<br/><br/>Cleaned & Standardized Data<br/><br/>Deduplication • Validation • Transformation"]

    G["🥇 GOLD LAYER<br/><br/>Business-Ready Star Schema"]

    C["dim_customers<br/><br/>18,484 Customers"]

    P["dim_products<br/><br/>295 Current Products"]

    F["fact_sales<br/><br/>60,398 Sales Records"]

    CRM --> B
    ERP --> B

    B --> S
    S --> G

    G --> C
    G --> P
    G --> F

    C -. customer_key .-> F
    P -. product_key .-> F
