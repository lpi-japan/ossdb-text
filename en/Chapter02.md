# Basic Database Operations with SQL
This chapter covers the fundamentals of database operations using SQL. In Chapter 2, you will learn the basics of database operations using SQL. Try querying and updating data in an already-created database using SQL.

## Basic Patterns of Database Usage
The role of a database is to manage various kinds of data according to user requests. These operations can be categorized into the following patterns.

- Create a table (CREATE TABLE)  
To store data in a database, you need to create a "table". You must specify the column names and the type of data (such as characters or numbers).

- Insert data (INSERT)  
Storing data into a database is called "insertion (INSERT)". You must insert data that matches the appropriate data type.

- Query data (SELECT)  
Retrieving data from a database is called "querying (SELECT)". One of the advantages of a database is the variety of queries it supports — filtering to retrieve a subset of data, or combining data from multiple tables.

- Update data (UPDATE)  
Modifying data in a database is called "updating (UPDATE)". You can update all rows at once, or update only specific rows by specifying a condition.

- Delete data (DELETE)  
Removing data from a database is called "deletion (DELETE)". Specify a condition to filter the rows you want to remove.

## Using the psql Tool
To execute SQL against PostgreSQL and operate the database, you use the psql tool (referred to below as psql).

psql is provided as a command that can be run on Linux, so you need to log in to Linux to use it. Log in as the postgres user, or log in as the admin user and then switch to the postgres user with the su command.

To switch users with the su command, run it with a `-` (hyphen) as shown below.

```
[admin@host1 ~]$ su - postgres
[postgres@host1 ~]$
```

## Displaying the List of Databases
Run psql with the `-l` option. psql connects to PostgreSQL and displays a list of currently created databases.

```
[postgres@host1 ~]$ psql -l
                                      List of databases
   Name    |  Owner   | Encoding |   Collation   |    Ctype      |   Access privileges
-----------+----------+----------+---------------+---------------+---------------------
 ossdb     | postgres | UTF8     | ja_JP.UTF-8   | ja_JP.UTF-8   |
 postgres  | postgres | UTF8     | ja_JP.UTF-8   | ja_JP.UTF-8   |
 template0 | postgres | UTF8     | ja_JP.UTF-8   | ja_JP.UTF-8   | =c/postgres          +
           |          |          |               |               | postgres=CTc/postgres
 template1 | postgres | UTF8     | ja_JP.UTF-8   | ja_JP.UTF-8   | =c/postgres          +
           |          |          |               |               | postgres=CTc/postgres
(4 rows)
```

## Connecting to a Database
Use psql to connect to a database. PostgreSQL can manage multiple databases simultaneously, but psql connects to and operates on one database at a time.

As shown below, specify the name of the database you want to connect to as an argument to psql. Connect to the ossdb database created in Chapter 1.

```
[postgres@host1 ~]$ psql ossdb
psql (13.14)
Type "help" for help.

ossdb=#
```

When the connection succeeds, a prompt appears and psql is ready to accept SQL statements and other commands. If you cannot connect, verify that PostgreSQL is running correctly and that you are running psql as the postgres user.

## Displaying psql Help
Display the psql help by typing `help`.
```
ossdb=# help
You are using psql, the command-line interface to PostgreSQL.
Type:  \copyright for distribution terms
       \h for help with SQL commands
       \? for help with psql commands
       \g or terminate with semicolon to execute query
       \q to quit
```

## Meta-Commands
In addition to accepting SQL, psql accepts meta-commands that begin with `\` (backslash).
Meta-commands serve various purposes, such as displaying help or performing operations on the database.

### Checking Help (`\h`)
You can check the help for available SQL commands.

```
ossdb=# \h
Available help:
  ABORT                            CREATE FOREIGN DATA WRAPPER      DROP ROUTINE
  ALTER AGGREGATE                  CREATE FOREIGN TABLE             DROP RULE
  ALTER COLLATION                  CREATE FUNCTION                  DROP SCHEMA
