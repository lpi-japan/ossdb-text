# Advanced Database Definition
Properly defining a database is essential for improving data integrity and using it more efficiently. This chapter covers the foundational concepts needed for database definition, such as primary keys and foreign keys, as well as convenient features like sequences.

## Primary Key
A primary key is one or more columns that can uniquely identify each row of data in a table. "Unique" means that no duplicate values exist in the column. A column that is unique is also called a "unique key."

In addition to being a unique key, a primary key must always have a value. A column that always contains a value is said to be "NOT NULL." Details about NULL are described later.

In the following example, specifying the order_id column of the orders table as a condition retrieves exactly one row, whereas specifying the customer_id column returns multiple rows. In this case, the order_id column holds unique values and can be used as a primary key, but the customer_id column cannot hold unique values and therefore cannot serve as a primary key.

```
ossdb=# SELECT * FROM orders WHERE order_id = 1;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2024-04-06 14:55:30.607262 |           1 |       1 |  10
(1 row)

ossdb=# SELECT * FROM orders WHERE customer_id = 2;

 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        2 | 2024-04-06 14:55:30.612462 |           2 |       2 |   5
        4 | 2024-04-06 14:55:30.616348 |           2 |       1 |   3
(2 rows)
```

### Specifying a Primary Key
To specify a primary key, you can do so either at table creation time using a CREATE TABLE statement, or for an existing table using an ALTER TABLE statement. When a primary key is specified, an index is automatically (implicitly) created to speed up searches. Additionally, a NOT NULL constraint is set on the designated column(s), and a unique index named "column_name_pkey" is created.

The syntax for the ALTER TABLE statement to specify a primary key is as follows:

```
ALTER TABLE table_name ADD PRIMARY KEY (column_name[,...])
```

In the following example, the prod_id column of the prod table is specified as the primary key.

```
ossdb=# ALTER TABLE prod ADD PRIMARY KEY(prod_id);
ALTER TABLE
ossdb=# \d prod
                   Table "public.prod"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 prod_id   | integer |           | not null |
 prod_name | text    |           |          |
 price     | numeric |           |          |
Indexes:
    "prod_pkey" PRIMARY KEY, btree (prod_id)
```

The order_id column of the orders table and the customer_id column of the customer table are also specified as primary keys.
```
ossdb=# ALTER TABLE orders ADD PRIMARY KEY(order_id);
ALTER TABLE
ossdb=# ALTER TABLE customer ADD PRIMARY KEY(customer_id);
ALTER TABLE
```

### Verifying Primary Key Behavior
When a primary key is specified, constraints are set to ensure the value is both "unique" (UNIQUE) and "NOT NULL." This means that inserting row data that violates these constraints will not be allowed.

In the following example, an INSERT statement that omits the primary key value prod_id (making it NULL), and an INSERT statement that specifies an already existing value, both result in errors.

```
ossdb=# INSERT INTO prod (prod_name,price) VALUES ('watermelon',60);
ERROR:  null value in column "prod_id" of relation "prod" violates not-null constraint
DETAIL:  Failing row contains (null, watermelon, 60).

ossdb=# INSERT INTO prod (prod_id,prod_name,price) VALUES (4,'watermelon',60);
ERROR:  duplicate key value violates unique constraint "prod_pkey"
DETAIL:  Key (prod_id)=(4) already exists.

ossdb=# INSERT INTO prod (prod_id,prod_name,price) VALUES (5,'watermelon',60);
INSERT 0 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name  | price
---------+------------+-------
       1 | orange     |    50
       2 | apple      |    70
       3 | melon      |   100
       4 | banana     |    30
       5 | watermelon |    60
(5 rows)
```

### Composite Primary Keys
As described earlier, "a primary key is one or more columns that uniquely identify a row of data," so it is possible to set a primary key consisting of multiple columns. This is called a composite primary key, or composite key.

