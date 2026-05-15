# Advanced SQL Database Operations
There are many other SQL syntax elements used for database operations. This chapter explains the SQL syntax that is most frequently used.

## Recreating the prod Table
The following exercises proceed with the prod table recreated.

Drop the prod table, then recreate it and execute INSERT statements for the new row data.

```
ossdb=# DROP TABLE prod;
DROP TABLE
ossdb=# CREATE TABLE prod ( prod_id     integer,
                            prod_name   text,
                            price       numeric  );
CREATE TABLE
ossdb=# INSERT INTO prod(prod_id,prod_name,price) VALUES
 (1,'orange',50),
 (2,'apple',70),
 (3,'melon',100),
 (4,'banana',30);
INSERT 0 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       4 | banana    |    30
(4 rows)
```

## Operators
When specifying conditions in a SELECT statement, you can use the AND/OR operators to specify multiple conditions, the LIKE operator to specify partial-match conditions, and the BETWEEN operator to specify a range of values. These have already appeared in the basic SQL section, but we will explain them in more detail here.

### AND/OR Operators
When you want to set multiple conditions in a WHERE clause used in a SELECT statement, you can use the AND and OR operators. The AND operator returns results when both specified conditions are satisfied; the OR operator returns results when either of the specified conditions is satisfied.

The following example retrieves only the rows in the prod table where the value of the price column is greater than 50 and less than 100.

```
ossdb=# SELECT * FROM prod WHERE price > 50 AND price < 100;
 prod_id | prod_name | price
---------+-----------+-------
       2 | apple     |    70
(1 row)
```

The following example retrieves rows in the customer table where the customer_id column is 1 or 2.

```
ossdb=# SELECT * FROM customer WHERE customer_id = 1 OR customer_id = 2;
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
           2 | Suzuki Products
(2 rows)
```

### LIKE Operator
The LIKE operator retrieves rows where the value of a column partially matches a specified condition.

Wildcards can be used to specify the condition.

| Wildcard | Description
|---|---
| _ | Any single character
| % | Any string of zero or more characters

The following example retrieves rows in the customer table where the customer_name column starts with "Suzuki".

```
ossdb=# SELECT * FROM customer WHERE customer_name LIKE 'Suzuki%';
 customer_id | customer_name
-------------+---------------
           2 | Suzuki Products
(1 row)
```

The following example retrieves rows in the customer table where the customer_name column contains "Trading". Because % appears on both sides, any row that contains "Trading" anywhere in the value will match the condition.

```
ossdb=# SELECT * FROM customer WHERE customer_name LIKE '%Trading%';
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
(1 row)
```

Note that while the LIKE operator is convenient, it can slow down search performance, so use it with care.

### BETWEEN Operator
The BETWEEN operator retrieves data where the value of a column falls within the range of two specified values. The two boundary values are specified with AND. Because the boundary values themselves are included, you can think of it as an "X or more, Y or less" condition.

The following example retrieves rows in the prod table where the price column is between 50 and 70.
```
ossdb=# SELECT * FROM prod WHERE price BETWEEN 50 AND 70;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
(2 rows)
```

## Aggregate Functions
Aggregate functions allow you to aggregate data using SQL statements, processing data in bulk and returning a single result.

The main aggregate functions are as follows.

| Function | Description
|---|---
| count function | Returns the number of rows in the target data
| sum function | Returns the sum of the target data (numeric)
| avg function | Returns the average of the target data (numeric)
| max function | Returns the maximum value of the target data (numeric or character)
| | For strings, the comparison is based on code point order
| min function | Returns the minimum value of the target data (numeric or character)
| | For strings, the comparison is based on code point order

### count Function  
The count function counts the number of rows of data.

```
ossdb=# SELECT count(order_id) FROM orders;
 count
-------
     5
(1 row)
```

### sum Function  
The sum function calculates the total of a specified column.

```
ossdb=# SELECT sum(qty) FROM orders;
 sum
-----
  30
(1 row)
```