(output omitted)
```

### Checking Help for a Specific SQL Command (`\h` SQL command)
By specifying a SQL command as an argument to the psql meta-command `\h`, you can view the help for that SQL command. The command name can be specified in uppercase or lowercase.

```
ossdb=# \h DELETE
Command:     DELETE
Description: Delete rows of a table
Synopsis:
[ WITH [ RECURSIVE ] with_query [, ...] ]
DELETE FROM [ ONLY ] table_name [ * ] [ [ AS ] alias ]
    [ USING from_item [, ...] ]
    [ WHERE condition | WHERE CURRENT OF cursor_name ]
    [ RETURNING * | output_expression [ [ AS ] output_name ] [, ...] ]

URL: https://www.postgresql.org/docs/13/sql-delete.html
```

If pagination is active and `-- More --` is displayed at the bottom left, you can scroll through the output using the cursor keys or the space bar. When you reach the end, pagination stops. To stop pagination partway through, press the `q` key.

### Checking psql Meta-Command Help (`\?`)
The psql meta-command `\?` displays help for all available psql meta-commands.

```
ossdb=# \?
General
  \copyright             Show PostgreSQL usage and distribution terms
  \crosstabview [COLUMNS]  Execute query and display result in crosstab format
  \errverbose            Show the last error message at maximum verbosity
(output omitted)
```

### Quitting psql (`\q`)
To quit psql, enter the psql meta-command `\q`.

```
ossdb=# \q
[postgres@host1 ~]$
```

## Checking Tables
To check the tables that have been created, use the psql meta-command `\d`.
```
ossdb=# \d
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | customer | table | postgres
 public | orders   | table | postgres
 public | prod     | table | postgres
(3 rows)
```

## Checking Table Definitions
To check what columns a table has, run the psql meta-command `\d` followed by the table name.
```
ossdb=# \d customer
                 Table "public.customer"
    Column     |  Type   | Collation | Nullable | Default
---------------+---------+-----------+----------+---------
 customer_id   | integer |           |          |
 customer_name | text    |           |          |

ossdb=# \d orders
                          Table "public.orders"
   Column    |            Type             | Collation | Nullable | Default
-------------+-----------------------------+-----------+----------+---------
 order_id    | integer                     |           |          |
 order_date  | timestamp without time zone |           |          |
 customer_id | integer                     |           |          |
 prod_id     | integer                     |           |          |
 qty         | integer                     |           |          |

ossdb=# \d prod
                Table "public.prod"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 prod_id   | integer |           |          |
 prod_name | text    |           |          |
 price     | integer |           |          |
```

## Tables, Relations
In this textbook, the place where data is stored is referred to as a "table", but the psql output uses terms such as "List of relations" and "table". You can generally treat "table" and "relation" as the same thing.

In its original sense, a relation refers to a set of data, but in a relational database a relation is represented in tabular form, so "relation" and "table" can be considered nearly synonymous.

Similarly, "row" and "record" or "tuple", and "column" and "field" are also synonyms.

## How to Execute SQL
psql accepts and executes two types of input: psql meta-commands and SQL commands. psql meta-commands always begin with `\`, which distinguishes them from SQL commands. Anything that is not a psql meta-command is executed as a SQL command against the PostgreSQL database.

In psql, newlines and spaces are used solely for formatting SQL commands and have no syntactic meaning. Input can span multiple lines. By appending a `;` (semicolon) or the psql meta-command `\g` at the end of a statement, the entire statement is sent to the server as a single instruction and processed.

## Prompt Display for Multi-Line Input
The prompt displayed when entering multi-line input in psql differs between normal mode and subsequent lines.

| Notation | Mode
| --- | ---
| dbname=# | Normal prompt
| dbname-# | Prompt for subsequent lines

What the prompt displays is defined by psql internal variables PROMPT1 and PROMPT2. For example, if you want nothing to be displayed for subsequent-line prompts, use the psql meta-command `\unset` to clear the PROMPT2 variable.

```
ossdb=# 1st line
ossdb-# 2nd line
ossdb-# 3rd line;
ERROR:  syntax error at or near "1"
LINE 1: 1st line
        ^
