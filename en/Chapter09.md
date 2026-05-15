# Performance Tuning
To improve database performance, it is necessary to understand the various mechanisms for improving performance and the methods of performance tuning. This chapter explains performance tuning.

## Indexes
An index is a mechanism for quickly finding the target rows during a search. As the name suggests, it directly points to where the data is located, like the index of a book.

Without an index, the entire table must be searched every time a query is executed. When there are many rows, the amount of data to be searched increases, so performance degrades significantly and queries become slow. Searching the entire table in this way is called a "sequential scan" or "full scan," while searching by using an index is called an "index scan."

### Index on the Primary Key
Indexes must be designed and created so that index scans occur as intended. In properly normalized tables, the most effective index is the one created on the primary key. Because the primary key is often used in search conditions and table joins, creating an index on it makes it possible to quickly find the required rows through an index scan.

As in the following example, when a primary key is defined, an index is created automatically.

```
ossdb=# \d prod
                    Table "public.prod"
   Column  |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 prod_id   | integer |           | not null |
 prod_name | text    |           |          |
 price     | integer |           |          |
Indexes:
    "prod_pkey" PRIMARY KEY, btree (prod_id)
Referenced by:
    TABLE "orders" CONSTRAINT "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

### Creating an Index
To create an index manually, use the CREATE INDEX statement.

The syntax for creating an index is as follows.

```
CREATE INDEX index_name ON table_name(column_name[,...]);
```

Specify the column or columns of the table on which you want to create the index. You can specify a single column or multiple columns. An index defined on multiple columns is called a composite index. A composite index may not be effective if only some of its columns are used in the search condition, so it should be created with consideration of what search conditions the SQL statement will use.

In the following example, an index is created on the customer_id column of the orders table.

```
ossdb=# CREATE INDEX orders_customer_id_idx
ON orders(customer_id);
CREATE INDEX
ossdb=# \d orders
                              Table "public.orders"
    Column   |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 order_id    | integer                     |           | not null |
 order_date  | timestamp without time zone |           |          |
 customer_id | integer                     |           |          |
 prod_id     | integer                     |           |          |
 qty         | integer                     |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (order_id)
    "orders_customer_id_idx" btree (customer_id)
Foreign-key constraints:
    "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

### Deleting an Index
To delete an index, use the DROP INDEX statement.

The syntax for deleting an index is as follows.

```
DROP INDEX index_name;
```

In the following example, the orders_customer_id_idx index is deleted.

```
ossdb=# DROP INDEX orders_customer_id_idx;
DROP INDEX
ossdb=# \d orders
                              Table "public.orders"
    Column   |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 order_id    | integer                     |           | not null |
 order_date  | timestamp without time zone |           |          |
 customer_id | integer                     |           |          |
 prod_id     | integer                     |           |          |
 qty         | integer                     |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (order_id)
Foreign-key constraints:
    "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

### Indexes Are Not a Cure-All
Indexes are a means of speeding up queries, but they are not a cure-all.

First, if the values in the indexed column are rewritten frequently, the index must also be updated frequently. As the amount of row data increases, the overhead of updating the index also grows, so columns that are not updated often are better candidates for indexing.

Also, if the values in a column are not distributed with enough variety, a sequential scan may be more efficient than an index scan.

To determine whether an index is working effectively, you should verify it by analyzing the SQL execution plan described next.

## Analyzing SQL Execution Plans
To check how SQL is actually executed inside the database, analyze the SQL execution plan. To perform the analysis, execute the SQL statement you want to analyze with EXPLAIN placed before it.

### SQL Execution Plan When No Index Exists
You can see that a search on a table with no index results in a full scan.

In the following example, the SELECT statement used to query the postal code database is analyzed. Because no index exists, a sequential scan (Seq Scan) is used.

```
ossdb=# EXPLAIN SELECT * FROM zip WHERE newzip = '1500002';
                       QUERY PLAN
--------------------------------------------------------
 Seq Scan on zip  (cost=0.00..4226.62 rows=1 width=140)
   Filter: (newzip = '1500002'::bpchar)
(2 rows)
```

### SQL Execution Plan When an Index Exists
You can see that if an index exists and the system determines that using it is beneficial, an index scan is performed.

```
ossdb=# CREATE INDEX zip_newzip_idx ON zip(newzip);
CREATE INDEX
ossdb=# EXPLAIN SELECT * FROM zip WHERE newzip = '1500002';
                                 QUERY PLAN
----------------------------------------------------------------------------
 Index Scan using zip_newzip_idx on zip  (cost=0.42..8.44 rows=1 width=140)
   Index Cond: (newzip = '1500002'::bpchar)
