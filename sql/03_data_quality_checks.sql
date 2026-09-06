-- Data Quality and Further Cleaning Scripts

-- These scripts are run after the Clean tables have been created
-- to validate data quality before proceeding with analysis.


-- London Postcode
-- ============================================
-- SECTION 1A: Count NULLs in each column
-- ============================================
SELECT
    SUM(CASE WHEN postcode   IS NULL THEN 1 END) AS postcode_nulls,
    SUM(CASE WHEN latitude   IS NULL THEN 1 END) AS latitude_nulls,
    SUM(CASE WHEN longitude  IS NULL THEN 1 END) AS longitude_nulls,
    SUM(CASE WHEN ward       IS NULL THEN 1 END) AS ward_nulls,
    SUM(CASE WHEN district   IS NULL THEN 1 END) AS district_nulls,
    SUM(CASE WHEN region     IS NULL THEN 1 END) AS region_nulls,
    SUM(CASE WHEN lsoa_code  IS NULL THEN 1 END) AS lsoa_code_nulls,
    SUM(CASE WHEN lsoa_name  IS NULL THEN 1 END) AS lsoa_name_nulls
FROM clean.london_postcodes;
-- Result: No NULLs found across any column. Proceeding to next check.
-- ============================================
-- SECTION 1B: Check for leading/trailing spaces
-- ============================================
SELECT
    SUM(CASE WHEN postcode   <> LTRIM(RTRIM(postcode))   THEN 1 END) AS postcode_spaces,
    SUM(CASE WHEN latitude   <> LTRIM(RTRIM(latitude))   THEN 1 END) AS latitude_spaces,
    SUM(CASE WHEN longitude  <> LTRIM(RTRIM(longitude))  THEN 1 END) AS longitude_spaces,
    SUM(CASE WHEN ward       <> LTRIM(RTRIM(ward))       THEN 1 END) AS ward_spaces,
    SUM(CASE WHEN district   <> LTRIM(RTRIM(district))   THEN 1 END) AS district_spaces,
    SUM(CASE WHEN region     <> LTRIM(RTRIM(region))     THEN 1 END) AS region_spaces,
    SUM(CASE WHEN lsoa_code  <> LTRIM(RTRIM(lsoa_code))  THEN 1 END) AS lsoa_code_spaces,
    SUM(CASE WHEN lsoa_name  <> LTRIM(RTRIM(lsoa_name))  THEN 1 END) AS lsoa_name_spaces
FROM clean.london_postcodes;
-- Result: No leading or trailing spaces detected. Proceeding to next check.
-- ============================================
-- SECTION 1C: Identify duplicate postcodes
-- ============================================
SELECT 
    postcode,
    COUNT(*) AS duplicate_count
FROM clean.london_postcodes
GROUP BY postcode
HAVING COUNT(*) > 1;
-- Result: Duplicates are expected and require no action.
-- london_postcodes was intentionally built using a UNION of 2011 and 2021
-- LSOA boundary vintages, meaning each postcode appears twice — once keyed
-- on its 2011 LSOA code and once on its 2021 code. This is by design,
-- accounting for the fact that the Metropolitan Police publishes crime data
-- using both 2011 and 2021 LSOA codes depending on the period of publication.



-- London Crime 

-- ============================================
-- SECTION 2A: Count NULLs in key crime columns
-- ============================================

SELECT
    SUM(CASE WHEN date        IS NULL THEN 1 END) AS date_nulls,
    SUM(CASE WHEN longitude   IS NULL THEN 1 END) AS longitude_nulls,
    SUM(CASE WHEN latitude    IS NULL THEN 1 END) AS latitude_nulls,
    SUM(CASE WHEN lsoa_code   IS NULL THEN 1 END) AS lsoa_code_nulls,
    SUM(CASE WHEN lsoa_name   IS NULL THEN 1 END) AS lsoa_name_nulls,
    SUM(CASE WHEN crime_type  IS NULL THEN 1 END) AS crime_type_nulls
FROM clean.london_crime_2023_2025;

-- ============================================
-- SECTION 2B: Inspect rows with missing values
-- ============================================

SELECT *
FROM clean.london_crime_2023_2025_
WHERE date       IS NULL
   OR longitude  IS NULL
   OR latitude   IS NULL
   OR lsoa_code  IS NULL
   OR lsoa_name  IS NULL
   OR crime_type IS NULL;

-- ============================================
-- SECTION 2C: Delete rows with NULLs in key fields
-- ============================================

DELETE FROM clean.london_crime_2023_2025_
WHERE date       IS NULL
   OR longitude  IS NULL
   OR latitude   IS NULL
   OR lsoa_code  IS NULL
   OR lsoa_name  IS NULL
   OR crime_type IS NULL;


 -- ============================================