ossdb=# \unset PROMPT2
ossdb=# 1st line
2nd line
3rd line;
ERROR:  syntax error at or near "1"
LINE 1: 1st line
        ^
```

In this textbook, examples are shown without the subsequent-line prompt so that multi-line SQL can easily be copied and pasted from the electronic PDF or EPUB. During hands-on exercises, the subsequent-line prompt appearing by default is the correct behavior.

## Reading and Executing from a Text File
psql has a feature that allows it to read and execute the contents of a text file. When you want to execute the same operations repeatedly, you can write meta-commands and SQL commands in a file in advance and have psql read and execute them.

The psql syntax for reading from a file is as follows.

```
$ psql -f filename [dbname] [username]
```

In the following example, the file test.sql containing the meta-command `\d` is read by psql and executed.
```
[postgres@host1 ~]$ cat test.sql
\d
[postgres@host1 ~]$ psql -f test.sql ossdb
          List of relations
 Schema |   Name   | Type  |  Owner
--------+----------+-------+----------
 public | customer | table | postgres
 public | orders   | table | postgres
 public | prod     | table | postgres
(3 rows)
```

## Querying Data (SELECT)
Querying data is the most fundamental use of a database. A database stores various types of data in tabular form, and querying is the process of retrieving that data in the required form. The SQL SELECT statement is used to query data.

The basic syntax of a SELECT statement is as follows.

```
SELECT [DISTINCT] * | column_list
	FROM table_name[,…]
	[WHERE search_condition]
	[GROUP BY grouping_expression]
	[HAVING search_condition]
	[ORDER BY sort_expression]
```

### Querying All Rows and All Columns
Retrieving all rows and all columns from a table is called a full query. Specifying `*` (asterisk) retrieves all columns from the target table.

The SELECT statement for a full query is as follows.

```
SELECT * FROM table
```

In the following examples, a full query is performed on the customer table, prod table, and orders table.
```
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
           2 | Suzuki Products
           3 | Takahashi Store
(3 rows)

ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
(3 rows)

ossdb=# SELECT * FROM orders;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2024-04-06 14:55:30.607262 |           1 |       1 |  10
        2 | 2024-04-06 14:55:30.612462 |           2 |       2 |   5
        3 | 2024-04-06 14:55:30.6152   |           3 |       3 |   8
        4 | 2024-04-06 14:55:30.616348 |           2 |       1 |   3
        5 | 2024-04-06 14:55:30.617621 |           3 |       2 |   4
(5 rows)
```

### Column List in SELECT
Specify the column names you want to retrieve in the SELECT statement, separated by commas.

The syntax of a SELECT statement with a column list is as follows.

```
SELECT column_name[,column_name...] FROM table
```

In the following example, only the prod_name and price columns are retrieved from the prod table.
```
ossdb=# SELECT prod_name,price FROM prod;
 prod_name | price
-----------+-------
 orange    |    50
 apple     |    70
 melon     |   100
(3 rows)
```

### Filtering with a WHERE Clause
To filter the rows retrieved by a query using a condition, use a WHERE clause.

The syntax of a WHERE clause is as follows.

```
WHERE column_name condition value
```

### Common Condition Operators
The following condition operators can be used in a WHERE clause.

| Operator  | Meaning
| --------- | --------
| =         | Equal to
| <>        | Not equal to
| \>        | Greater than
| <         | Less than
| \>=       | Greater than or equal to
| <=        | Less than or equal to
| BETWEEN   | Range
| LIKE      | Partial match

Let's look at what results each condition operator produces.

### Equal To, Not Equal To
Retrieve rows where the value of a column is equal to (`=`) or not equal to (`<>`) a specified value. When specifying a string as the condition value, enclose it in `'` (single quotes).

In the following example, rows from the customer table where the customer_id column equals 2 are retrieved.

```
ossdb=# SELECT * FROM customer WHERE customer_id = 2;
 customer_id | customer_name
-------------+---------------
           2 | Suzuki Products
(1 row)
```

In the following example, rows from the customer table where the customer_id column is not 2 are retrieved.

```
ossdb=# SELECT * FROM customer WHERE customer_id <> 2;
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
           3 | Takahashi Store
(2 rows)
```