For example, a case like "Year 1, Class 2, Student Number 3" that is made up of multiple elements is a good example of a composite primary key.
```
ossdb=# CREATE TABLE student (class TEXT,no INTEGER,name TEXT);
CREATE TABLE
ossdb=# ALTER TABLE student ADD PRIMARY KEY (class,no);
ALTER TABLE
ossdb=# \d student
               Table "public.student"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 class  | text    |           | not null |
 no     | integer |           | not null |
 name   | text    |           |          |
Indexes:
    "student_pkey" PRIMARY KEY, btree (class, no)
```

## Foreign Key
A foreign key is a column whose values exist in the primary key (or unique key; omitted hereafter) of another table. The act of a foreign key referencing the primary key of another table is called a "foreign key reference," and the referenced primary key is called the "referenced key."

### Referential Integrity Constraint
Ensuring that the referenced key always has a value through a foreign key reference is called a "foreign key constraint" or "referential integrity constraint." When a foreign key constraint is set, attempting to insert a value into the foreign key that does not exist in the referenced key, or attempting to update the foreign key to a value not present in the referenced key, will result in an error. This prevents the foreign key from being set to an incorrect value.

In addition, it also becomes impossible to delete a value from the referenced key if it is referenced by a foreign key, preventing the situation where a value used by a foreign key in another table becomes inaccessible.

### Specifying a Foreign Key
To specify a foreign key, you can do so either at table creation time using a CREATE TABLE statement, or for an existing table using an ALTER TABLE statement.

The syntax for the ALTER TABLE statement to specify a foreign key is as follows:

```
ALTER TABLE table_name ADD FOREIGN KEY (column_name) REFERENCES referenced_table (referenced_key_name)
```

In the following example, foreign keys are set on the customer_id column and the prod_id column of the orders table.

```
ossdb=# ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE
ossdb=# ALTER TABLE orders ADD FOREIGN KEY (prod_id) REFERENCES prod(prod_id);
ALTER TABLE
ossdb=# \d orders
                             Table "public.orders"
   Column    |            Type             | Collation | Nullable | Default
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

ossdb=# \d customer
                  Table "public.customer"
    Column     |  Type   | Collation | Nullable | Default
---------------+---------+-----------+----------+---------
 customer_id   | integer |           | not null |
 customer_name | text    |           |          |
Indexes:
    "customer_pkey" PRIMARY KEY, btree (customer_id)
Referenced by:
    TABLE "orders" CONSTRAINT "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
```

In the following example, the first INSERT fails because there is no row with customer_id = 4 in the customer table, violating the foreign key constraint. The second INSERT also fails because there is no row with prod_id = 6 in the prod table, violating the foreign key constraint.

```
ossdb=# INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty)
VALUES (6,CURRENT_TIMESTAMP,4,6,6);
ERROR:  insert or update on table "orders" violates foreign key constraint "orders_prod_id_fkey"
DETAIL:  Key (prod_id)=(6) is not present in table "prod".

ossdb=# INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty)
VALUES (6,CURRENT_TIMESTAMP,3,6,6);
ERROR:  insert or update on table "orders" violates foreign key constraint "orders_prod_id_fkey"
DETAIL:  Key (prod_id)=(6) is not present in table "prod".
``` 

![Foreign key constraint violation](./Pict/foreign-01.png)

In the next INSERT, instead of the previously failing prod_id = 6, we insert prod_id = 5. This time no constraint violation occurs and the INSERT completes successfully.

```
ossdb=# INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty)
VALUES (6,CURRENT_TIMESTAMP,3,5,6);
INSERT 0 1
ossdb=# SELECT * FROM orders WHERE order_id = 6;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        6 | 2024-04-17 11:11:11.840835 |           3 |       5 |   6
(1 row)

ossdb=# SELECT o.order_id,c.customer_name,p.prod_name,o.qty
FROM orders o
JOIN customer c ON o.customer_id = c.customer_id
JOIN prod p ON o.prod_id = p.prod_id
WHERE order_id = 6;
 order_id | customer_name   | prod_name  | qty
----------+-----------------+------------+-----
        6 | Takahashi Store | watermelon |   6
(1 row)
```