(2 rows)
```

### Even if an Index Exists, It Is Not Always Used
Even if an index exists, it may be judged unnecessary depending on the search condition.

In the following example, an index is created on the largearea column of the zip table, but because the largearea column can contain only either 0 or 1, the index is not necessarily used in every case. Finally, the count function is used to check how many rows are stored for 0 and 1 respectively. Because most values in the largearea column are 0, the planner decides that using the index would not provide good performance and chooses a full scan. Because there are relatively few rows whose largearea value is 1, an index scan is selected.

```
ossdb=# CREATE INDEX zip_largearea ON zip(largearea);
CREATE INDEX
ossdb=# EXPLAIN SELECT * FROM zip WHERE largearea = 0;
                         QUERY PLAN
-------------------------------------------------------------
 Seq Scan on zip  (cost=0.00..4226.62 rows=121597 width=140)
   Filter: (largearea = 0)
(2 rows)

ossdb=# EXPLAIN SELECT * FROM zip WHERE largearea = 1;
                                   QUERY PLAN
--------------------------------------------------------------------------------
 Index Scan using zip_largearea on zip  (cost=0.29..719.21 rows=2773 width=140)
   Index Cond: (largearea = 1)
(2 rows)

ossdb=# SELECT largearea,count(*) FROM zip GROUP BY largearea;
 largearea | count
-----------+--------
         0 | 121714
         1 |   2656
(2 rows)
```

This is similar to the index of a book. In a technical book about PostgreSQL, you would not use the index at the back of the book to look for pages containing the very common word "PostgreSQL." If you can expect that almost every page will match, it is far more efficient to flip through the pages from the beginning or to look at the table of contents or index using a different word.

## VACUUM Processing
To continue using PostgreSQL, VACUUM processing becomes necessary. VACUUM processing reclaims the space occupied by row data that is no longer needed and makes it available for reuse. VACUUM processing is closely related to PostgreSQL data management.

Although VACUUM processing is configured to run automatically, it can also be executed manually.

### PostgreSQL Data Management
With PostgreSQL, when row data is updated or deleted, the actual row data is not physically removed. Instead, the old row data is marked as no longer used and excluded from query results. VACUUM processing reclaims these unnecessary rows.

The advantage of this method is that, at the update or delete stage, it does not physically remove row data; it only marks it, which is advantageous for performance. On the other hand, if updates become frequent, the amount of row data that is no longer needed can grow too much and the physical amount of data can become large, consuming disk space and degrading sequential scan performance.

### VACUUM and VACUUM FULL
To perform VACUUM processing, use the VACUUM statement or the VACUUM FULL statement.

The VACUUM statement reclaims unnecessary row data and makes it reusable. The size of the data file does not change.

The VACUUM FULL statement can further reduce the size of the data file by moving the physical placement of row data. Because the VACUUM FULL statement involves moving row data, executing it acquires a strong lock on the entire table, preventing other users from performing operations. The VACUUM FULL statement has significant side effects, so it is best used after deleting a large amount of data, for example when you want to shrink the data file and increase free disk space.

### VACUUM ANALYZE
The VACUUM statement can be executed together with the ANALYZE statement, which recreates statistics about data distribution to help determine the SQL execution plan.

The following example executes VACUUM ANALYZE on the database.
```
ossdb=# VACUUM ANALYZE;
VACUUM
```

### Autovacuum Daemon
The autovacuum daemon is a mechanism that automatically executes VACUUM and ANALYZE.

The autovacuum daemon runs by default and monitors when VACUUM processing and statistics regeneration are needed.

Let's check whether the autovacuum daemon is running. The process named autovacuum running on Linux is the autovacuum daemon.
```
[postgres@host1 ~]$ ps ax | grep autovacuum
  37358 ?        Ss     0:10 postgres: autovacuum launcher
  60901 pts/1    S+     0:00 grep --color=auto autovacuum
```

## Rearranging Data by Database Clustering
Database clustering rearranges the physical placement of data according to an index. By rearranging the data, row data that is queried by using the index is grouped together on physical disk, which can reduce disk access and improve performance.

Use the CLUSTER statement to perform clustering. The first time you perform clustering, you must explicitly specify the index in the USING clause. After the second time, the index used for clustering is recorded, so it is fine to execute the CLUSTER statement without specifying the index.

In the following example, clustering is performed on the orders table using the orders_pkey index. The index used for clustering is displayed with CLUSTER appended to its information.

```
ossdb=# CLUSTER orders;
ERROR:  there is no previously clustered index for table "orders"
ossdb=# CLUSTER orders USING orders_pkey;
CLUSTER
ossdb=# \d orders
                              Table "public.orders"
    Column   |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 order_id    | integer                     |           | not null |
 order_date  | timestamp without time zone |           |          |
 customer_id | integer                     |           |          |
 prod_id     | integer                     |           |          |
 qty         | integer                     |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (order_id) CLUSTER
Foreign-key constraints:
    "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

\pagebreak