In the following example, rows from the customer table where the customer_name column equals 'Sato Trading' are retrieved. When specifying string data, enclose the value with `'` (single quotes) on both sides.

```
ossdb=# SELECT * FROM customer WHERE customer_name = 'Sato Trading';
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
(1 row)
```

### Greater Than, Less Than
Retrieve rows where the value of a column is greater than (`>`) or less than (`<`) a specified value.

In the following example, rows from the prod table where the price column is greater than 70 are retrieved. The row for apple, whose price is 70, is not included.
```
ossdb=# SELECT * FROM prod WHERE price > 70;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   100
(1 row)
```

### Greater Than or Equal To, Less Than or Equal To
Retrieve rows where the value of a column is greater than or equal to (`>=`) or less than or equal to (`<=`) a specified value.

In the following example, rows from the prod table where the price column is greater than or equal to 70 are retrieved. The row for apple, whose price is 70, is also included.
```
ossdb=# SELECT * FROM prod WHERE price >= 70;
 prod_id | prod_name | price
---------+-----------+-------
       2 | apple     |    70
       3 | melon     |   100
(2 rows)
```

### Range Query (A or more, B or less)
Specify two values in the condition to retrieve data that falls within the range between them.

In the following example, rows from the prod table where the price column is between 10 and 80 (inclusive) are retrieved. Orange (price 50) and apple (price 70) are included; melon, which is outside the range, is not.
```
ossdb=# SELECT * FROM prod WHERE price BETWEEN 10 AND 80;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
(2 rows)
```

This result is the same as combining "greater than or equal to" and "less than or equal to" with comparison operators. The AND operator is used to require that both conditions be satisfied.

```
ossdb=# SELECT * FROM prod WHERE price >= 10 AND price <= 80;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
(2 rows)
```

## Partial Match Search
Partial match search uses the LIKE operator to retrieve data where part of a string matches the specified pattern.

The following symbols can be used in patterns.

| Symbol | Matching behavior
| --- | ---
| % | Zero or more characters
| _ | Exactly one character

### Match Anywhere in the String (Substring Search)
Search for rows where the string contains the specified substring. The search string is surrounded by `%` on both sides. As with previous queries, the value is a string and must be enclosed in `'` (single quotes).

In the following example, 'orange' and 'melon' match because they contain the character 'n'. For 'melon', the trailing `%` matches zero characters. 'apple' does not contain 'n' and is therefore not returned.
```
ossdb=# SELECT * FROM prod WHERE prod_name LIKE '%n%';
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       3 | melon     |   100
(2 rows)
```

### Prefix Search, Suffix Search
Search for rows where the string starts or ends with the specified characters. As with substring search, `%` is used, but only one `%` is placed at one end to indicate the start or end of the string.

In the following example, 'orange' and 'apple' match because they end with 'e'.
```
ossdb=# SELECT * FROM prod WHERE prod_name LIKE '%e';
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
(2 rows)
```

For a prefix search, put the search string at the beginning. For example, specifying `'ap%'` would match 'apple'.

### Specifying the Character Position  
Search for rows where the specified character appears at a particular position in the string. Use one `_` (underscore) for each character position.
In the following example, three underscores followed by `'le'` are used as the condition `'___le'` to search for 5-character strings ending in `le`; as a result, 'apple' (a-p-p-l-e) is returned. With only two underscores (`'__le'`), the pattern matches 4-character strings ending in `le`, and no results are found.
```
ossdb=# SELECT * FROM prod WHERE prod_name LIKE '___le';
 prod_id | prod_name | price
---------+-----------+-------
       2 | apple     |    70
(1 row)
ossdb=# SELECT * FROM prod WHERE prod_name LIKE '__le';
 prod_id | prod_name | price
---------+-----------+-------
(0 rows)
```

### Searching for Rows That Do NOT Match
Just as there is not-equal (`<>`) corresponding to equal (`=`), there is a NOT LIKE operator corresponding to LIKE, which matches rows that do not contain the specified string.
In the following example, the NOT LIKE operator is used to retrieve rows that do not contain 'n'. Only 'apple' matches.
```
ossdb=# SELECT * FROM prod WHERE prod_name NOT LIKE '%n%';
 prod_id | prod_name | price
---------+-----------+-------
       2 | apple     |    70
(1 row)
```

