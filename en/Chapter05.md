# Basic Exercises
In the previous chapters, you learned the basics of databases using SQL.

Let's review what you have learned with two exercise problems.

## Exercise 1: Data Manipulation {.unnumbered}

Try performing the following operations in SQL.

1. Increase the prices of all products in the prod table by 10%
2. Restore the prices of products in the prod table whose prices are 100 or higher
3. Save the data in the prod table to a file
4. Delete the prod table
5. Create the prod table again
6. Load the data into the prod table from the file

Be sure to check the table definition beforehand. Also refer to the example CREATE TABLE statement for creating the table in Chapter 1.

### Exercise 1-1: Increase the prices of all products in the prod table by 10% {.unnumbered}
Execute UPDATE on the price column of the prod table.

```
ossdb=# \d prod
                    Table "public.prod"
   Column  |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 prod_id   | integer |           |          |
 prod_name | text    |           |          |
 price     | integer |           |          |

ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
       2 | apple     |    70
       3 | melon     |   100
       4 | banana    |    31
(4 rows)

ossdb=# UPDATE prod SET price = price * 1.1;
UPDATE 4
ossdb=# SELECT * FROM prod;
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    55
       2 | apple     |    77
       3 | melon     |   110
       4 | banana    |    34
(4 rows)
```

### Exercise 1-2: Restore the prices of products in the prod table whose prices are 100 or higher {.unnumbered}
Execute UPDATE for products whose price value is 100 or greater.

```
ossdb=# UPDATE prod SET price = price/1.1 WHERE price >= 100;
UPDATE 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    55
       2 | apple     |    77
       4 | banana    |    34
       3 | melon     |   100
(4 rows)
```

### Exercise 1-3: Save the data in the prod table to a file {.unnumbered}
Use the COPY TO statement to save the data to a file.

```
ossdb=# COPY prod TO '/tmp/prod.csv' (FORMAT csv);
COPY 4
ossdb=# \\! cat /tmp/prod.csv
1,orange,55
2,apple,77
4,banana,34
3,melon,100
```

### Exercise 1-4: Delete the prod table {.unnumbered}
Use the DROP TABLE statement to delete the prod table.

```
ossdb=# DROP TABLE prod;
DROP TABLE
ossdb=# SELECT * FROM prod;
ERROR:  relation "prod" does not exist
LINE 1: SELECT * FROM prod;
                    ^
```

### Exercise 1-5: Create the prod table again {.unnumbered}
When creating a table, specify a data type for each column according to the data it stores. Use the integer type for integers such as IDs, the text type for characters, and the numeric type for numbers used in calculations.

```
ossdb=# CREATE TABLE prod ( prod_id     integer,
                            prod_name   text,
                            price       numeric );
CREATE TABLE
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
(0 rows)
```

### Exercise 1-6: Load the data into the prod table from a file {.unnumbered}
Use the COPY FROM statement to load the data from a file.
```
ossdb=# COPY prod FROM '/tmp/prod.csv' (FORMAT csv);
COPY 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    55
       2 | apple     |    77
       4 | banana    |    34
       3 | melon     |   100
(4 rows)
```

## Exercise 2: Postal Code Database {.unnumbered}
Let's design a postal code database.

Postal code data is published in CSV format. Design a database to store this postal code data, and then actually store the data in it.

### Exercise 2-1: Downloading Postal Code Data {.unnumbered}
You can download the postal code data from the following web page.

```
https://www.post.japanpost.jp/zipcode/download.html
```

Data is distributed in various formats. Click the link for "Address postal codes (one record per line, UTF-8 format)" under "Address postal codes (one record per line, UTF-8 format) (CSV format)".

From the "Download the latest data" link under "Data download," you can download a ZIP archive containing the CSV file. You need to either download it on the server or copy the downloaded file to the server.

```
https://www.post.japanpost.jp/service/search/zipcode/download/utf/zip/utf_ken_all.zip
```

The following example downloads the postal code CSV data on the server using the wget command and extracts it with the unzip command.

```
[postgres@host1 ~]$ wget https://www.post.japanpost.jp/service/search/zipcode/download/utf/zip/utf_ken_all.zip
--2026-05-15 16:47:23--  https://www.post.japanpost.jp/service/search/zipcode/download/utf/zip/utf_ken_all.zip
Resolving www.post.japanpost.jp (www.post.japanpost.jp)... 43.253.212.144
Connecting to www.post.japanpost.jp (www.post.japanpost.jp)|43.253.212.144|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2183402 (2.1M) [application/zip]
Saving to: `utf_ken_all.zip'

