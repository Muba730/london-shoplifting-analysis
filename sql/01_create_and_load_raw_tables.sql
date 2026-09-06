
-- =============================================================
-- Create Tables in Raw Schema
-- =============================================================

USE ShopliftingDB;

-- ======================================================
-- Table: Raw.london_postcodes
-- ======================================================

GO

DROP TABLE IF EXISTS Raw.london_postcodes;
 
CREATE TABLE Raw.london_postcodes (
    postcode                            VARCHAR(10)     NOT NULL,
    in_use                              VARCHAR(3),
    latitude                            DECIMAL(10, 6),
    longitude                           DECIMAL(10, 6),
    easting                             INT,
    northing                            INT,
    grid_ref                            VARCHAR(10),
    county                              VARCHAR(100),
    district                            VARCHAR(100),
    ward                                VARCHAR(100),
    district_code                       VARCHAR(20),
    ward_code                           VARCHAR(20),
    country                             VARCHAR(50),
    county_code                         VARCHAR(20),
    parish                              VARCHAR(150),
    national_park                       VARCHAR(100),
    built_up_area                       VARCHAR(100),
    lower_layer_super_output_area       VARCHAR(100),
    region                              VARCHAR(50),
    altitude                            INT,
    london_zone                         TINYINT,
    lsoa_code                           VARCHAR(20),
    msoa_code                           VARCHAR(20),
    middle_layer_super_output_area      VARCHAR(100),
    parish_code                         VARCHAR(20),
    census_output_area                  VARCHAR(20),
    index_of_multiple_deprivation       INT,
    quality                             TINYINT,
    user_type                           TINYINT,
    nearest_station                     VARCHAR(100),
    distance_to_station                 DECIMAL(10, 7),
    postcode_area                       VARCHAR(5),
    postcode_district                   VARCHAR(10),
    police_force                        VARCHAR(50),
    plus_code                           VARCHAR(20),
    average_income                      INT,
    travel_to_work_area                 VARCHAR(100),
    itl_level_2                         VARCHAR(100),
    itl_level_3                         VARCHAR(100),
    uprns                               TEXT,
    distance_to_sea                     DECIMAL(10, 4),
    lsoa21_code                         VARCHAR(20),
    lower_layer_super_output_area_2021  VARCHAR(100),
    msoa21_code                         VARCHAR(20),
    middle_layer_super_output_area_2021 VARCHAR(100),
    census_output_area_2021             VARCHAR(20),
    constituency_code_2024              VARCHAR(20),
    constituency_name_2024              VARCHAR(100),
    property_type                       VARCHAR(50),
    roads                               VARCHAR(2000),
    fixphrase                           VARCHAR(100),
    rural_urban_2021                    VARCHAR(100),
    PRIMARY KEY (postcode)
);

GO
TRUNCATE TABLE Raw.london_postcodes;

GO
BULK INSERT Raw.london_postcodes
FROM 'C:\Shoplifting_UK_2025\Data\London_postcodes_clean.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    CODEPAGE = '65001',
    TABLOCK
);

-- ======================================================
-- Table: Raw.london_crime_2023_2025
-- ======================================================

GO
DROP TABLE IF EXISTS Raw.london_crime_2023_2025;
 
CREATE TABLE Raw.london_crime_2023_2025 (
    crime_id                    VARCHAR(64),
    crime_month                 CHAR(7),
    reported_by                 VARCHAR(30),
    falls_within                VARCHAR(30),
    longitude                   DECIMAL(10, 6),
    latitude                    DECIMAL(10, 6),
    location                    VARCHAR(60),
    lsoa_code                   VARCHAR(10),
    lsoa_name                   VARCHAR(45),
    crime_type                  VARCHAR(35),
    last_outcome_category       VARCHAR(55),
    context                     VARCHAR(255)
);

GO
TRUNCATE TABLE Raw.london_crime_2023_2025;

GO
BULK INSERT Raw.london_crime_2023_2025
FROM 'C:\Shoplifting_UK_2025\Data\London_Crime_2023-2025.csv'
WITH (
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
 
-- ======================================================
-- Table: Raw.london_Retail
-- ======================================================
USE ShopliftingDB;
GO

DROP TABLE IF EXISTS Raw.London_Retail_2023_2025;

CREATE TABLE Raw.London_Retail_2023_2025 (
    District_Code   VARCHAR(10),
    Area            VARCHAR(60),
    Year            INT,
    Retail_Count    INT
);
GO

BULK INSERT Raw.London_Retail_2023_2025
FROM 'C:\Shoplifting_UK_2025\Data\london_retail.csv'
WITH (
    FIRSTROW        = 2,
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIELDTERMINATOR = ',',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- ======================================================
-- Table: Raw.london_shoplifting_total_2020_2025
-- ======================================================
USE ShopliftingDB;
GO
DROP TABLE IF EXISTS Raw.london_shoplifting_total_2020_2025;
 
CREATE TABLE Raw.london_shoplifting_total_2020_2025 (
    year                        INT,
    city_of_london              INT,
    metropolitan_police         INT,
    london                      INT
);
GO
TRUNCATE TABLE Raw.london_shoplifting_total_2020_2025;
GO
BULK INSERT Raw.london_shoplifting_total_2020_2025
FROM 'C:\Shoplifting_UK_2025\Data\london_Shoplifting_Total_2020_2025.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    CODEPAGE = '65001',
    TABLOCK
);