# Table
In Chapter 4, we explain tables, the basic mechanism for storing data in a relational database.

## Creating Tables (CREATE TABLE)
In the previous chapter, we created simple tables in example statements and executed SQL statements against them. In an actual database, users create tables according to their needs. Let's look at how to create a table.

To create a table, use the CREATE TABLE statement.

The syntax of the CREATE TABLE statement is as follows.

```
CREATE TABLE table_name
	(column_name data_type [NULL|NOT NULL]
		| [UNIQUE]
		| [PRIMARY KEY (column_name[,...])]
		| [REFERNCES referenced_table_name (referenced_column_name)]
	[,...])
```

To create a table, you must decide the names of the columns and what kind of data each column will contain. Here, we create a staff table with the following three columns.

| | Column name | Data type
|----|--------|----------
| Employee number | id | integer type
| Name | name | text type
| Birthday | birthday | date type

In SQL, this becomes as follows. Once it has been created, verify that it appears in the list of tables and check the table definition.

```
ossdb=# CREATE TABLE staff
                    (id       integer,
                     name     text,
                     birthday date);
CREATE TABLE

ossdb=# \d
               List of relations
 Schema |     Name     |  Type   |  Owner
--------+--------------+---------+----------
 public | char_test    | table   | postgres
 public | customer     | table   | postgres
 public | date_test    | table   | postgres
 public | numeric_test | table   | postgres
 public | orders       | table   | postgres
 public | prod         | table   | postgres
 public | staff        | table   | postgres
 public | varchar_test | table   | postgres
(8 rows)

ossdb=# \d staff
                  Table "public.staff"
 Column   |  Type   | Collation | Nullable | Default
----------+---------+-----------+----------+---------
 id       | integer |           |          |
 name     | text    |           |          |
 birthday | date    |           |          |
```

## Storing Data in the staff Table
Let's store data in the staff table using the INSERT statement.

```
ossdb=# INSERT INTO staff (id,name,birthday) VALUES (1,'Toru Miyahara','1972-01-09');
INSERT 0 1
ossdb=# SELECT * FROM staff;
 id |     name      |  birthday
----+---------------+------------
  1 | Toru Miyahara | 1972-01-09
(1 row)
```

## Modifying Table Definitions (ALTER TABLE)
To modify a table definition after creating a table, use the ALTER TABLE statement.

With the ALTER TABLE statement, in addition to modifying the definition and behavior of the table itself, you can also modify column definitions within the table, so the way you specify it is correspondingly more complex.

Let's check the syntax help with the meta-command `\h`. You do not need to memorize the details here, but try to understand from the help that you specify the table to be changed and then specify an action such as "add a new column (= ADD COLUMN)."
```
ossdb=# \h ALTER TABLE
Command:     ALTER TABLE
Description: change the definition of a table
Syntax:
ALTER TABLE [ IF EXISTS ] [ ONLY ] name [ * ]
    action [, ... ]

(output omitted)

action is one of:

    ADD [ COLUMN ] [ IF NOT EXISTS ] column_name data_type [ COLLATE collation ] [ column_constraint [ ... ] ]
    DROP [ COLUMN ] [ IF EXISTS ] column_name [ RESTRICT | CASCADE ]
    ALTER [ COLUMN ] column_name [ SET DATA ] TYPE data_type [ COLLATE collation ] [ USING expression 
(output omitted)
```

Here, let's try an ALTER TABLE statement that adds a new column. We add the dept_id column representing the department assignment to the staff table, and then store a value in that column with the UPDATE statement.
```
ossdb=# ALTER TABLE staff ADD COLUMN dept_id integer;
ALTER TABLE
ossdb=# \d staff
                  Table "public.staff"
 Column   |  Type   | Collation | Nullable | Default
----------+---------+-----------+----------+---------
 id       | integer |           |          |
 name     | text    |           |          |
 birthday | date    |           |          |
 dept_id  | integer |           |          |

 ossdb=# UPDATE staff SET dept_id = 1 WHERE id = 1;
 UPDATE 1
 ossdb=# SELECT * FROM staff;
 id |     name      |  birthday  | dept_id
----+---------------+------------+---------
  1 | Toru Miyahara | 1972-01-09 |       1
(1 row)
```

## As a Rule, Do Not Modify Table Definitions
The ALTER TABLE statement can make many kinds of changes, but it is not desirable to casually modify column definitions when data has already been stored. At a minimum, consider the following design aspects and the impact of the work before deciding how to proceed.

### Is the Design Correct?  
For example, above we added the dept_id column to the staff table, but was managing department affiliation in the staff table really the ideal approach? It may indeed be convenient to list staff together with their affiliation information by running SELECT * FROM staff;. However, is it not possible that one staff member belongs to multiple departments?