### Setting Primary Keys and Foreign Keys in CREATE TABLE
Primary keys and foreign keys can also be set in the CREATE TABLE statement.

The following example shows CREATE TABLE statements that set primary keys and foreign keys for the prod, customer, and orders tables. Since a foreign key requires the primary key of another table as the referenced key, the referenced tables must be created first.

```
ossdb=# DROP TABLE orders;
ossdb=# DROP TABLE prod;
ossdb=# DROP TABLE customer;

ossdb=# CREATE TABLE prod
        (prod_id   INTEGER PRIMARY KEY,
         prod_name TEXT,
         price     INTEGER);
CREATE TABLE

ossdb=# CREATE TABLE customer
        (customer_id   INTEGER PRIMARY KEY,
         customer_name TEXT);
CREATE TABLE

ossdb=# CREATE TABLE orders
        (order_id    INTEGER   PRIMARY KEY,
         order_date  TIMESTAMP,
         customer_id INTEGER   REFERENCES customer (customer_id),
         prod_id     INTEGER   REFERENCES prod (prod_id),
         qty         INTEGER);
CREATE TABLE
```

Recreate the row data in the tables.

```
ossdb=# INSERT INTO customer(customer_id,customer_name) VALUES
 (1,'Sato Trading'),
 (2,'Suzuki Products'),
 (3,'Takahashi Store');
INSERT 0 3

ossdb=# INSERT INTO prod(prod_id,prod_name,price) VALUES
 (1,'orange',50),
 (2,'apple',70),
 (3,'melon',100);
```

### Are Primary Keys and Foreign Keys Necessary?
By setting primary keys and foreign keys, you can prevent accidentally inserting duplicate values into a table or inadvertently deleting row data. On the other hand, any temporarily inconsistent state will no longer be tolerated, which can be inconvenient when performing data maintenance. Due to this inconvenience, some systems choose to perform data integrity checks in the application layer rather than using database constraints.

It is difficult to say definitively which approach is better, but in principle it is a good idea to set primary keys and foreign keys on the database side, and remove constraints only if there are operational issues. At the very least, the concepts of primary keys and foreign keys are important from a design perspective. It is also necessary to properly perform normalization, described later, during database design.

## Normalization
Normalization is a database design methodology that determines how data is stored in a relational database. Since a relational database stores row data in table format, you can think of it as the process of decomposing actual row data into multiple tables so that it can be stored easily in tabular form.

Normalization has forms such as First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF). Simply put, as normalization progresses, tables are split and their number increases. By splitting tables, each table takes on a simpler structure, which reduces the likelihood of problems occurring when modifying, deleting, or adding row data.

This textbook does not explain normalization in detail, but since it is a concept that must be understood for database design, please study it through specialized textbooks and references.

## About NULL
NULL is defined as "unknown" or "undefined," and is distinguished from "zero," "blank," or "empty string." A numeric zero, a blank character, or an empty string each represent a state where data "exists," whereas NULL represents a state where data does "not exist."

### NOT NULL Constraint
When a column must not contain NULL, set a NOT NULL constraint in the table definition. A column with a NOT NULL constraint must always have a value. Since a primary key always requires a value, a NOT NULL constraint is automatically set when a primary key is defined.

In the following example, the customer_id column of the customer table has a NOT NULL constraint because it is defined as the primary key.

```
ossdb=# \d customer
                  Table "public.customer"
    Column     |  Type   | Collation | Nullable | Default
---------------+---------+-----------+----------+---------
 customer_id   | integer |           | not null |
 customer_name | text    |           |          |
Indexes:
    "customer_pkey" PRIMARY KEY, btree (customer_id)
Referenced by:
    TABLE "orders" CONSTRAINT "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
```

### NULL Evaluation
Since NULL holds no value, it cannot be searched using ordinary comparison operators. To evaluate whether a column value is NULL, use the IS NULL operator or the IS NOT NULL operator.