Similarly, "prefix non-match" and "suffix non-match" searches are also possible.

```
ossdb=# SELECT * FROM prod WHERE prod_name NOT LIKE '%e';
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   100
(1 row)
```

## Sorting with an ORDER BY Clause
To sort query results in a specified order, use an ORDER BY clause. Because a relational database treats data as a set, the display order of results is not guaranteed unless sorting is explicitly specified. By specifying sorting with an ORDER BY clause, you can retrieve rows in the expected order. Specifying DESC sorts in descending order.

The syntax of an ORDER BY clause is as follows.

```
ORDER BY column_name [DESC]
```

In the following examples, the prod table is sorted by the price column in ascending and descending order.

```
ossdb=# SELECT * FROM prod ORDER BY price;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
(3 rows)

ossdb=# SELECT * FROM prod ORDER BY price DESC;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   100
       2 | apple     |    70
       1 | orange    |    50
(3 rows)
```

## Joining Tables
In a relational database, you can retrieve data by linking tables together. The act of linking tables is called a "join".

### Joining with a JOIN Clause
To perform a join, specify the columns to join using a JOIN clause. The values in the specified columns are compared, and rows with matching values are joined.

The syntax of a JOIN clause is as follows.

```
FROM table1
	JOIN table2 ON table1.column = table2.column
```
In a SELECT against a single table, the target table was specified with a FROM clause, but with a join, a second table is specified by naming it after the JOIN clause. The ON clause used together with the table specification is also important. After ON, write the join condition. Specify the columns that are related between the two tables as the join condition; rows where these values match are returned as the result.

Let's step through the use of joins.

### Querying a Single Table  
In the following example, the SELECT statement specifies the order_id, customer_id, prod_id, and qty columns from the orders table — the base table for the join — in the column list.
```
ossdb=# SELECT order_id,customer_id,prod_id,qty FROM orders;
 order_id | customer_id | prod_id | qty
----------+-------------+---------+-----
        1 |           1 |       1 |  10
        2 |           2 |       2 |   5
        3 |           3 |       3 |   8
        4 |           2 |       1 |   3
        5 |           3 |       2 |   4
(5 rows)
```
In this result, the customer_id and prod_id columns are not self-explanatory as they stand. We will replace them by looking up the corresponding values from the customer table and prod table respectively.

### Joining the orders Table and the customer Table  
When multiple tables are specified in a FROM clause or JOIN clause, use `table_name.column_name` notation in the column list and join conditions.
First, join the orders table and the customer table using a JOIN clause. The join condition specified in the ON clause matches rows where the customer_id column in the orders table equals the customer_id column in the customer table.

Here, to compare with the previous result, we display the order_id and customer_id columns alongside the customer_name column newly obtained from the customer table.
```
ossdb=# SELECT orders.order_id,orders.customer_id,customer.customer_name
FROM orders
JOIN customer ON orders.customer_id = customer.customer_id;
 order_id | customer_id | customer_name
----------+-------------+---------------
        1 |           1 | Sato Trading
        2 |           2 | Suzuki Products
        4 |           2 | Suzuki Products
        3 |           3 | Takahashi Store
        5 |           3 | Takahashi Store
(5 rows)
```
The customer table contained the following data, so you can see that for each row the related value is looked up from the customer table: customer_id `1` maps to `Sato Trading`, `2` to `Suzuki Products`, and so on.

```
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
           2 | Suzuki Products
           3 | Takahashi Store
(3 rows)
```

![JOIN of the orders table and the customer table](./Pict/join-01.png)

\pagebreak

### Joining the orders Table and the prod Table  
Similarly, join the orders table and the prod table using a JOIN clause. The join condition specified in the ON clause matches rows where the prod_id column in the orders table equals the prod_id column in the prod table.

