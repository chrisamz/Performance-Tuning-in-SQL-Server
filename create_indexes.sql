-- create_indexes.sql
-- This script creates indexes to improve query performance

-- Example: Creating an index on a frequently queried column
CREATE INDEX idx_example_column
ON your_table_name (example_column);

-- Example: Creating a composite index on multiple columns
CREATE INDEX idx_example_composite
ON your_table_name (column1, column2);

-- Example: Creating a unique index
CREATE UNIQUE INDEX idx_example_unique
ON your_table_name (unique_column);

-- Example: Creating an index with included columns
CREATE INDEX idx_example_included
ON your_table_name (column1)
INCLUDE (column2, column3);

-- Example: Creating a filtered index
CREATE INDEX idx_example_filtered
ON your_table_name (filter_column)
WHERE filter_column IS NOT NULL;

-- Example: Creating a clustered index
CREATE CLUSTERED INDEX idx_example_clustered
ON your_table_name (cluster_column);

-- Example: Creating a non-clustered index
CREATE NONCLUSTERED INDEX idx_example_nonclustered
ON your_table_name (noncluster_column);

-- Example: Creating an index on a foreign key column
CREATE INDEX idx_example_fk
ON your_table_name (foreign_key_column);

-- Example: Dropping an existing index if necessary
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'idx_old_example')
BEGIN
    DROP INDEX idx_old_example ON your_table_name;
END

-- Example: Creating an index on a frequently queried column in another table
CREATE INDEX idx_another_table_example_column
ON another_table_name (another_example_column);

-- Example: Creating a composite index on multiple columns in another table
CREATE INDEX idx_another_table_composite
ON another_table_name (another_column1, another_column2);

-- Example: Creating a unique index in another table
CREATE UNIQUE INDEX idx_another_table_unique
ON another_table_name (another_unique_column);

-- Example: Creating an index with included columns in another table
CREATE INDEX idx_another_table_included
ON another_table_name (another_column1)
INCLUDE (another_column2, another_column3);

-- Example: Creating a filtered index in another table
CREATE INDEX idx_another_table_filtered
ON another_table_name (another_filter_column)
WHERE another_filter_column IS NOT NULL;

-- Example: Creating a clustered index in another table
CREATE CLUSTERED INDEX idx_another_table_clustered
ON another_table_name (another_cluster_column);

-- Example: Creating a non-clustered index in another table
CREATE NONCLUSTERED INDEX idx_another_table_nonclustered
ON another_table_name (another_noncluster_column);

-- Example: Creating an index on a foreign key column in another table
CREATE INDEX idx_another_table_fk
ON another_table_name (another_foreign_key_column);

-- Example: Dropping an existing index if necessary in another table
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'idx_another_old_example')
BEGIN
    DROP INDEX idx_another_old_example ON another_table_name;
END