### avg Function  
The avg function calculates the average of a specified column.

```
ossdb=# SELECT avg(qty) FROM orders;
        avg
--------------------
 6.0000000000000000
(1 row)
```

### max Function  
The max function calculates the maximum value of a specified column.

```
ossdb=# SELECT max(qty) FROM orders;
 max
-----
  10
(1 row)
```

### min Function  
The min function calculates the minimum value of a specified column.

```
ossdb=# SELECT min(qty) FROM orders;
 min
-----
   3
(1 row)
```

### Reference: Maximum/Minimum of String Data
The ordering of string data is evaluated based on the sort order of character code points.

The following example uses the convert_to function to display the UTF-8 code points for the characters "a" through "o", and confirms that sorting follows that order. The ORDER BY DESC clause sorts the data in the specified column in reverse order.

You can see that the results of the max and min functions also follow that sort order.

```
ossdb=# TRUNCATE char_test;
TRUNCATE TABLE
ossdb=# INSERT INTO char_test VALUES ('あ'),('い'),('う'),('え'),('お');
INSERT 0 5
ossdb=# SELECT string,convert_to(string,'utf8') FROM char_test
ORDER BY string DESC;
 string | convert_to
--------+------------
 お     | \xe3818a
 え     | \xe38188
 う     | \xe38186
 い     | \xe38184
 あ     | \xe38182
(5 rows)

ossdb=# SELECT max(string),min(string) FROM char_test ;
 max  | min
------+------
 お   | あ
(1 row)
```

## Combining GROUP BY with Aggregate Functions
The GROUP BY clause lets you group rows by a specified column and then calculate aggregate functions for each group.

The following example groups the rows in the orders table by the value of the prod_id column and calculates aggregate functions for each group.

```
ossdb=# SELECT prod_id,count(qty),sum(qty),avg(qty),min(qty),max(qty)
FROM orders
GROUP BY prod_id;
 prod_id | count | sum |        avg         | min | max
---------+-------+-----+--------------------+-----+-----
       3 |     1 |   8 | 8.0000000000000000 |   8 |   8
       2 |     2 |   9 | 4.5000000000000000 |   4 |   5
       1 |     2 |  13 | 6.5000000000000000 |   3 |  10
(3 rows)
```
In the prod table, the item with prod_id 1 was "orange". Oranges were sold twice, and the quantity qty sold each time is aggregated here. The total quantity is 13 units, and the highest single-sale quantity was 10 units — this gives us information about oranges. Similarly, "apple" totals 9 units and "melon" totals 8 units, with aggregation performed for each data value in the column specified by GROUP BY.

### HAVING Clause
The HAVING clause lets you filter groups after grouping. Because HAVING filters on groups, the comparison target must be an aggregate function.

The following example groups the rows in the orders table by the prod_id column and retrieves only the groups where the total qty is less than 10.
```
ossdb=# SELECT prod_id,sum(qty) FROM orders
GROUP BY prod_id;
 prod_id | sum
---------+-----
       3 |   8
       2 |   9
       1 |  13
(3 rows)

ossdb=# SELECT prod_id,sum(qty) FROM orders
GROUP BY prod_id
HAVING sum(qty) < 10;
 prod_id | sum
---------+-----
       3 |   8
       2 |   9
(2 rows)
```

### Order of Application of WHERE, GROUP BY, and HAVING with Aggregate Functions
When using aggregate functions in a query, the WHERE, GROUP BY, and HAVING clauses are applied in the following order.

1. Row filtering by the WHERE clause
2. Grouping by the GROUP BY clause
3. Group filtering by the HAVING clause

First, the WHERE clause filters all rows that are the target of the search. Rows excluded at this point are not included in the aggregate function calculations. Next, the GROUP BY clause groups the remaining rows. The HAVING clause then filters the groups based on the results of the aggregate function calculations on those groups.

## Subqueries
A subquery is a SQL expression that executes another SELECT statement inside a SELECT statement. Because the main query executes based on the results returned by the subquery, it enables searches with dynamic conditions. Subqueries can be used in combination with the EXISTS and IN operators.

