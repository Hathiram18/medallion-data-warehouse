# medallion-data-warehouse
End-to-end PostgreSQL Data Warehouse implementing a Bronze–Silver–Gold Medallion Architecture with ETL pipelines, PL/pgSQL procedures, dimensional modeling, and data quality validation.

## Project Architecture

```mermaid
flowchart TD

    CRM["CRM CSV Files<br/><br/>Customer<br/>Product<br/>Sales"]
    ERP["ERP CSV Files<br/><br/>Customer Master<br/>Location<br/>Product Category"]

    BRONZE["BRONZE LAYER<br/><br/>Raw Data"]
    SILVER["SILVER LAYER<br/><br/>Cleaning & Standardization"]
    GOLD["GOLD LAYER<br/><br/>Business-Ready Star Schema"]

    DC["Customer Dimension"]
    DP["Product Dimension"]
    FS["Sales Fact"]

    CRM --> BRONZE
    ERP --> BRONZE

    BRONZE --> SILVER
    SILVER --> GOLD

    GOLD --> DC
    GOLD --> DP
    GOLD --> FS
