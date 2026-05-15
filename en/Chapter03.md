# Data Types
PostgreSQL stores data by classifying it into several data types. Chapter 3 explains data types.


## Data Types Used in the Sample Database
The sample database used so far uses the following three data types.

- numeric data type
- character string data type
- date data type

## Numeric Data Types
A numeric data type is a data type for storing what we commonly call numbers. Databases provide functions for the four arithmetic operations and many other kinds of numeric operations, so numeric data can be processed and handled easily.

### integer type
This is an integer data type. It can store integer values from -2147483648 to +2147483647. Because it stores integer values, values after the decimal point are not stored. Values after the decimal point are rounded.

In the following example, when the value 30.4 is INSERTed, the digits after the decimal point are rounded and stored as 30. When the value is UPDATEd to 30.5, it is rounded and stored as 31.

```
ossdb=# INSERT INTO prod(prod_id,prod_name,price) VALUES (4,'バナナ',30.4);
INSERT 0 1
ossdb=# SELECT * FROM prod WHERE prod_id = 4;
 prod_id | prod_name | price
---------+-----------+-------
       4 | バナナ    |    30
(1 row)

ossdb=# UPDATE prod SET price = 30.5 WHERE prod_id = 4;
UPDATE 1
ossdb=# SELECT * FROM prod WHERE prod_id = 4;
 prod_id | prod_name | price
---------+-----------+-------
       4 | バナナ    |    31
(1 row)
```

### numeric type
This is a numeric data type with arbitrary precision. It can store numbers that include values after the decimal point. You can specify up to 131072 digits above the decimal point and up to 16383 digits below the decimal point. When specifying the number of digits, the total number of digits including the integer and fractional parts is called the precision, and the number of digits after the decimal point is called the scale, as shown below.

```
numeric(precision,scale)
```

For example, if you specify `numeric(6,2)`, the total number of digits is 6, the number of digits after the decimal point is 2, and the integer part is 4 digits because 6-2=4, so values from -9999.99 to 9999.99 can be stored.

In the following example, a `numeric_test` table is created with an `id` column of type `numeric`. Because the integer part is 4 digits, the INSERT statement specifying the 5-digit value 19999 results in an error.

```
ossdb=# CREATE TABLE numeric_test(id numeric(6,2));
CREATE TABLE
ossdb=# \d numeric_test
               Table "public.numeric_test"
 Column |     Type     | Collation | Nullable | Default
--------+--------------+-----------+----------+---------
 id     | numeric(6,2) |           |          |

ossdb=# INSERT INTO numeric_test VALUES (9999.99);
INSERT 0 1
ossdb=# INSERT INTO numeric_test VALUES (19999.99);
ERROR:  numeric field overflow
DETAIL:  A field with precision 6, scale 2 must round to an absolute value less than 10^4.
```

### Other Numeric Types
PostgreSQL also provides numeric types other than `integer` and `numeric`. These are provided for purposes such as storing data in the database according to the nature of the data and maintaining compatibility.

The following numeric types are available.

| Data type | Size | Range |
|---|---|---|
| smallint | 2 bytes | -32768 to +32767 |
| integer | 4 bytes | -2147483648 to +2147483647 |
| bigint | 8 bytes | -9223372036854775808 to +9223372036854775807 |
| decimal | variable length | up to 131072 digits above the decimal point and up to 16383 digits below the decimal point |
| numeric | variable length | up to 131072 digits above the decimal point and up to 16383 digits below the decimal point |
| real | 4 bytes | 6-digit precision |
| double precision | 8 bytes | 15-digit precision |
| serial | 4 bytes | 1 to 2147483647 |
| bigserial | 8 bytes | 1 to 9223372036854775807 |

## Character String Data Types
Character string data types can store character data. Different data types are available depending on factors such as the maximum number of characters and whether the type is variable-length or fixed-length.

| Data type | Description
|---|---
| character varying(n), varchar(n) | variable-length with limit
| character(n), char(n) | fixed-length padded with spaces
| text | variable-length with no limit

### character varying type (varchar type)
This is a variable-length string type with an upper limit on the number of characters. Because it is variable-length, any number of characters can be stored as long as it is within the character limit. An error occurs if you try to store a string that exceeds the limit.