### EXISTS Operator
The EXISTS operator causes the main query to return results when the subquery returns one or more rows.

With the EXISTS operator, the main query executes first and passes each returned row's values one at a time to the subquery for evaluation. When the subquery returns one or more rows, the row returned by the main query is included in the final result.

The following example retrieves one row at a time from the prod table in the main query, then checks in the subquery whether the same prod_id value exists in the orders table. Orange, apple, and melon all have rows in the orders table, but banana, which has prod_id 4, has no rows in the orders table and therefore is not returned as a result of the main query.

```
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       4 | banana    |    30
(4 rows)

ossdb=# SELECT * FROM orders;
  order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2024-04-06 14:55:30.607262 |           1 |       1 |  10
        2 | 2024-04-06 14:55:30.612462 |           2 |       2 |   5
        3 | 2024-04-06 14:55:30.6152   |           3 |       3 |   8
        4 | 2024-04-06 14:55:30.616348 |           2 |       1 |   3
        5 | 2024-04-06 14:55:30.617621 |           3 |       2 |   4
(5 rows)

ossdb=# SELECT prod_id,prod_name FROM prod
WHERE EXISTS (SELECT * FROM orders WHERE orders.prod_id = prod.prod_id);
 prod_id | prod_name
---------+-----------
       1 | orange
       2 | apple
       3 | melon
(3 rows)
```

### IN Operator
The IN operator can execute a subquery as the set of values for a WHERE clause condition in the main query.

The following example retrieves the prod_id and prod_name columns from the prod table based on the prod_id values from rows in the orders table where the qty column is greater than 5.

```
ossdb=# SELECT prod_id FROM orders WHERE qty > 5;
 prod_id
---------
       1
       3
(2 rows)

ossdb=# SELECT prod_id,prod_name FROM prod
WHERE prod_id IN (SELECT prod_id FROM orders WHERE qty > 5);
 prod_id | prod_name
---------+-----------
       1 | orange
       3 | melon
(2 rows)
```

## Handling Date and Time Data
Date and time data has special handling methods that differ from numeric and string types.

### Checking and Setting the Date Format
The date format varies by country and environment. To check the date format currently configured in PostgreSQL, run SHOW DATESTYLE.

The following example shows that the format is ISO with YMD — that is, year-month-day order. In this case, a date written with a two-digit year such as "24-04-14" is interpreted as year-month-day and treated as "April 14, 2024".

```
ossdb=# SHOW DATESTYLE;
 DateStyle
-----------
 ISO, YMD
(1 row)

ossdb=# SELECT '24-04-14'::date;
    date
------------
 2024-04-14
(1 row)
```

You can also change DATESTYLE. For example, changing to the American style of month-day-year means that the same string "24-04-14" would be interpreted as "month 24, day 4 of 2014", which results in an error.
```
ossdb=# set DATESTYLE to 'ISO, MDY';
SET
ossdb=# SHOW DATESTYLE;
 DateStyle
-----------
 ISO, MDY
(1 row)

ossdb=# SELECT '24-04-14'::date;
ERROR:  date/time field value out of range: "24-04-14"
LINE 1: SELECT '24-04-14'::date;
               ^
HINT:  Perhaps you need a different "datestyle" setting.

ossdb=# SELECT '04-14-24'::date;
    date
------------
 2024-04-14
(1 row)
```

As shown here, date formats vary by country and environment settings, so always check the format and change the setting as needed. Specifying the year with only two digits is not recommended because it can lead to misinterpretation, so use four digits whenever possible. The format "2024-04-14" is always treated as "April 14, 2024" and is the recommended format.

```
ossdb=# SHOW DATESTYLE;
 DateStyle
-----------
 ISO, MDY
(1 row)

ossdb=# SELECT '2024-04-14'::date;
    date
------------
 2024-04-14
(1 row)
```

