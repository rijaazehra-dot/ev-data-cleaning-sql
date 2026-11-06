

WITH CTE_Duplicates AS (
    SELECT 
        VIN_1_10,
        ROW_NUMBER() OVER (
            PARTITION BY VIN_1_10 
            ORDER BY (SELECT NULL)
        ) AS row_num
    FROM export
)
DELETE FROM CTE_Duplicates
WHERE row_num > 1;

-- Standardize whitespace and text formatting across key columns in the export table
UPDATE export
SET 
    VIN_1_10 = UPPER(LTRIM(RTRIM(VIN_1_10))),
    County = LTRIM(RTRIM(County)),
    City = LTRIM(RTRIM(City)),
    State = UPPER(LTRIM(RTRIM(State))),
    Make = UPPER(LTRIM(RTRIM(Make))),
    Model = UPPER(LTRIM(RTRIM(Model))),
    Electric_Vehicle_Type = LTRIM(RTRIM(Electric_Vehicle_Type));

-- Option 1: Remove rows where critical columns contain NULL or empty values
DELETE FROM export
WHERE VIN_1_10 IS NULL OR VIN_1_10 = ''
   OR County IS NULL OR County = ''
   OR City IS NULL OR City = ''
   OR Make IS NULL OR Make = ''
   OR Model IS NULL OR Model = '';

-- Option 2: Replace NULL or blank values with a default placeholder (e.g., 'UNKNOWN')
UPDATE export
SET 
    County = ISNULL(NULLIF(County, ''), 'UNKNOWN'),
    City = ISNULL(NULLIF(City, ''), 'UNKNOWN'),
    Make = ISNULL(NULLIF(Make, ''), 'UNKNOWN'),
    Model = ISNULL(NULLIF(Model, ''), 'UNKNOWN'),
    Electric_Vehicle_Type = ISNULL(NULLIF(Electric_Vehicle_Type, ''), 'UNKNOWN');




    SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN VIN_1_10 IS NULL OR VIN_1_10 = '' THEN 1 ELSE 0 END) AS Null_VIN,
    SUM(CASE WHEN County IS NULL OR County = '' THEN 1 ELSE 0 END) AS Null_County,
    SUM(CASE WHEN City IS NULL OR City = '' THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN Make IS NULL OR Make = '' THEN 1 ELSE 0 END) AS Null_Make,
    SUM(CASE WHEN Model IS NULL OR Model = '' THEN 1 ELSE 0 END) AS Null_Model
FROM export;