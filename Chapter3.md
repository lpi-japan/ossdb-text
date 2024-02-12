# データ型
PostgreSQLでは、データをいくつかのデータ型に分類して保管しています。これまで利用してきたサンプルデータベースでは、以下の3つのデータ型を使用しています。

* 数値データ型
* 文字列データ型
* 日付データ型


## 数値データ型
数値データ型は、いわゆる「数字」を保管するためのデータ型です。データベースでは四則演算をはじめ、様々な数値演算のための関数などが用意されているので、簡単に数値データを加工して取り扱うことができます。

### integer型
整数のデータ型です。-2147483648から+2147483647までの整数値を格納することができます。整数値のため、小数点以下の値は格納されません。小数点以下の値は四捨五入されます。

以下の例では、値を30.4でINSERTすると小数点以下は四捨五入されて30で格納されています。値を30.5にUPDATEすると四捨五入されて31で格納されています。
``` {.haskell}
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

### numeric型
任意の精度の数値データ型です。小数点以下の値を含む数値を格納することができます。小数点より上は131072桁まで、小数点より下は16383桁までの桁数を指定できます。桁数を指定する場合、整数と小数点以下を合わせた桁数を「精度」、小数点以下の桁数を「位取り」と呼び、以下のように指定します。
``` {.haskell}
numeric(精度,位取り)
```

たとえば「numeric(6,2)」と指定すると、全体の桁数は6桁、小数点以下は2桁、整数部は6-2で4桁なので最大9999.99までの値を格納することができます。

以下の例では、numeric型のid列を持ったnumeric_test表を作成しています。整数部は4桁なので、5桁の値である19999を指定したINSERT文はエラーとなっています。

``` {.haskell}
ossdb=# CREATE TABLE numeric_test(
id numeric(6,2));
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

### その他の数値型
PostgreSQLはinteger型、numeric型以外の数値型も備えています。これらはデータの性質に合わせたデータベースへの保管や、互換性の維持などの目的のために用意されています。

#### 数値型一覧表

|データ型         |サイズ |範囲                                       |
|----------------|------|------------------------------------------|
|smallint        |2バイト|	-32768から+32767                         |
|integer         |4バイト|-2147483648から+2147483647                  |
|bigint          |8バイト|-9223372036854775808から+9223372036854775807 |
|decimal         |可変長 |小数点より上は131072桁まで、小数点より下は16383桁まで |
|numeric         |可変長 |小数点より上は131072桁まで、小数点より下は16383桁まで |
|real            |4バイト|6桁精度                                     |
|double precision|8バイト|15桁精度                                    |
|serial          |4バイト|1から2147483647                             |
|bigserial       |8バイト|1から9223372036854775807                    |

## 文字列データ型
文字列データ型は、文字のデータを保管することができます。数値型のような演算に比べて大小比較や演算などを行うことはできませんが、LIKE演算子のように部分一致検索などを行うことができます。

### character varying型(varchar型)
文字数に上限のある可変長の文字列型です。可変長ですから、文字数制限内であれば何文字の文字データでも構いません。上限を超える文字列を格納しようとするとエラーになります。

以下の例では、長さ3のvarchar型を持ったvarchar_test表を作成しています。文字数の長さは半角、全角にかかわらず長さ3（3文字）までを許容します。
``` {.haskell}
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

### character型(char型)
文字数に上限のある固定長の文字列型です。固定長のため、足りない分の文字数は空白で埋められます。

以下の例では、長さ3のchar型を持ったchar_test表を作成しています。一文字を格納すると末尾まで空白で埋められており、後方一致検索を使って空白を検索することで確認できます。
``` {.haskell}
ossdb=# CREATE TABLE char_test(
string char(3));
CREATE TABLE
ossdb=# INSERT INTO char_test VALUES ('あ');
INSERT 0 1
ossdb=# SELECT * FROM char_test WHERE string LIKE '% ';
 string
--------
 あ
(1 row)
```
上限である3文字を超える文字列を格納しようとするとエラーになります。
文字列数の長さは半角、全角にかかわらず長さ3（3文字）までです。
``` {.haskell}
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

### text型
文字数に上限のない可変長の文字列型です。文字列長の指定が必要ないため便利ですが、ANSI SQL標準には定義されていないデータ型です。

#### 文字列型一覧表

データ型 | 説明
--- | ---
character varying(n), varchar(n) | 上限付き可変長
character(n), char(n) | 空白で埋められた固定長
text | 制限なし可変長

## 日付・時刻データ型
日付・時刻データ型は、日付だけを格納するデータ型、時刻だけを格納するデータ型、両方を同時に格納するデータ型の３つが使用できます。目的に応じて使い分けるとよいでしょう。なお、本項では日付・時刻データ型の紹介とし、日付・時刻データを検索する際の特有の記述については後述します。

#### 日付・時刻データ型一覧表

データ型 | 説明
--- | ---
date | 日付のみ格納（時刻データは切り捨てられ00:00:00となる）
time | 時刻のみ格納（日付データを持たず日付型への変換不可）
timestamp | 日付と時刻を格納

以下の例では、date型、time型、timestamp型の3つの列を持ったdate_test表を作成しています。それぞれに現在時刻を挿入すると、各データ型で定められた「日付」「時刻」「日付と時刻」が格納されていることを確認します。（現在時刻を取得する`now()`関数については後述します。）
``` {.haskell}
ossdb=# CREATE TABLE date_test ( d_test  date,
                                 t_test  time,
                                 ts_test timestamp);
CREATE TABLE
ossdb=# \d date_test
                        Table "public.date_test"
 Column  |            Type             | Collation | Nullable | Default
---------+-----------------------------+-----------+----------+---------
 d_test  | date                        |           |          |
 t_test  | time without time zone      |           |          |
 ts_test | timestamp without time zone |           |          |

ossdb=# INSERT INTO date_test VALUES (now(),now(),now());
INSERT 0 1
ossdb=# SELECT * FROM date_test;
   d_test   |     t_test      |          ts_test
------------+-----------------+----------------------------
 2018-01-23 | 12:34:56.526066 | 2018-01-23 12:34:56.526066
(1 row)
```


\pagebreak

