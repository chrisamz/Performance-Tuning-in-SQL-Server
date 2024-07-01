-- execution_plan_analysis.sql
-- This script analyzes execution plans to identify inefficiencies

-- Example: Displaying the execution plan for a query
SET SHOWPLAN_XML ON;
GO

-- Example Query 1: Analyze this query to understand its execution plan
SELECT
    column1,
    column2
FROM
    your_table_name
WHERE
    example_column = 'some_value';
GO

-- Example Query 2: Analyze this query to understand its execution plan
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
GO

-- Example Query 3: Analyze this query to understand its execution plan
SELECT
    yt.column1,
    yt.column2
FROM
    your_table_name yt
WHERE
    EXISTS (SELECT 1 FROM another_table at WHERE at.column3 = yt.column3 AND at.column4 = 'some_value');
GO

SET SHOWPLAN_XML OFF;
GO

-- Capture the actual execution plan for a query
SET STATISTICS XML ON;
GO

-- Example Query 4: Capture the actual execution plan
SELECT
    column1,
    column2
FROM
    your_table_name
WHERE
    example_column = 'some_value';
GO

-- Example Query 5: Capture the actual execution plan
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
GO

-- Example Query 6: Capture the actual execution plan
SELECT
    yt.column1,
    yt.column2
FROM
    your_table_name yt
WHERE
    EXISTS (SELECT 1 FROM another_table at WHERE at.column3 = yt.column3 AND at.column4 = 'some_value');
GO

SET STATISTICS XML OFF;
GO

-- Example: Analyzing missing index recommendations
SELECT
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    db_name(mid.database_id) AS database_name,
    object_name(mid.object_id, mid.database_id) AS table_name,
    'CREATE INDEX [missing_index_' + CONVERT(varchar, mig.index_group_handle) + '_' + CONVERT(varchar, mig.index_handle)
    + '_' + LEFT(PARSENAME(mid.statement, 1), 32) + ']' + ' ON ' + mid.statement + ' (' + ISNULL (mid.equality_columns,'')
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
    + ISNULL (mid.inequality_columns, '') + ')' + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
FROM
    sys.dm_db_missing_index_group_stats migs
    INNER JOIN sys.dm_db_missing_index_groups mig ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY
    improvement_measure DESC;

-- Example: Identifying high-cost queries
SELECT
    TOP 10
    total_worker_time/execution_count AS avg_cpu_cost,
    total_elapsed_time/execution_count AS avg_elapsed_time,
    total_logical_reads/execution_count AS avg_logical_reads,
    total_logical_writes/execution_count AS avg_logical_writes,
    execution_count,
    statement_text = SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END
        - qs.statement_start_offset)/2) + 1)
FROM
    sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY
    avg_cpu_cost DESC;

-- Example: Identifying queries with high logical reads
SELECT
    TOP 10
    total_logical_reads/execution_count AS avg_logical_reads,
    total_worker_time/execution_count AS avg_cpu_cost,
    total_elapsed_time/execution_count AS avg_elapsed_time,
    execution_count,
    statement_text = SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END
        - qs.statement_start_offset)/2) + 1)
FROM
    sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY
    avg_logical_reads DESC;

-- Example: Identifying queries with high logical writes
SELECT
    TOP 10
    total_logical_writes/execution_count AS avg_logical_writes,
    total_worker_time/execution_count AS avg_cpu_cost,
    total_elapsed_time/execution_count AS avg_elapsed_time,
    execution_count,
    statement_text = SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END
        - qs.statement_start_offset)/2) + 1)
FROM
    sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY
    avg_logical_writes DESC;
