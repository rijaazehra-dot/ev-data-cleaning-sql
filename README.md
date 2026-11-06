# ev-data-cleaning-sql
End-to-end data cleaning, deduplication, and anomaly resolution on electric vehicle datasets using SQL Server.
Project Overview: What dataset you used (Electric Vehicle population data).

Tools Used: SQL Server Management Studio (SSMS).

Key Steps Performed: Handling import errors, removing duplicate rows, standardizing text formatting, and resolving NULL values.
# 🚗 Electric Vehicle Data Cleaning & Standardization (SQL Server)

## 📌 Project Overview
This project focuses on cleaning, deduplicating, and standardizing a raw dataset of over 18,000+ Electric Vehicle (EV) records using **Microsoft SQL Server Management Studio (SSMS)**. 

The goal of this project was to transform raw data containing import errors, duplicate rows, whitespace issues, and missing values into a structured, validated dataset ready for downstream analysis and business intelligence reporting.

---

## 🛠️ Tools & Technologies Used
* **Database Engine:** SQL Server Management Studio (SSMS)
* **Language:** T-SQL (Transact-SQL)
* **Techniques:** Common Table Expressions (CTEs), Window Functions (`ROW_NUMBER()`), Data Transformation, Data Validation

---

## 🧹 Data Cleaning & Transformation Workflow

### 1. Handling Import & Schema Errors
Resolved data truncation errors during flat-file import by adjusting column data types (e.g., expanding `Electric_Utility` column width to accommodate longer text strings).

### 2. Deduplication using CTE & Window Functions
Identified and removed exact duplicate records based on the unique vehicle identifier (`VIN_1_10`) using a Common Table Expression (CTE) combined with `ROW_NUMBER()`.

```sql
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

UPDATE export
SET 
    VIN_1_10 = UPPER(LTRIM(RTRIM(VIN_1_10))),
    County = LTRIM(RTRIM(County)),
    City = LTRIM(RTRIM(City)),
    State = UPPER(LTRIM(RTRIM(State))),
    Make = UPPER(LTRIM(RTRIM(Make))),
    Model = UPPER(LTRIM(RTRIM(Model))),
    Electric_Vehicle_Type = LTRIM(RTRIM(Electric_Vehicle_Type));

SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN VIN_1_10 IS NULL OR VIN_1_10 = '' THEN 1 ELSE 0 END) AS Null_VIN,
    SUM(CASE WHEN County IS NULL OR County = '' THEN 1 ELSE 0 END) AS Null_County,
    SUM(CASE WHEN City IS NULL OR City = '' THEN 1 ELSE 0 END) AS Null_City,
    SUM(CASE WHEN Make IS NULL OR Make = '' THEN 1 ELSE 0 END) AS Null_Make,
    SUM(CASE WHEN Model IS NULL OR Model = '' THEN 1 ELSE 0 END) AS Null_Model
FROM export;
