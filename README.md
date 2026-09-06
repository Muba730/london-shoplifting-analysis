# London Shoplifting Analysis

An analysis of recorded shoplifting in London between 2023 and 2025, using SQL Server for data preparation and modelling and Power BI for visualisation.

The project brings together crime records, annual retail unit counts and postcode references to explore how shoplifting has changed, which boroughs face the greatest pressure and when incidents peak. These findings inform decisions about where retailers could direct security resources.

## SQL files

| File | Purpose |
| --- | --- |
| [01_create_and_load_raw_tables.sql](sql/01_create_and_load_raw_tables.sql) | Creates raw tables and loads source CSV files. |
| [02_clean_and_model_data.sql](sql/02_clean_and_model_data.sql) | Filters shoplifting records, standardises dates, combines 2011 and 2021 geographic codes and creates a shared borough dimension. |
| [03_data_quality_checks.sql](sql/03_data_quality_checks.sql) | Checks missing values, duplicates, retail counts and geographic coverage, with further cleaning steps. |

The model keeps individual crime incidents separate from annual retail counts and connects them through borough codes.

## Working with the scripts

The scripts assume that `ShopliftingDB` and the `Raw` and `clean` schemas already exist. Source CSV files are not included; the import paths refer to the original local setup. Some statements recreate tables or delete records as part of cleaning.

The repository currently contains the SQL scripts. The report and Power BI dashboard can be added as the project develops.