## Functions for Retrieving the Current Date and Time
There are functions you can use to obtain the current date or time when inserting row data, for example.

### CURRENT_DATE/CURRENT_TIME/CURRENT_TIMESTAMP Functions
The CURRENT_DATE, CURRENT_TIME, and CURRENT_TIMESTAMP functions retrieve the current date, time, and date-and-time respectively.

The following example uses them in a SELECT statement, but they can also be used in INSERT and UPDATE statements.

```
ossdb=# SELECT CURRENT_DATE;
 current_date
--------------
 2024-04-14
(1 row)

ossdb=# SELECT CURRENT_TIME;
    current_time
--------------------
 16:31:41.243898+09
(1 row)

ossdb=# SELECT CURRENT_TIMESTAMP;
       current_timestamp
-------------------------------
 2024-04-14 16:31:47.848579+09
(1 row)
```

### now() Function
The now() function retrieves the current date and time. The result is returned as the TIMESTAMP type, the same as CURRENT_TIMESTAMP.

```
ossdb=# SELECT now();
              now
-------------------------------
 2024-04-14 16:52:24.355623+09
(1 row)
```

## Complex Joins
In addition to ordinary joins using the JOIN clause, there are also outer joins and self joins.

### Outer Join
With an ordinary join (equi-join) using the JOIN clause, a row will not be included in the results unless matching rows exist in both tables being joined.

The following example adds a new row to the customer table and then uses an ordinary join to retrieve which store sold which product and how many. However, the store "Fujiwara Distribution", which was just added to the customer table, has no sales history in the orders table, so it does not appear at all in the results.

```
ossdb=# INSERT INTO customer(customer_id,customer_name) VALUES (4,'Fujiwara Distribution');
INSERT 0 1
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
           1 | Sato Trading
           2 | Suzuki Products
           3 | Takahashi Store
           4 | Fujiwara Distribution
(4 rows)

ossdb=# SELECT c.customer_name,o.prod_id,o.qty
FROM customer c JOIN orders o
ON c.customer_id = o.customer_id;
 customer_name   | prod_id | qty
-----------------+---------+-----
 Sato Trading    |       1 |  10
 Suzuki Products |       2 |   5
 Suzuki Products |       1 |   3
 Takahashi Store |       3 |   8
 Takahashi Store |       2 |   4
(5 rows)
```

An outer join is a join method that can include in the results even the rows that would otherwise disappear because they exist in only one of the tables. Using the LEFT OUTER JOIN clause ensures that all rows from the table on the left side of the join are included in the results.

In the example below, a left outer join is performed between the customer table (on the left of the JOIN clause) and the orders table. The only difference from the example above is replacing "JOIN" with "LEFT OUTER JOIN", but this ensures that even when no matching row exists in the orders table, every piece of data in the customer table is included in the results. You can see that the store "Fujiwara Distribution" appears in the results but has no sales history.

```
ossdb=# SELECT c.customer_name,o.prod_id,o.qty
FROM customer c LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id;
 customer_name         | prod_id | qty
-----------------------+---------+-----
 Sato Trading          |       1 |  10
 Suzuki Products       |       2 |   5
 Suzuki Products       |       1 |   3
 Takahashi Store       |       3 |   8
 Takahashi Store       |       2 |   4
 Fujiwara Distribution |         |
(6 rows)
```

Outer joins across multiple tables are also possible.

The following example additionally joins the prod table using the LEFT OUTER JOIN clause. The prod_id is replaced with the product name.

```
ossdb=# SELECT c.customer_name,p.prod_name,o.qty
FROM customer c
LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
LEFT OUTER JOIN prod p ON o.prod_id = p.prod_id;
 customer_name         | prod_name | qty
-----------------------+-----------+-----
 Sato Trading          | orange    |  10
 Suzuki Products       | orange    |   3
 Suzuki Products       | apple     |   5
 Takahashi Store       | apple     |   4
 Takahashi Store       | melon     |   8
 Fujiwara Distribution |           |
(6 rows)
```
Depending on the situation, the RIGHT OUTER JOIN and FULL OUTER JOIN clauses can be used in the same way.