utf_ken_all.zip     100%[===================>]   2.08M  9.69MB/s in 0.2s

2024-04-10 15:23:02 (9.69 MB/s) - `utf_ken_all.zip' saved [2183402/2183402]

[postgres@host1 ~]$ ls
utf_ken_all.zip
[postgres@host1 ~]$ unzip utf_ken_all.zip
Archive:  utf_ken_all.zip
  inflating: utf_ken_all.csv
[postgres@host1 ~]$ ls -l utf_ken_all.csv
-rw-r--r--. 1 postgres postgres 18335216 Mar 22 10:40 utf_ken_all.csv
```

### Exercise 2-2: Creating the Postal Code Database Table {.unnumbered}
Create a table in the database to store the postal code data.

The data fields in the postal code data are as follows.

| Contents | Notes |
|---|---|
| National local government code (JIS X0401, X0402) | Half-width digits |
| (Old) postal code (5 digits) | Half-width digits |
| Postal code (7 digits) | Half-width digits |
| Prefecture name | Half-width katakana (listed in code order) |
| City, ward, town, or village name | Half-width katakana (listed in code order) |
| Area name | Half-width katakana (listed in gojuon order) |
| Prefecture name | Kanji (listed in code order) |
| City, ward, town, or village name | Kanji (listed in code order) |
| Area name | Kanji (listed in gojuon order) |
| Indicator for cases where one area is represented by two or more postal codes | |
| Indicator for areas where block numbers are assigned for each sub-area | |
| Indicator for areas that have chome | |
| Indicator for cases where one postal code represents two or more areas | |
| Update indicator | |
| Reason for change | |

Create the table based on these data fields.

The following example is a CREATE TABLE statement for creating the table, where fixed-length character data is defined as the char type and non-fixed-length character data is defined as the text type.

```
ossdb=# CREATE TABLE zip (
                          lgcode    char(5),
                          oldzip    char(5),
                          newzip    char(7),
                          prefkana  text,
                          citykana  text,
                          areakana  text,
                          pref      text,
                          city      text,
                          area      text,
                          largearea integer,
                          koaza     integer,
                          choume    integer,
                          smallarea integer,
                          change    integer,
                          reason    integer );
CREATE TABLE
```

### Exercise 2-3: Checking the Contents of the Postal Code Data {.unnumbered}
The data looks like the following.

```
[postgres@host1 ~]$ head -3 utf_ken_all.csv
01101,"060  ","0600000","HOKKAIDO","SAPPORO SHI CHUO KU",
"IF THERE IS NO LISTING BELOW","Hokkaido","Sapporo-shi Chuo-ku","No listing below",
0,0,0,0,0,0
01101,"064  ","0640941","HOKKAIDO","SAPPORO SHI CHUO KU",
"ASAHIGAOKA","Hokkaido","Sapporo-shi Chuo-ku","Asahigaoka",0,0,1,0,0,0
01101,"060  ","0600041","HOKKAIDO","SAPPORO SHI CHUO KU",
"ODORI HIGASHI","Hokkaido","Sapporo-shi Chuo-ku","Odori Higashi",0,0,1,0,0,0
```

### Exercise 2-4: Loading the Data {.unnumbered}
Use psql to load the CSV file.

In the following example, the CSV file is loaded using the `\copy` meta-command.

```
ossdb=# \copy zip from utf_ken_all.csv (format csv)
COPY 124370
```

### Exercise 2-5: Checking the Postal Code Data {.unnumbered}
Check the loaded postal code data.

In the following example, a filtered search is performed on the newzip column, which stores data for postal codes currently in use.

```
ossdb=# SELECT * FROM zip WHERE newzip = '1500002';
 lgcode | oldzip | newzip  |   prefkana   | citykana |                areakana                |  pref  |   city    |                area                 | largearea | koaza | choume | smallarea | change | reason
--------+--------+---------+--------------+----------+----------------------------------------+--------+-----------+-------------------------------------+-----------+-------+--------+-----------+--------+--------
 13113  | 150    | 1500002 | TOKYO TO     | SHIBUYA KU | SHIBUYA (EXCLUDING THE FOLLOWING BLDG.) | Tokyo  | Shibuya-ku | Shibuya (excluding the following building) |         0 |     0 |      1 |         0 |      0 |      0
(1 row)
```

\pagebreak