In the following example, a `varchar_test` table is created with a `varchar` type of length 3. Up to length 3 (3 characters) is allowed regardless of whether the characters are half-width or full-width.
```
ossdb=# CREATE TABLE varchar_test(
varstring varchar(3));
CREATE TABLE
ossdb=# INSERT INTO varchar_test VALUES ('ABC');
INSERT 0 1
ossdb=# INSERT INTO varchar_test VALUES ('あいうえお');
ERROR:  value too long for type character varying(3)
ossdb=# INSERT INTO varchar_test VALUES ('あいう');
INSERT 0 1
ossdb=# INSERT INTO varchar_test VALUES ('AIUEO');
ERROR:  value too long for type character varying(3)
ossdb=# SELECT * FROM varchar_test;
 varstring
-----------
 ABC
 あいう
(2 rows)
```

### character type (char type)
This is a fixed-length string type with an upper limit on the number of characters. Because it is fixed-length, any missing characters are padded with spaces.

In the following example, a `char_test` table is created with a `char` type of length 3. When one character is stored, it is padded with spaces to the end. In the following example, when searching with the `LIKE` operator for strings from 1 to 3 characters in length, only the 3-character case is found.

```
ossdb=# CREATE TABLE char_test(
string char(3));
CREATE TABLE
ossdb=# INSERT INTO char_test VALUES ('あ');
INSERT 0 1
ossdb=# SELECT * FROM char_test WHERE string LIKE '_';
 string
--------
(0 rows)

ossdb=# SELECT * FROM char_test WHERE string LIKE '___';
 string
--------
 あ
(1 row)
```

An error occurs if you try to store a string longer than the limit of 3 characters.
The string length is limited to length 3 (3 characters) regardless of whether the characters are half-width or full-width.
```
ossdb=# INSERT INTO char_test VALUES ('ABC');
INSERT 0 1
ossdb=# INSERT INTO char_test VALUES ('あいうえお');
ERROR:  value too long for type character(3)
ossdb=# INSERT INTO char_test VALUES ('あいう');
INSERT 0 1
ossdb=# INSERT INTO char_test VALUES ('AIUEO');
ERROR:  value too long for type character(3)
ossdb=# SELECT * FROM char_test;
 string
--------
 あ
 ABC
 あいう
(3 rows)
```

### text type
This is a variable-length string type with no upper limit on the number of characters. It is convenient because there is no need to specify the string length, but it is a data type not defined in the ANSI SQL standard.

It is used in the `customer` table and `prod` table of the sample database.

```
ossdb=# \d customer
                    Table "public.customer"
     Column    |  Type   | Collation | Nullable | Default
---------------+---------+-----------+----------+---------
 customer_id   | integer |           |          |
 customer_name | text    |           |          |
```

## Date and Time Data Types
For date and time data types, you can use three kinds of data types: one that stores only dates, one that stores only times, and one that stores both. It is best to use them appropriately depending on the purpose.

In this section, we introduce date and time data types. The distinctive notation used when querying date and time data will be explained later.

| Data type | Description
|--- | ---
| date | stores only the date (time data is truncated and becomes 00:00:00) |
| time | stores only the time (has no date data and cannot be converted to the date type) |
| timestamp | stores the date and time |

In the following example, a `date_test` table is created with three columns of type `date`, `time`, and `timestamp`. When the current date and time are inserted into each column, you can confirm that each data type stores the defined `date`, `time`, and `date and time`. The `CURRENT_TIMESTAMP` function returns the current date and time as type `timestamp`.
```
ossdb=# CREATE TABLE date_test ( d_test  date,
                                 t_test  time,
                                 ts_test timestamp);
CREATE TABLE
ossdb=# \d date_test
                          Table "public.date_test"
   Column |            Type             | Collation | Nullable | Default
----------+-----------------------------+-----------+----------+---------
 d_test   | date                        |           |          |
 t_test   | time without time zone      |           |          |
 ts_test  | timestamp without time zone |           |          |

ossdb=# INSERT INTO date_test VALUES (CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);
INSERT 0 1
ossdb=# SELECT * FROM date_test;
   d_test   |     t_test      |          ts_test
------------+-----------------+----------------------------
 2024-04-07 | 22:58:38.353556 | 2024-04-07 22:58:38.353556
(1 row)
```


\pagebreak

