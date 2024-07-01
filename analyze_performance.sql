-- analyze_performance.sql
-- This script gathers initial performance metrics and identifies potential issues

-- Capture query execution statistics
SELECT
    qs.sql_handle,
    qs.execution_count,
    qs.total_worker_time AS total_cpu_time,
    qs.total_elapsed_time AS total_duration,
    qs.total_logical_reads AS total_logical_reads,
    qs.total_physical_reads AS total_physical_reads,
    qs.total_logical_writes AS total_logical_writes,
    SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END
        - qs.statement_start_offset)/2) + 1) AS statement_text
FROM
    sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY
    qs.total_worker_time DESC;

-- Identify missing indexes that could improve performance
SELECT
    migs.avg_user_impact * migs.user_seeks AS impact,
    mid.statement,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM
    sys.dm_db_missing_index_groups mig
    INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
    INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY
    impact DESC;

-- Capture index usage statistics to identify unused indexes
SELECT
    OBJECT_NAME(s.[object_id]) AS [ObjectName],
    i.name AS [IndexName],
    s.user_seeks, 
    s.user_scans, 
    s.user_lookups, 
    s.user_updates
FROM 
    sys.dm_db_index_usage_stats s 
    INNER JOIN sys.indexes i ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
WHERE 
    OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1
    AND s.database_id = DB_ID()
ORDER BY 
    OBJECT_NAME(s.[object_id]), 
    i.name;

-- Capture wait statistics to identify resource bottlenecks
SELECT
    wait_type,
    wait_time_ms,
    wait_time_ms / 1000.0 AS wait_time_sec,
    wait_time_ms / 1000.0 / 60.0 AS wait_time_min,
    waiting_tasks_count
FROM
    sys.dm_os_wait_stats
WHERE
    wait_type NOT IN (
        'SLEEP_TASK', 'BROKER_TASK_STOP', 'BROKER_EVENTHANDLER', 'BROKER_RECEIVE_WAITFOR',
        'BROKER_TRANSMITTER', 'CHECKPOINT_QUEUE', 'CHKPT', 'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT',
        'LAZYWRITER_SLEEP', 'ONDEMAND_TASK_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH',
        'XE_TIMER_EVENT', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP',
        'DISPATCHER_QUEUE_SEMAPHORE', 'SQLTRACE_BUFFER_FLUSH', 'XE_DISPATCHER_JOIN',
        'XE_DISPATCHER_WAIT', 'XE_LIVE_TARGET_TVF'
    )
ORDER BY
    wait_time_ms DESC;

-- Capture system performance metrics
SELECT
    sqlserver_start_time,
    cpu_count,
    hyperthread_ratio,
    physical_memory_kb,
    available_memory_kb
FROM
    sys.dm_os_sys_info;