In the following example, 'orange' is inserted as a row with a non-NULL price column, and 'grape' is inserted as a row with a NULL price column, and each is then searched. (The INSERTs are performed starting from a state where there is no data in the prod table.)

```
ossdb=# INSERT INTO prod VALUES (6,'grape',NULL);
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       6 | grape     |
(4 rows)

ossdb=# SELECT * FROM prod WHERE price IS NULL;
 prod_id | prod_name | price
---------+-----------+-------
       6 | grape     |
(1 row)

ossdb=# SELECT * FROM prod WHERE price IS NOT NULL;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
(3 rows)
```

### Handling NULL in Aggregate Functions
NULL may be ignored in various aggregate functions.

In the following example, counting the total number of rows in the table with count(*) is compared to counting the number of values in the price column with count(price).

```
ossdb=# SELECT count(*) FROM prod;
 count
-------
     4
(1 row)

ossdb=# SELECT count(price) FROM prod;
 count
-------
     3
(1 row)
```

It is obvious that NULL does not affect the result of aggregate functions such as the total sum(price) or the maximum and minimum max(price), but what about the average avg(price)?

```
ossdb=# SELECT sum(price),count(price),avg(price) FROM prod;
 sum | count |         avg
-----+-------+---------------------
 220 |     3 | 73.3333333333333333
(1 row)
```

In practice, as can be seen from the earlier count(price) result, NULL is not included in the row count used to calculate the average, resulting in "220 ÷ 3 rows = 73.33..." as the result.

### Empty String
Similar to NULL, there is the "empty string." An empty string can be specified in an INSERT statement for a string-type column as `''` (two consecutive single quotes). An empty string is not NULL, so it does not violate a NOT NULL constraint.

In the following example, a row with an empty string in the prod_name column of the prod table is inserted. The price column is set to NULL. When the prod_name column is searched with an IS NULL condition, the empty string is not found because it represents a state where "an empty value exists." On the other hand, the price column, into which NULL was inserted, is found by IS NULL.
```
ossdb=# INSERT INTO prod VALUES (7,'',NULL);
INSERT 0 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       6 | grape     |
       7 |           |
(5 rows)

ossdb=# SELECT * FROM prod WHERE prod_name IS NULL;
 prod_id | prod_name | price
---------+-----------+-------
(0 rows)

ossdb=# SELECT * FROM prod WHERE price IS NULL;
 prod_id | prod_name | price
---------+-----------+-------
       6 | grape     |
       7 |           |
(2 rows)
```

## Sequences
A sequence is a feature that generates sequential numbers. For example, when used inside an INSERT statement, a sequence automatically inserts a sequential number as a value, making it suitable for columns that require unique, non-duplicated values such as ID numbers.

### Creating a Sequence
To create a sequence, use the CREATE SEQUENCE statement.

The syntax for creating a sequence is as follows:

```
CREATE SEQUENCE sequence_name;
```

The default values for a sequence when no values are specified at creation time are as follows:

| Item | Value
|---|---
| Start value | 1
| Increment | 1
| Maximum value | 2^63 - 1 (9,223,372,036,854,775,807)

### Sequence Operations
You can retrieve values from or set values in a sequence using sequence operation functions.

The currval() function returns the current value of a sequence. The sequence value is not updated. If the sequence value has not been retrieved even once within the session, an error will occur.

The nextval() function returns the next value after the current value and updates the sequence to that next value. By default, the sequence value increases by 1, so if the current value is 1, the next value will be 2. When the maximum value is reached, a call to nextval will result in an error by default.

In the following example, the order_id_seq sequence is created and its values are retrieved. The currval() function returns an error if the sequence has not been used, but once nextval() is used the error no longer occurs.