### Cross Join
For a query that retrieves all combinations of stores and products, use a cross join, which specifies no join condition.
The following example retrieves all possible combinations (4×4=16 rows) from the customer table (4 rows) and the prod table (4 rows). From the outer join results above, we know that the combination "banana sold at Fujiwara Distribution" does not exist in the actual data, but a cross join retrieves all possible combinations.

```
ossdb=# SELECT customer_name,prod_name
FROM customer c
CROSS JOIN prod p;
 customer_name         | prod_name
-----------------------+-----------
 Sato Trading          | orange
 Sato Trading          | apple
 Sato Trading          | melon
 Sato Trading          | banana
 Suzuki Products       | orange
 Suzuki Products       | apple
 Suzuki Products       | melon
 Suzuki Products       | banana
 Takahashi Store       | orange
 Takahashi Store       | apple
 Takahashi Store       | melon
 Takahashi Store       | banana
 Fujiwara Distribution | orange
 Fujiwara Distribution | apple
 Fujiwara Distribution | melon
 Fujiwara Distribution | banana
(16 rows)
```

The same result can also be obtained by listing multiple tables separated by commas after the FROM clause, without using the JOIN clause as shown below. (In this case, when a join condition is needed, use a WHERE clause instead of an ON clause.)

```
ossdb=# SELECT customer_name,prod_name
FROM customer c, prod p;
 customer_name         | prod_name
-----------------------+-----------
 Sato Trading          | orange
 Sato Trading          | apple
 Sato Trading          | melon
 Sato Trading          | banana
 Suzuki Products       | orange
 Suzuki Products       | apple
 Suzuki Products       | melon
 Suzuki Products       | banana
 Takahashi Store       | orange
 Takahashi Store       | apple
 Takahashi Store       | melon
 Takahashi Store       | banana
 Fujiwara Distribution | orange
 Fujiwara Distribution | apple
 Fujiwara Distribution | melon
 Fujiwara Distribution | banana
(16 rows)
```

### Self Join
A self join is a join method that treats one table as if it were two separate tables. To distinguish the two copies, you must use aliases for the table.

The following example searches for all combinations of products whose combined price totals less than 100. There is only one prod table, but it is treated as two tables named p1 and p2 using aliases. p1 and p2 are then joined with a simple join (a join that produces all combinations), and the results are filtered by the WHERE clause based on the total price.
```
ossdb=# SELECT p1.prod_name,p2.prod_name,p1.price + p2.price AS pricesum
FROM prod p1,prod p2
WHERE p1.price + p2.price < 100;
 prod_name | prod_name | pricesum
-----------+-----------+----------
 orange    | banana    |       80
 banana    | orange    |       80
 banana    | banana    |       60
(3 rows)
```

This may be a little hard to understand on its own, but it becomes clearer if you look at the intermediate steps. The prod table contains the following data.

```
ossdb=# SELECT prod_name,price FROM prod;
 prod_name | price
-----------+-------
 orange    |    50
 apple     |    70
 melon     |   100
 banana    |    30
(4 rows)
```

By performing a self join on this, we generate all combinations when choosing two products. We use a cross join for the combinations.

```
ossdb=# SELECT p1.prod_name,p1.price,
               p2.prod_name,p2.price
FROM prod p1,prod p2;
 prod_name | price | prod_name | price
-----------+-------+-----------+-------
 orange    |    50 | orange    |    50
 orange    |    50 | apple     |    70
 orange    |    50 | melon     |   100
 orange    |    50 | banana    |    30
 apple     |    70 | orange    |    50
 apple     |    70 | apple     |    70
 apple     |    70 | melon     |   100
 apple     |    70 | banana    |    30
 melon     |   100 | orange    |    50
 melon     |   100 | apple     |    70
 melon     |   100 | melon     |   100
 melon     |   100 | banana    |    30
 banana    |    30 | orange    |    50
 banana    |    30 | apple     |    70
 banana    |    30 | melon     |   100
 banana    |    30 | banana    |    30
(16 rows)
```

