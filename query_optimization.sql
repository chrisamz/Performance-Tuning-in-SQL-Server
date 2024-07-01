-- query_optimization.sql
-- This script contains optimized queries

-- Example: Optimizing a SELECT query with proper indexing and avoiding SELECT *
-- Original Query
-- SELECT * FROM your_table_name WHERE example_column = 'some_value';

-- Optimized Query
SELECT
    column1,
    column2,
    column3
FROM
    your_table_name
WHERE
    example_column = 'some_value';

-- Example: Using indexed columns in JOIN conditions and WHERE clauses
-- Original Query
-- SELECT a.*, b.*
-- FROM table_a a
-- JOIN table_b b ON a.id = b.a_id
-- WHERE a.status = 'active';

-- Optimized Query
SELECT
    a.column1,
    a.column2,
    b.column3,
    b.column4
FROM
    table_a a
JOIN
    table_b b ON a.id = b.a_id
WHERE
    a.status = 'active';

-- Example: Using EXISTS instead of IN for subqueries
-- Original Query
-- SELECT column1, column2
-- FROM your_table_name
-- WHERE column3 IN (SELECT column3 FROM another_table WHERE column4 = 'some_value');

-- Optimized Query
SELECT
    yt.column1,
    yt.column2
FROM
    your_table_name yt
WHERE
    EXISTS (SELECT 1 FROM another_table at WHERE at.column3 = yt.column3 AND at.column4 = 'some_value');

-- Example: Avoiding functions on columns in WHERE clauses
-- Original Query
-- SELECT column1, column2
-- FROM your_table_name
-- WHERE UPPER(column3) = 'SOME_VALUE';

-- Optimized Query
SELECT
    column1,
    column2
FROM
    your_table_name
WHERE
    column3 = 'some_value';

-- Example: Using SET NOCOUNT ON to reduce network traffic
-- Original Query
-- SELECT column1, column2 FROM your_table_name;

-- Optimized Query
SET NOCOUNT ON;

SELECT
    column1,
    column2
FROM
    your_table_name;

SET NOCOUNT OFF;

-- Example: Using appropriate data types and avoiding implicit conversions
-- Original Query
-- SELECT column1 FROM your_table_name WHERE varchar_column = 123;

-- Optimized Query
SELECT
    column1
FROM
    your_table_name
WHERE
    varchar_column = '123';

-- Example: Using indexed views for complex aggregations
-- Original Query
-- SELECT region, COUNT(*) AS total_sales
-- FROM sales_table
-- GROUP BY region;

-- Optimized Query
-- Create an indexed view
CREATE VIEW vw_total_sales
WITH SCHEMABINDING
AS
SELECT
    region,
    COUNT_BIG(*) AS total_sales
FROM
    dbo.sales_table
GROUP BY
    region;

-- Create a unique clustered index on the view
CREATE UNIQUE CLUSTERED INDEX idx_vw_total_sales
ON vw_total_sales (region);

-- Query the indexed view
SELECT
    region,
    total_sales
FROM
    vw_total_sales;

-- Example: Using table variables instead of temporary tables for small datasets
-- Original Query
-- CREATE TABLE #temp_table (id INT, value VARCHAR(50));
-- INSERT INTO #temp_table SELECT id, value FROM your_table_name WHERE condition;
-- SELECT * FROM #temp_table;

-- Optimized Query
DECLARE @temp_table TABLE (id INT, value VARCHAR(50));
INSERT INTO @temp_table SELECT id, value FROM your_table_name WHERE condition;
SELECT * FROM @temp_table;

-- Example: Optimizing a DELETE query with proper indexing and conditions
-- Original Query
-- DELETE FROM your_table_name WHERE condition;

-- Optimized Query
DELETE TOP (1000)
FROM
    your_table_name
WHERE
    condition;

-- Example: Using CTEs for better readability and maintainability
-- Original Query
-- SELECT column1, column2 FROM your_table_name WHERE condition1;
-- SELECT column3, column4 FROM another_table WHERE condition2;

-- Optimized Query
WITH CTE_Example AS (
    SELECT column1, column2 FROM your_table_name WHERE condition1
)
SELECT
    CTE_Example.column1,
    CTE_Example.column2,
    at.column3,
    at.column4
FROM
    CTE_Example
JOIN
    another_table at ON CTE_Example.column1 = at.column1
WHERE
    condition2;