```
ossdb=# SELECT orders.order_id,prod.prod_name
FROM orders
JOIN prod ON orders.prod_id = prod.prod_id;
 order_id | prod_name
----------+-----------
        1 | orange
        4 | orange
        2 | apple
        5 | apple
        3 | melon
(5 rows)
```

### Joining Three Tables  
Combine both joins into a single SELECT statement. The original SELECT statement was as follows.

```
SELECT order_id,customer_id,prod_id,qty
FROM orders
```

Compare with the original SELECT statement and notice that the column list has been replaced, and two JOIN clauses have been added consecutively.  

```
ossdb=# SELECT orders.order_id,customer.customer_name,prod.prod_name,orders.qty
FROM orders
JOIN customer ON orders.customer_id = customer.customer_id
JOIN prod     ON orders.prod_id = prod.prod_id;
 order_id | customer_name   | prod_name | qty
----------+-----------------+-----------+-----
        1 | Sato Trading    | orange    |  10
        4 | Suzuki Products | orange    |   3
        2 | Suzuki Products | apple     |   5
        5 | Takahashi Store | apple     |   4
        3 | Takahashi Store | melon     |   8
(5 rows)
```
We have successfully replaced customer_id with the customer name retrieved from the customer table, and prod_id with the product name retrieved from the prod table.

![JOIN of three tables](./Pict/join-02.png)

\pagebreak

### Using Table Aliases
Table names that are used repeatedly in a SQL statement can be given an alias in the FROM clause or JOIN clause. Specifying a short alias can make the SQL statement shorter and easier to read.

The syntax for specifying a table alias is as follows.

```
FROM table_name alias
JOIN table_name alias
```

Applying table aliases to the SQL statement that performs the JOIN above results in the following. The orders table is aliased as `o`, the customer table as `c`, and the prod table as `p`.

```
ossdb=# SELECT o.order_id,c.customer_name,p.prod_name,o.qty
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN prod p     ON o.prod_id = p.prod_id;
 order_id | customer_name   | prod_name | qty
----------+-----------------+-----------+-----
        1 | Sato Trading    | orange    |  10
        4 | Suzuki Products | orange    |   3
        2 | Suzuki Products | apple     |   5
        5 | Takahashi Store | apple     |   4
        3 | Takahashi Store | melon     |   8
(5 rows)
```

## Inserting Row Data (INSERT)
To insert row data into a table, use an INSERT statement.

The syntax of an INSERT statement is as follows.

```
INSERT INTO table_name(column_name[,…])
	VALUES (value[,...])
```

When specifying string data as a value, you must enclose it in `'` (single quotes).

```
ossdb=# INSERT INTO prod(prod_id,prod_name,price) VALUES (4,'banana',30);
INSERT 0 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       4 | banana    |    30
(4 rows)
```

## Updating Data (UPDATE)
To update row data, use an UPDATE statement.

The syntax of an UPDATE statement is as follows.

```
UPDATE table_name
	SET column_name = value
	WHERE condition
```

In the following example, the price column value of the row where the prod_id column equals 4 in the prod table is updated to 40.
```
ossdb=# UPDATE prod SET price = 40 WHERE prod_id = 4;
UPDATE 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       4 | banana    |    40
(4 rows)
```

Update values can also be set using arithmetic on the existing row data values. In the following example, the price column in the prod table is increased by 10 across all rows, and then reverted.

```
ossdb=# UPDATE prod SET price = price + 10;
UPDATE 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    60
       2 | apple     |    80
       3 | melon     |   110
       4 | banana    |    50
(4 rows)

ossdb=# UPDATE prod SET price = price - 10;
UPDATE 4
```

## Deleting Row Data (DELETE)
To delete row data, use a DELETE statement. The DELETE statement deletes all rows that match the condition specified in the WHERE clause. If no WHERE clause is specified, all rows in the specified table are deleted.

The syntax of a DELETE statement is as follows.

```
DELETE FROM table_name
	WHERE condition
```

In the following example, the row where the prod_id column equals 4 is deleted from the prod table.
```
ossdb=# DELETE FROM prod WHERE prod_id = 4;
DELETE 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
(3 rows)
```

\pagebreak
