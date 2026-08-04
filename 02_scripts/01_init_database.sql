-- Optional: Create the database (run while connected to the postgres database)
-- CREATE DATABASE datawarehouse;

-- Connect to the database before executing the remaining commands.
-- Example (psql):
-- \c datawarehouse

-- Create schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

COMMENT ON SCHEMA bronze IS 'Raw ingestion layer';
COMMENT ON SCHEMA silver IS 'Cleaned and standardized layer';
COMMENT ON SCHEMA gold IS 'Business-ready reporting layer';
