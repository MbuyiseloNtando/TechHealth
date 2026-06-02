# Data Warehouse Project – OLTP to DWH Pipeline

## Overview
This project builds a Tech Health data warehouse from a relational source database. It enforces column constraints (NOT NULL, UNIQUE, CHECK, FK) at every stage to guarantee data integrity.

### Tech Stack
- **Source DB**: Microsoft SQL Server
- **DWH**: Microsoft SQL Server
- **ETL**: Microsoft SQL Server

## Star Schema Design
- **Dimensions**: Date, Coach, Location, Products, Customers, Devices
- **Facts**: Coach assignments, Devices, Sales, Health Metrics
- **Constraints**: primary keys, foreign keys, NOT NULL, range inputs, 

## How to Run
1 Set up database (`TechHealthDB_create.sql`)
2 Create data warehose (`TechHealthDW_Create.sql`)


## Data Integrity Features
- **Source DB**: PRIMARY KEY, FOREIGN KEY, NOT NULL, CHECK constraints.
- **DWH**: Same constraints + surrogate keys  for dimensions.
- **ETL**: Data type validation,  referential integrity checks before load.

## Future Improvements
- Incremental loading (CDC)
- Add monitoring (dbt, Great Expectations)
