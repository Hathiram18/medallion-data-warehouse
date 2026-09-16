# medallion-data-warehouse
End-to-end PostgreSQL Data Warehouse implementing a Bronze–Silver–Gold Medallion Architecture with ETL pipelines, PL/pgSQL procedures, dimensional modeling, and data quality validation.

                  CRM CSV FILES
        ┌────────────────────────────┐
        │ Customer                    │
        │ Product                     │
        │ Sales                       │
        └──────────────┬─────────────┘
                       │
                       │
                  ERP CSV FILES
        ┌──────────────┴─────────────┐
        │ Customer Master             │
        │ Location                    │
        │ Product Category            │
        └──────────────┬─────────────┘
                       │
                       ▼
                ┌────────────┐
                │   BRONZE   │
                │ Raw data   │
                └─────┬──────┘
                      │
               Cleaning /
               Standardization
                      │
                      ▼
                ┌────────────┐
                │   SILVER   │
                │ Clean data │
                └─────┬──────┘
                      │
                Data modeling
                      │
                      ▼
                ┌────────────┐
                │    GOLD    │
                │ Star schema│
                └─────┬──────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Customer     Product     Sales
       Dimension   Dimension     Fact