In such cases, you create a new department affiliation table to represent the fact that "staff member 01 belongs to organization A." If "staff member 01 also belongs to organization C at the same time," you simply add another row.

An example of a department affiliation table is shown below. The Meaning column would not actually be included in a real database table.

| Staff ID | Department Code | Meaning
| --- | --- | ---
| 01 | A | Staff member 01 belongs to organization A |
| 02 | B | Staff member 02 belongs to organization B |
| 03 | C | Staff member 03 belongs to organization C |
| 01 | C | Staff member 01 belongs to organization C (showing that they belong to A and C at the same time) |

![Should ALTER TABLE Be Used?](./Pict/alter-01.png)

\pagebreak

### Impact of the Table Definition Change Work Itself
Even if it were appropriate for the staff list to have a department code, the change work itself could negatively affect the entire system.

If the table is small, the work finishes quickly, so there is little problem. But what if it is a member table for a web service containing data for several million people? If this table is referenced every time a user logs in, then while the table modification is in progress it cannot be referenced, and no one will be able to log in. In actual database product implementations, some do allow references while table definitions are being changed. However, updates to the data and similar operations become impossible, so some impact will still occur.

By considering the scope and duration of the impact, instead of changing the table definition, you can create a new table like the one above and keep the required data without disrupting user operations.

### Short-Term Measures and Medium- to Long-Term Measures
Suppose you create a new department affiliation table in order to store the necessary data for the time being. However, there may still be cases where, from a design perspective, having the department code in the staff list is in fact optimal.

Notifying users of a service outage period for major maintenance and changing to the ideal table can be useful as a medium- to long-term measure.

No matter what operation it is, you must consider how it will affect other SQL statements and programs. Among such operations, table maintenance in particular tends to have a broad impact, so be especially careful.

## Deleting a Table
To delete a table, use the DROP TABLE statement.
Deleting a table also deletes the data stored in that table and cannot be undone.

```
ossdb=# \d
               List of relations
 Schema |     Name     |  Type   |  Owner
--------+--------------+---------+----------
 public | char_test    | table   | postgres
 public | customer     | table   | postgres
 public | date_test    | table   | postgres
 public | numeric_test | table   | postgres
 public | orders       | table   | postgres
 public | prod         | table   | postgres
 public | staff        | table   | postgres
 public | varchar_test | table   | postgres
(8 rows)

ossdb=# DROP TABLE staff;
DROP TABLE
ossdb=# \d
               List of relations
 Schema |     Name     |  Type   |  Owner
--------+--------------+---------+----------
 public | char_test    | table   | postgres
 public | customer     | table   | postgres
 public | date_test    | table   | postgres
 public | numeric_test | table   | postgres
 public | orders       | table   | postgres
 public | prod         | table   | postgres
 public | varchar_test | table   | postgres
(7 rows)
```

## Deleting Data with TRUNCATE
For deleting data, in addition to DROP TABLE, which deletes the table definition itself, there are DELETE, which deletes only the rows that match a WHERE condition, and TRUNCATE, which deletes all data in a table while leaving the table itself intact.

If you want to delete data only from specific rows that match a condition, use the DELETE statement. However, deleting data with DELETE can take time when there are many target rows. For example, in cases where data accumulated over time needs to be deleted in bulk after its retention period has expired, you might divide the table by month or similar units and then TRUNCATE it month by month.

The DROP TABLE statement deletes not only the table and its data, but also related indexes, views, and other objects. If you recreate the table, these must also be redefined, which creates the problem of taking time. To avoid this problem, use the TRUNCATE statement when you want to delete only the row data in bulk.

The syntax of the TRUNCATE statement is as follows.

```
TRUNCATE table_name
```

In the following example, all row data in the char_test table is deleted with the TRUNCATE statement.

```
ossdb=# SELECT * FROM char_test;
 string
--------
 a
 ABC
 abc
(3 rows)

ossdb=# TRUNCATE char_test;
TRUNCATE TABLE
ossdb=# SELECT * FROM char_test;
 string
--------
(0 rows)
```

## Saving and Loading Data
Using psql, you can save data to a file or load data from a file.

There are two methods: using the COPY statement, which is SQL, and using `\copy`, which is a psql meta-command. They are similar, but the mechanism differs slightly. We will explain each of them.

### COPY Statements Are Executed as SQL
The COPY statement is executed as SQL, and PostgreSQL writes data directly to a file on the OS where it is running. Therefore, the following restrictions apply.

- It can be executed only by a PostgreSQL superuser. In this hands-on exercise, the postgres user is the superuser.
- It cannot write to a remote location. The data is written as a local file on the server where PostgreSQL is running. If you want the data on a remote system, you need to transfer the written file over the network.

### Saving Row Data with COPY TO
You can save data to a file with COPY TO.

The syntax for saving data with COPY TO is as follows. By specifying csv in the FORMAT clause, you can save the data as a CSV-format file.