Next, let's display the combined total price for each row to the right of this result.

```
ossdb=# SELECT p1.prod_name,p1.price "price1",
               p2.prod_name,p2.price "price2",
               p1.price + p2.price   "total"
FROM prod p1,prod p2;
 prod_name | price1 | prod_name | price2 | total
-----------+--------+-----------+--------+-------
 orange    |     50 | orange    |     50 |   100
 orange    |     50 | apple     |     70 |   120
 orange    |     50 | melon     |    100 |   150
 orange    |     50 | banana    |     30 |    80
 apple     |     70 | orange    |     50 |   120
 apple     |     70 | apple     |     70 |   140
 apple     |     70 | melon     |    100 |   170
 apple     |     70 | banana    |     30 |   100
 melon     |    100 | orange    |     50 |   150
 melon     |    100 | apple     |     70 |   170
 melon     |    100 | melon     |    100 |   200
 melon     |    100 | banana    |     30 |   130
 banana    |     30 | orange    |     50 |    80
 banana    |     30 | apple     |     70 |   100
 banana    |     30 | melon     |    100 |   130
 banana    |     30 | banana    |     30 |    60
(16 rows)
```

Now add a WHERE condition to this result to filter for "combined price less than 100".

```
ossdb=# SELECT p1.prod_name,p1.price "price1",
               p2.prod_name,p2.price "price2",
               p1.price + p2.price   "total"
FROM prod p1,prod p2
WHERE p1.price + p2.price < 100;
 prod_name | price1 | prod_name | price2 | total
-----------+--------+-----------+--------+-------
 orange    |     50 | banana    |     30 |    80
 banana    |     30 | orange    |     50 |    80
 banana    |     30 | banana    |     30 |    60
(3 rows)
```

All that remains is to narrow down the SELECT list to only what you need, and you get the same result as the first SQL statement executed.

## Limiting the Number of Rows with the LIMIT Clause
The LIMIT clause lets you limit the number of rows retrieved by a query. Normally, a SQL query returns all rows that match the condition, but specifying LIMIT lets you retrieve only the number of rows you need.

### Specifying LIMIT and Sort Order
Because the order of query results is not guaranteed, you need to use the ORDER BY clause to specify the ordering of the rows in order to reliably retrieve the intended rows.

The following example retrieves only 3 rows from the orders table. To fix the order, the rows are sorted by the order_id column.

```
ossdb=# SELECT * FROM orders ORDER BY order_id;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2024-04-06 14:55:30.607262 |           1 |       1 |  10
        2 | 2024-04-06 14:55:30.612462 |           2 |       2 |   5
        3 | 2024-04-06 14:55:30.6152   |           3 |       3 |   8
        4 | 2024-04-06 14:55:30.616348 |           2 |       1 |   3
        5 | 2024-04-06 14:55:30.617621 |           3 |       2 |   4
(5 rows)

ossdb=# SELECT * FROM orders ORDER BY order_id LIMIT 3;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2024-04-06 14:55:30.607262 |           1 |       1 |  10
        2 | 2024-04-06 14:55:30.612462 |           2 |       2 |   5
        3 | 2024-04-06 14:55:30.6152   |           3 |       3 |   8
(3 rows)
```

### OFFSET Clause
By combining OFFSET, you can skip a specified number of rows from the beginning before retrieving rows.

The following example gives a value of 1 to the OFFSET clause, so it skips the first row and retrieves 3 rows starting from the second row.
```
ossdb=# SELECT * FROM orders ORDER BY order_id LIMIT 3 OFFSET 1;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        2 | 2024-04-06 14:55:30.612462 |           2 |       2 |   5
        3 | 2024-04-06 14:55:30.6152   |           3 |       3 |   8
        4 | 2024-04-06 14:55:30.616348 |           2 |       1 |   3
(3 rows)
```

\pagebreak