```
ossdb=# CREATE SEQUENCE order_id_seq;
CREATE SEQUENCE

ossdb=# SELECT currval('order_id_seq');
ERROR:  currval of sequence "order_id_seq" is not yet defined in this session

ossdb=# SELECT nextval('order_id_seq');
 nextval
---------
       1
(1 row)

ossdb=# SELECT currval('order_id_seq');
 currval
---------
       1
(1 row)

ossdb=# SELECT nextval('order_id_seq');
 nextval
---------
       2
(1 row)
```


### Setting Sequence Values
Using the setval() function, you can set the value of a sequence. The settable values start from 1.

In the following example, a sequence value is being set.

```
ossdb=# SELECT setval('order_id_seq',0);
ERROR:  setval: value 0 is out of bounds for sequence "order_id_seq" (1..9223372036854775807)

ossdb=# SELECT setval('order_id_seq',100);
 setval
--------
    100
(1 row)

ossdb=# SELECT currval('order_id_seq');
 currval
---------
     100
(1 row)

ossdb=# SELECT nextval('order_id_seq');
 nextval
---------
     101
(1 row)
```

### Using Sequences in SQL Statements
Sequences can be used inside INSERT statements.

In the following example, the order_id column value is obtained from the order_id_seq sequence in an INSERT statement that inserts row data into the orders table.

```
ossdb=# TRUNCATE orders;
TRUNCATE TABLE
ossdb=# SELECT setval('order_id_seq',100);
 setval
--------
    100
(1 row)

ossdb=# INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty)
VALUES (nextval('order_id_seq'),CURRENT_TIMESTAMP,2,1,7);
INSERT 0 1
ossdb=# SELECT * FROM orders;
 order_id |        order_date         | customer_id | prod_id | qty
----------+---------------------------+-------------+---------+-----
      101 | 2024-04-17 14:38:11.97433 |           2 |       1 |   7
(1 row)
```

### Using Sequences in Table Definitions
By specifying a sequence in the table definition, you can have values obtained from the sequence inserted automatically at INSERT time.

There are two methods: specifying SERIAL as the column data type, or specifying a pre-created sequence as the default value.

The following example defines the SERIAL type for the id column at table creation time. By specifying only the memo column value at INSERT time, the sequence value is automatically inserted into the id column.

```
ossdb=# CREATE TABLE serial_test(
	id	SERIAL,
	memo	TEXT);
CREATE TABLE
ossdb=# insert into serial_test(memo) values('SERIAL test');
INSERT 0 1
ossdb=# SELECT * FROM serial_test;
 id |    memo
----+-------------
  1 | SERIAL test
(1 row)
```

### Sequences and Gap Numbers
Sequences make it easy to generate sequential numbers, but even if a SQL statement fails, the sequence value still advances. This produces what is called "gaps" — sequential numbers with missing values.
A sequence does not guarantee a completely gapless sequence of numbers, and creating a completely gapless sequence is difficult. For example, if a row in the middle is deleted, the sequence is no longer completely consecutive. It is easier from a system design perspective to treat a sequence simply as a non-duplicated value for distinguishing rows, rather than expecting a perfectly consecutive sequence.

In the following example, even when an INSERT statement fails with an error, the sequence value advances, causing a gap in the next INSERT statement.

```
ossdb=# SELECT currval('order_id_seq');
 currval
---------
     101
(1 row)

ossdb=# INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty)
VALUES (nextval('order_id_seq'),now(),10,4,7);
ERROR:  insert or update on table "orders" violates foreign key constraint "orders_customer_id_fkey"
DETAIL:  Key (customer_id)=(10) is not present in table "customer".
ossdb=# SELECT currval('order_id_seq');
 currval
---------
     102
(1 row)

ossdb=# INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty)
VALUES (nextval('order_id_seq'),now(),1,2,5);
INSERT 0 1
ossdb=# SELECT * FROM orders;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
      101 | 2024-04-17 14:38:11.97433  |           2 |       1 |   7
      103 | 2024-04-17 14:43:04.379357 |           1 |       2 |   5
(2 rows)
```

\pagebreak
