-- ======================================================
-- Script  : clean_london_postcodes.sql
-- Schema  : clean
-- Table   : clean.london_postcodes
-- Source  : Raw.london_postcodes
-- ======================================================
-- Transformations applied:
--     - Filters to active postcodes only (in_use = 'Yes')
--     - Loads LSOA codes twice — 2011 and 2021 boundary
--       vintages — so crime records using either code can
--       find a postcode match. UNION deduplicates rows
--       where both vintages are identical.
--     - Adds district_code for borough-level joins.
-- ======================================================

USE ShopliftingDB;
GO

DROP TABLE IF EXISTS clean.london_postcodes;

CREATE TABLE clean.london_postcodes (
    postcode        VARCHAR(10),
    latitude        DECIMAL(10, 6),
    longitude       DECIMAL(10, 6),
    ward            VARCHAR(100),
    district        VARCHAR(100),
    district_code   VARCHAR(10),
    region          VARCHAR(50),
    lsoa_code       VARCHAR(10),
    lsoa_name       VARCHAR(100)
);
GO

INSERT INTO clean.london_postcodes
-- 2011 LSOA codes
SELECT
    postcode, latitude, longitude, ward, district, district_code, region,
    lsoa_code                        AS lsoa_code,
    lower_layer_super_output_area    AS lsoa_name
FROM Raw.london_postcodes
WHERE in_use    = 'Yes'
AND   lsoa_code IS NOT NULL
AND   lsoa_code <> ''

UNION

-- 2021 LSOA codes
SELECT
    postcode, latitude, longitude, ward, district, district_code, region,
    lsoa21_code                         AS lsoa_code,
    lower_layer_super_output_area_2021  AS lsoa_name
FROM Raw.london_postcodes
WHERE in_use      = 'Yes'
AND   lsoa21_code IS NOT NULL
AND   lsoa21_code <> '';
GO

-- ======================================================
-- Script  : clean_london_crime_2023_2025.sql
-- Schema  : clean
-- Table   : clean.london_crime_2023_2025
-- Source  : Raw.london_crime_2023_2025
-- ======================================================
-- Transformations applied:
--     - Filters to Shoplifting only
--     - Drops: last_outcome_category, context
--     - Renames crime_month to date, converts to DATE type
--     - Derives district and district_code from lsoa_code
--       via london_postcodes for borough-level analysis
-- ======================================================

USE ShopliftingDB;
GO

DROP TABLE IF EXISTS clean.london_crime_2023_2025;

CREATE TABLE clean.london_crime_2023_2025 (
    crime_id        VARCHAR(100),
    date            DATE,
    reported_by     VARCHAR(30),
    falls_within    VARCHAR(30),
    longitude       DECIMAL(10, 6),
    latitude        DECIMAL(10, 6),
    location        VARCHAR(60),
    lsoa_code       VARCHAR(10),
    lsoa_name       VARCHAR(45),
    crime_type      VARCHAR(35),
    district        VARCHAR(100),
    district_code   VARCHAR(10)
);
GO

-- -------------------------------------------------------
-- Step 1: Insert shoplifting records
-- crime_month arrives as 'YYYY-MM'; appending '-01' and
-- casting to DATE gives the first day of the reported month.
-- district and district_code filled in Step 2.
-- -------------------------------------------------------
INSERT INTO clean.london_crime_2023_2025
    (crime_id, date, reported_by, falls_within, longitude, latitude,
     location, lsoa_code, lsoa_name, crime_type, district, district_code)
SELECT
    crime_id,
    CAST(crime_month + '-01' AS DATE)   AS date,
    reported_by,
    falls_within,
    longitude,
    latitude,
    location,
    lsoa_code,
    lsoa_name,
    TRIM(crime_type)                    AS crime_type,
    NULL                                AS district,
    NULL                                AS district_code
FROM Raw.london_crime_2023_2025
WHERE TRIM(crime_type) = 'Shoplifting';
GO

-- -------------------------------------------------------
-- Step 2: Derive district and district_code from lsoa_code
-- Joins directly to london_postcodes on lsoa_code —
-- the authoritative, vintage-safe source for borough
-- attribution. Uses DISTINCT to avoid duplicates from
-- the 2011/2021 dual-vintage rows.
-- -------------------------------------------------------
UPDATE c
SET    c.district      = lp.district,
       c.district_code = lp.district_code