```
COPY table_name TO file (FORMAT format)
```

In the following example, data from the customer table is saved to a file in CSV format.
The \\! meta-command executes a Linux shell command.

```
ossdb=# COPY customer TO '/tmp/customer.csv' (FORMAT csv);
COPY 3
ossdb=# \! cat /tmp/customer.csv
1,Sato Trading
2,Suzuki Products
3,Takahashi Store
```

Depending on the file destination, COPY TO may be rejected by SELinux, which controls OS security. How to check this is explained later.

### Loading a CSV File
You can load row data from a file with COPY FROM.

The syntax for loading data with the COPY statement is as follows. By specifying csv in the FORMAT clause, you can load from a CSV-format file.

```
COPY table_name FROM file (FORMAT format)
```

In the following example, data for the customer table is loaded from a CSV-format file.
```
ossdb=# DELETE FROM customer;
DELETE 3
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
(0 rows)

ossdb=# COPY customer FROM '/tmp/customer.csv' (FORMAT csv);
COPY 3
ossdb=# SELECT * FROM customer;
 customer_id |   customer_name
-------------+-----------------
           1 | Sato Trading
           2 | Suzuki Products
           3 | Takahashi Store
(3 rows)
```

### `\copy` Meta-Command Is Processed by psql
psql can use the `\copy` meta-command, which behaves similarly to the COPY statement. The differences are as follows.

- The COPY statement is SQL and is executed by the database server. The output file is created on the database server. In contrast, the `\copy` meta-command is a client-side data retrieval operation, and the output file is created on the client terminal.
- In addition to absolute paths, files can also be specified relative to the current directory of the client terminal when psql is executed.

Specific usage examples are explained in the exercises that follow.

### Reference: Relationship Between PostgreSQL and SELinux
With the COPY statement, PostgreSQL creates a file on the OS and saves data to it. This file creation may be rejected by SELinux, which controls security on the OS side.

The following is an example of attempting to create a CSV file in the home directory of the postgres user. SELinux rejects file creation in the home directory, and an error occurs.

```
ossdb=# COPY customer TO '/home/postgres/customer.csv' (FORMAT csv);
ERROR:  could not open file "/home/postgres/customer.csv" for writing: Permission denied
HINT:  COPY TO causes the PostgreSQL server process to write a file. You may need a client-side mechanism such as psql's \copy
```

SELinux logs are recorded in /var/log/audit/audit.log. If you search this log file for the string customer.csv, you can see what kind of processing was denied.

Processing related to OS file operations such as add_name by the postgresql_t context against the user_home_dir_t context is being denied.

```
[admin@host1 ~]$ sudo grep customer.csv /var/log/audit/audit.log
type=AVC msg=audit(1712711439.220:626): avc:  denied  { add_name } for  pid=24821 comm="postmaster" name="customer.csv" scontext=system_u:system_r:postgresql_t:s0 tcontext=unconfined_u:object_r:user_home_dir_t:s0 tclass=dir permissive=1
type=AVC msg=audit(1712711439.220:626): avc:  denied  { create } for  pid=24821 comm="postmaster" name="customer.csv" scontext=system_u:system_r:postgresql_t:s0 tcontext=system_u:object_r:user_home_dir_t:s0 tclass=file permissive=1
type=AVC msg=audit(1712711439.220:626): avc:  denied  { write open } for  pid=24821 comm="postmaster" path="/home/postgres/customer.csv" dev="dm-0" ino=18700809 scontext=system_u:system_r:postgresql_t:s0 tcontext=system_u:object_r:user_home_dir_t:s0 tclass=file permissive=1
type=AVC msg=audit(1712711439.220:627): avc:  denied  { getattr } for  pid=24821 comm="postmaster" path="/home/postgres/customer.csv" dev="dm-0" ino=18700809 scontext=system_u:system_r:postgresql_t:s0 tcontext=system_u:object_r:user_home_dir_t:s0 tclass=file permissive=1
```

If the processing you want to perform is rejected by SELinux, either change it so that the file is created in a location that is not rejected, such as the /tmp directory, or appropriately change the SELinux settings.

To determine whether SELinux is the cause, you can also temporarily run SELinux in Permissive mode. However, changing to Permissive should be done only for verification purposes, and once you have finished dealing with the problem, you must return it to Enforcing.

In the following example, SELinux is changed from Enforcing to Permissive.

```
[root@host1 ~]# getenforce
Enforcing
[root@host1 ~]# setenforce 0
[root@host1 ~]# getenforce
Permissive
```

If you execute the COPY statement again, it succeeds this time.

```
ossdb=# COPY customer TO '/home/postgres/customer.csv' (FORMAT csv);
COPY 3
```

Once you know the cause is SELinux, return it to Enforcing and take the appropriate measures.



\pagebreak