-- SECTION 2D: Check for leading/trailing spaces
-- ============================================

SELECT
    SUM(CASE WHEN date       <> LTRIM(RTRIM(date))       THEN 1 END) AS date_spaces,
    SUM(CASE WHEN longitude  <> LTRIM(RTRIM(longitude))  THEN 1 END) AS longitude_spaces,
    SUM(CASE WHEN latitude   <> LTRIM(RTRIM(latitude))   THEN 1 END) AS latitude_spaces,
    SUM(CASE WHEN lsoa_code  <> LTRIM(RTRIM(lsoa_code))  THEN 1 END) AS lsoa_code_spaces,
    SUM(CASE WHEN lsoa_name  <> LTRIM(RTRIM(lsoa_name))  THEN 1 END) AS lsoa_name_spaces,
    SUM(CASE WHEN crime_type <> LTRIM(RTRIM(crime_type)) THEN 1 END) AS crime_type_spaces
FROM clean.london_crime_2023_2025_;


-- ============================================
-- SECTION 2E: Identify duplicate crime_id values
-- ============================================

SELECT 
    crime_id,
    COUNT(*) AS duplicate_count
FROM clean.london_crime_2023_2025_
GROUP BY crime_id
HAVING COUNT(*) > 1;

-- ============================================
-- SECTION 2F: View duplicate rows by crime_id
-- ============================================

SELECT c.*
FROM clean.london_crime_2023_2025_ c
INNER JOIN (
    SELECT crime_id
    FROM clean.london_crime_2023_2025_
    GROUP BY crime_id
    HAVING COUNT(*) > 1
) d
ON c.crime_id = d.crime_id
ORDER BY c.crime_id;


-- ============================================
-- SECTION 2G: Delete duplicate crime rows
-- Keep the first occurrence of each crime_id
-- ============================================

WITH d AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY crime_id
            ORDER BY crime_id
        ) AS rn
    FROM clean.london_crime_2023_2025_
)
DELETE FROM d
WHERE rn > 1;

-- ======================================================
-- Script  : london_retail_2023_2025.sql
-- Schema  : clean
-- Table   : clean.london_Retail_2023_2025
-- Purpose : Data quality checks post-transformation
-- ======================================================

-- ============================================
-- SECTION 3A: Row Count
-- ============================================
SELECT COUNT(*) AS total_rows
FROM clean.london_Retail_2023_2025;

-- ============================================
-- SECTION 3B: Count NULLs in key columns
-- ============================================
SELECT
    SUM(CASE WHEN District_Code  IS NULL THEN 1 ELSE 0 END) AS district_code_nulls,
    SUM(CASE WHEN Area           IS NULL THEN 1 ELSE 0 END) AS area_nulls,
    SUM(CASE WHEN Year           IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    SUM(CASE WHEN Retail_Count   IS NULL THEN 1 ELSE 0 END) AS retail_count_nulls
FROM clean.london_Retail_2023_2025;


-- ============================================
-- SECTION 3C: Check for leading/trailing spaces
-- ============================================
SELECT
    SUM(CASE WHEN District_Code <> LTRIM(RTRIM(District_Code)) THEN 1 ELSE 0 END) AS district_code_spaces,
    SUM(CASE WHEN Area          <> LTRIM(RTRIM(Area))          THEN 1 ELSE 0 END) AS area_spaces
FROM clean.london_Retail_2023_2025;

-- ============================================
-- SECTION 3D: Check Year conversion is correct
-- Expected: only 2023-01-01, 2024-01-01, 2025-01-01
-- ============================================
SELECT DISTINCT Year, COUNT(*) AS row_count
FROM Clean.London_Retail_2023_2025
GROUP BY Year
ORDER BY Year;

-- ============================================
-- SECTION 3E: Check Retail_Count is valid
-- No negatives, no zeros
-- ============================================
SELECT
    MIN(Retail_Count)   AS min_retail_count,
    MAX(Retail_Count)   AS max_retail_count,
    AVG(Retail_Count)   AS avg_retail_count,
    SUM(CASE WHEN Retail_Count <= 0 THEN 1 ELSE 0 END) AS zero_or_negative
FROM Clean.London_Retail_2023_2025;

-- ============================================
-- SECTION 3F: Check all 33 London boroughs present
-- per year
-- ============================================
SELECT Year, COUNT(DISTINCT District_Code) AS borough_count
FROM Clean.London_Retail_2023_2025
GROUP BY Year
ORDER BY Year;

-- ============================================
-- SECTION 3G: Check for duplicate District_Code
-- per year
-- ============================================
SELECT District_Code, Year, COUNT(*) AS duplicate_count
FROM Clean.London_Retail_2023_2025
GROUP BY District_Code, Year
HAVING COUNT(*) > 1;