FROM   clean.london_crime_2023_2025 c
LEFT JOIN (
    SELECT DISTINCT lsoa_code, district, district_code
    FROM   clean.london_postcodes
    WHERE  district_code IS NOT NULL
    AND    district      IS NOT NULL
) lp ON c.lsoa_code = lp.lsoa_code;
GO

-- ======================================================
-- Data Quality Checks
-- ======================================================

-- -------------------------------------------------------
-- Check 1: Total records loaded
-- -------------------------------------------------------
SELECT COUNT(*) AS total_records
FROM   clean.london_crime_2023_2025;
GO

-- -------------------------------------------------------
-- Check 2: Records with no district assigned
-- Expected: small number of out-of-london records whose
-- lsoa_code does not exist in london_postcodes.
-- -------------------------------------------------------
SELECT COUNT(*) AS null_districts
FROM   clean.london_crime_2023_2025
WHERE  district  IS NULL
AND    lsoa_code IS NOT NULL;
GO

-- -------------------------------------------------------
-- Check 3: Which LSOAs have no district match?
-- Expected: LSOAs outside the Greater london boundary
-- with no entry in london_postcodes. These records will
-- be excluded from borough-level analysis in Power BI.
-- -------------------------------------------------------
SELECT
    lsoa_code,
    lsoa_name,
    COUNT(*) AS records
FROM   clean.london_crime_2023_2025
WHERE  district  IS NULL
AND    lsoa_code IS NOT NULL
GROUP BY lsoa_code, lsoa_name
ORDER BY records DESC;
GO

-- ======================================================
-- Script  : clean_london_retail_2023_2025.sql
-- Schema  : clean
-- Table   : clean.london_Retail_2023_2025
-- Source  : Raw.london_Retail_2023_2025
-- ======================================================
-- Transformations applied:
--     - Converts Year from SMALLINT to DATE by appending
--       '-01-01' (e.g. 2023 → 2023-01-01) so Power BI
--       can treat it as a time axis.
--     - All other columns passed through unchanged.
-- ======================================================

USE ShopliftingDB;
GO

DROP TABLE IF EXISTS clean.london_retail_2023_2025;

CREATE TABLE clean.london_Retail_2023_2025 (
    District_Code   VARCHAR(10),
    Area            VARCHAR(60),
    Year            DATE,
    Retail_Count    INT
);
GO

INSERT INTO clean.london_retail_2023_2025
SELECT
    District_Code,
    Area,
    CAST(CAST(Year AS VARCHAR(4)) + '-01-01' AS DATE)   AS Year,
    Retail_Count
FROM Raw.london_Retail_2023_2025;
GO

-- ======================================================
-- Script  : clean_borough_dim.sql
-- Schema  : clean
-- Table   : clean.borough_dim
-- Source  : clean.london_postcodes
-- ======================================================
-- Purpose:
--     Creates a borough dimension table with one distinct
--     row per london borough. Connects clean.london_crime_2023_2025
--     and clean.london_Retail_2023_2025 to borough-level
--     attributes via district_code.
-- ======================================================
--
--         clean.london_Retail_2023_2025 (many)
--              --> clean.borough_dim (one)  [on district_code]
--         clean.london_crime_2023_2025 (many)
--              --> clean.borough_dim (one)  [on district_code]
--
-- Note:
--     Run clean_london_postcodes.sql before this script.
--     Expected output: 33 rows (one per london borough).
-- ======================================================

USE ShopliftingDB;
GO

DROP TABLE IF EXISTS clean.borough_dim;

CREATE TABLE clean.borough_dim (
    district_code   VARCHAR(10),
    district        VARCHAR(100)
);
GO

INSERT INTO clean.borough_dim
SELECT DISTINCT
    district_code,
    MIN(district) AS district
FROM clean.london_postcodes
WHERE district_code IS NOT NULL
AND   district_code <> ''
GROUP BY district_code;
GO

-- Verify: should be 33 rows
SELECT * FROM clean.borough_dim ORDER BY district;
GO
