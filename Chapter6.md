# SQLによるデータベースの操作 応用編
データベースの操作に使用するSQL文には、他にも様々な文法が存在しています。この章では、特に多用するSQL文の文法について解説します。

* 以降の実行例は、prod表が以下の状態になっている前提で記載します。
```
ossdb=# DROP TABLE prod;
DROP TABLE
ossdb=# CREATE TABLE prod ( prod_id     integer,
                            prod_name   text,
                            price       numeric  );
CREATE TABLE
ossdb=# INSERT INTO prod(prod_id,prod_name,price) VALUES
 (1,'みかん',50),
 (2,'りんご',70),
 (3,'メロン',100),
 (4,'バナナ',30);
INSERT 0 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    50
       2 | りんご    |    70
       3 | メロン    |   100
       4 | バナナ    |    30
(4 rows)
```

## 演算子と関数

### 演算子
* AND/OR演算子  
SELECT文などに指定するWHERE句の条件で、複数の条件を設定したい場合にはAND演算子、OR演算子が使用できます。  
AND演算子は指定した条件が両方満たされる場合、OR演算子は指定した条件のいずれかが満たされる場合にSQL文の結果が表示されます。  
以下の例は、prod表のprice列の値が50よりも大きく、100よりも小さい行データのみを検索しています。
```
ossdb=# SELECT * FROM prod WHERE price > 50 AND price < 100;
 prod_id | prod_name | price
---------+-----------+-------
       2 | りんご    |    70
(1 row)
```
以下の例は、customer表のcustomer_id列が1または2の行データを検索しています。
```
ossdb=# SELECT * FROM customer WHERE customer_id = 1 OR customer_id = 2;
 customer_id | customer_name
-------------+---------------
           1 | 佐藤商事
           2 | 鈴木物産
(2 rows)
```

* LIKE演算子  
ある列の値が指定した条件に部分的に一致する行データを取り出します。  
以下の例では、customer表のcustomer_name列が「鈴木」で始まる行データを検索しています。
```
ossdb=# SELECT * FROM customer WHERE customer_name LIKE '鈴木%';
 customer_id | customer_name
-------------+---------------
           2 | 鈴木物産
(1 row)
```
以下の例では、customer表のcustomer_name列に「商」が含まれる行データを検索しています。前後に%がついているので、値のどこに「商」があっても検索条件に一致します。
```
ossdb=# SELECT * FROM customer WHERE customer_name LIKE '%商%';
 customer_id | customer_name
-------------+---------------
           1 | 佐藤商事
           3 | 高橋商店
(2 rows)
```
なおLIKE演算子は便利な反面、性能上検索速度が遅くなる場合があるので、注意して使う必要があるでしょう。

#### LIKE演算子で使用できるワイルドカード

|ワイルドカード|内容 |
|-------|---------|
|_      |1文字      |
|%      |0文字以上の文字列|

* BETWEEN演算子  
ある列の値が指定した2つの条件値の範囲内にあるデータを取り出します。2つの条件値はANDで指定します。条件値そのものも含まれるので「○以上、○以下」という条件であると考えればよいでしょう。  
以下の例では、prod表のprice列が50から70の間の行データを検索しています。
```
ossdb=# SELECT * FROM prod WHERE price BETWEEN 50 AND 70;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    50
       2 | りんご    |    70
(2 rows)
```

### 関数
* 集約関数  
集約関数を使用すると、データをSQL文で集計することができ、データを一括で処理して1つの結果を返します。

#### 主な集約関数
|関数 | 説明|
|--- | ---|
|count関数 | 対象データの件数を返す|
|sum関数 | 対象データ（数値）の合計値を返す|
|avg関数 | 対象データ（数値）の平均値を返す|
|max関数 | 対象データ（数値または文字）の最大値を返す|
| |文字の場合、コード順で大小を評価|
|min関数 | 対象データ（数値または文字）の最小値を返す|
| |文字の場合、コード順で大小を評価|

* count関数  
count関数はデータの行数を数える関数です。
```
ossdb=# SELECT count(order_id) FROM orders;
 count
 ------
     5
(1 row)
```

* sum関数  
sum関数は指定された列の合計を計算する関数です。
```
ossdb=# SELECT sum(qty) FROM orders;
 sum
 ----
  30
(1 row)
```

* avg関数  
avg関数は指定された列の平均を計算する関数です。
```
ossdb=# SELECT avg(qty) FROM orders;
        avg
 -------------------
 6.0000000000000000
(1 row)
```

* max関数  
max関数は指定された列の最大値を計算する関数です。
```
ossdb=# SELECT max(qty) FROM orders;
 max
 -----
  10
(1 row)
```

* min関数  
min関数は指定された列の最小値を計算する関数です。
```
ossdb=# SELECT min(qty) FROM orders;
 min
 -----
   3
(1 row)
```

参考： 文字データの最大/最小  
文字データの大小関係は、文字コードの並び順により評価されます。  
以下の例では、「あ」～「お」を表すUTF-8の文字コードを表示し、その順序通りに並べ替えが行われていることを確認しています。max関数やmin関数の結果も並び順に従っていることがわかります。
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

### GROUP BY句と集約関数の組み合わせ
GROUP BY句を使うと、指定された列で行をグループ化し、それぞれのグループ毎に集約関数の計算を行うことができます。

以下の例は、orders表の行データをprod_id列の値毎にグループ化し、各グループ毎に集約関数で計算を行っています。
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
prod表では、prod_idの1番は「みかん」でした。みかんが2回販売され、そのときに販売された数量qtyを集計しています。合計数量は13個、もっとも多く売れたときは一度に10個売れた、というようにみかんについての情報が得られます。同様に「りんご」は9個、「メロン」は8個というように、GROUP BYで指定した列の各データに対して集計が行われます。

### HAVING句
HAVING句を使うと、グループ化した後のグループに対して条件による絞り込みを行うことができます。HAVING句はグループに対しての絞り込みを行うため、比較対象は集約関数である必要があります。

以下の例では、orders表の行データをprod_id列の値毎にグループ化し、qty列の合計値が10未満の結果のみ取得しています。
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

### WHERE句、GROUP BY句、HAVING句の適用順序
集約関数を使った検索では、WHERE句、GROUP BY句、HAVING句が以下の順序で適用されます。

1. WHERE句による行に対する絞り込み
2. GROUP BY句によるグループ化
3. HAVING句によるグループに対する絞り込み

まずWHERE句で検索対象になる行全体に対して絞り込みが行われます。この時点で除外された行は集約関数の対象にはなりません。次にGROUP BY句によるグループ化が行われます。HAVING句はこのグループに対して集約関数で計算を行い、指定された演算子に基づいて絞り込みを行います。

例えば、ある学習塾の "優秀な" 高校生向けプロモーションのために、現在の生徒情報から①「年齢別」「地域別」に生徒数を集計し生徒数の傾向を調べることを考えます。
②今回は「高校生向け」という条件があるので、年齢を絞ることで集計対象になる件数集計対象の年齢を大きく減らし絞ります。
③優秀な学生というプロモーションの趣旨をどう検索に落とし込むかは担当者の腕の見せ所かと思いますが、ここでは「進学校がある」のような地域性を考え「地域別にみたときのテストの平均点が80点を超える」とします。

SQLを考えると以下のようになるでしょう。
```
SELECT 年齢,地域,count(*),avg(点数)
FROM   生徒一覧
WHERE  年齢 BETWEEN 16 AND 18 --------- ② 年齢の条件で分類に関係ないデータを除外
GROUP BY 年齢,地域--------------------- ① 年齢、地域別に分類
HAVING avg(点数) >= 80;---------------- ③ 平均点が80点を超えるグループを抽出
```
ここで注目して欲しいのは②の年齢の条件と、③の平均点の条件です。実は、両条件をHAVING句にまとめて書いても良いのです。得られる結果は全く同じです。
```
SELECT 年齢,地域,count(*),avg(点数)
FROM   生徒一覧
GROUP BY 年齢,地域
HAVING avg(点数) >= 80
AND    年齢  BETWEEN 16 AND 18;------- 年齢の条件をHAVING句に記述
```
2つのSQLの違いは、その検索パフォーマンスに現れます。ある「年齢・地域」グループの平均点が80点以上であることは、集計された結果をみて初めて適用できる条件ですので、HAVING句に書くほかありません。前者は、集計対象とする16歳以上18歳以下という条件をWHERE句で記述し、絞り込んだ行のみを集計しています。
後者は年齢による絞り込みをせずに全件（おそらく小学生、中学生が名簿には多数含まれるでしょう）を対象に集計し、最後にHAVING句で年齢を絞り込んでいます。無駄な集計作業に時間をかけているのです。

## 副問い合わせ
副問い合わせは、SELECT文の中でさらにSELECT文を実行するSQLの記述です。副問い合わせで検索された結果に基づいて主問い合わせを実行することができるので、動的な条件での検索が可能になります。副問い合わせはEXISTS演算子、IN演算子と組み合わせて実行できます。

### EXISTS演算子
EXISTS演算子は、副問い合わせの結果が行を1行以上返した場合、主問い合わせが結果を返します。

EXISTS演算子では、まず主問い合わせが実行され、返された行データの値が1行ずつ副問い合わせに渡されて実行されます。副問い合わせが行を1行以上返すと、主問い合わせが返した行データが最終的に結果として返されます。

以下の例では、主問い合わせでprod表から1行ずつ行データを取り出し、副問い合わせでorders表に対してprod_id列に同じ値が存在するかを確認します。みかん、りんご、メロンはorders表に行データが存在していますが、prod_id列の値が4のバナナはorders表に行データが存在していないため、主問い合わせの結果として返されません。
```
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    50
       2 | りんご    |    70
       3 | メロン    |   100
       4 | バナナ    |    30
(4 rows)

ossdb=# SELECT * FROM orders;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2018-01-22 12:34:51.510398 |           1 |       1 |  10
        2 | 2018-01-22 12:34:58.875188 |           2 |       2 |   5
        3 | 2018-01-22 12:35:07.440391 |           3 |       3 |   8
        4 | 2018-01-22 12:35:16.847541 |           2 |       1 |   3
        5 | 2018-01-22 12:35:26.164922 |           3 |       2 |   4
(5 rows)

ossdb=# SELECT prod_id,prod_name FROM prod
WHERE EXISTS (SELECT * FROM orders WHERE orders.prod_id = prod.prod_id);
 prod_id | prod_name
---------+-----------
       1 | みかん
       2 | りんご
       3 | メロン
(3 rows)
```

### IN演算子
IN演算子は、副問い合わせの結果を主問い合わせのWHERE句の条件に対する値として実行できます。

以下の例では、orders表のqty列の値が5よりも大きい行データのprod_id列の値から、prod表のprod_id列とprod_name列の値を取得しています。
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
       1 | みかん
       3 | メロン
(2 rows)
```

## 日付・時刻型データの取り扱い
日付・時刻型データは数値型や文字列型と異なり、特別な取り扱い方が用意されています。

### 日付形式を確認・設定する
日付の形式は国や環境によって異なります。PostgreSQLがどのような日付形式に設定されているかを確認するには、SHOW DATESTYLEを実行します。

以下の例では、ISO書式でMDY、つまり月日年のスタイルであることが分かります。西暦を2桁で表すとき「01-12-05」は何年の何月何日を表しますか？本例では、それを月-日-年で解釈するよう設定されていましたので「1月―12日―2005年」と扱われています。
```
ossdb=# SHOW DATESTYLE;
 DateStyle
-----------
 ISO, MDY
(1 row)

ossdb=# select '01-12-05'::date;
    date
------------
 2005-01-12
(1 row)
```
なお、DATESTYLEを変更することもできます。日本人にはこちらのほうが馴染みがあるであろう、年―月―日の解釈に変更します。同じ「01-12-05」という文字列は、今度は「2001年―12月―5日」と解釈されました。
```
ossdb=# set DATESTYLE to 'ISO, YMD';
SET
ossdb=# SHOW DATESTYLE;
 DateStyle
-----------
 ISO, YMD
(1 row)

ossdb=# select '01-12-05'::date;
    date
------------
 2001-12-05
(1 row)
```

### 現在時刻を取得する

* now()関数  
now()関数は、現在の日付と時刻を取得する関数です。  
以下の例では、SELECT文で使用していますが、INSERT文やUPDATE文でも使用できます。
```
ossdb=# SELECT now();
              now
 -------------------------------
  2018-01-23 12:34:56.297675+09
 (1 row)
```

* CURRENT_DATE/CURRENT_TIME/CURRENT_TIMESTAMP関数  
CURRENT_xxx関数は、それぞれ現在の日付、時刻、日付と時刻を取得する関数です。
```
ossdb=# SELECT CURRENT_DATE;
 current_date
 --------------
 2018-01-23
 (1 row)
 　
ossdb=# SELECT CURRENT_TIME;
    current_time
 --------------------
 12:34:56.496858+09
 (1 row)
　
ossdb=# SELECT CURRENT_TIMESTAMP;
       current_timestamp
 -------------------------------
 2018-01-23 12:34:56.677673+09
 (1 row)
```

### 文字列の入力値を日付型の列に格納する
上記は日付・時刻データを返す関数の結果として日付・時刻を取得しています。この結果をそのまま日付・時刻型の列に挿入することができます。
```
ossdb=# CREATE TABLE date_sample (ts_test timestamp);
CREATE TABLE
ossdb=# INSERT INTO date_sample VALUES (now());
INSERT 0 1
ossdb=# SELECT * FROM date_sample;
          ts_test
----------------------------
 2018-01-23 12:34:56.907503
(1 row)
```
次は「現在時刻」ではなく、「2018年1月23日」のように文字列として指定された数の並びを日付型の列に格納する方法を紹介します。to_timestamp関数を用います。

#### to_timestamp関数の使い方
```
to_timestamp(’文字列’,'フォーマット')
```
ここで文字列は日付・時刻として解釈可能でなければならず（2018年1月23日、23-JAN-2018など）、その書式をフォーマット部分で指定します。フォーマットとは、文字列中の数字部分が日付・時刻に変換するときに、月・日・時・分・秒のどれを表すか指定するものです。

#### フォーマットの指定
パターン | 説明
--- | ---
YYYY | 西暦4桁
YY | 西暦2桁
MM | 数値で月を表す
MON | 月名の省略形（JAN、FEB・・・など）
MONTH | 月名（JANUARY、FEBRUARY・・・など）
DD | 日付
HH | 12時間表記の時（AM/PMと一緒に指定）
HH24 | 24時間表記の時
MI | 分
SS | 秒
MS | ミリ秒
US | マイクロ病

使い方の例を見てみましょう。日本語の「2018年1月23日」はまさに文字列ですが、その文字列中には日付を表す「2018」「1」「23」が含まれています。この数値が日付のどの桁を表すかフォーマット指定します。
```
ossdb=# INSERT INTO date_sample VALUES (to_timestamp('2018年1月23日','YYYY年MM月DD日'));
INSERT 0 1
ossdb=# SELECT * FROM date_sample;
          ts_test
----------------------------
 2018-01-23 12:34:56.907503
 2018-01-23 00:00:00
(2 rows)
```
次の例では、さらに時・分・秒まで格納しています。「12時」だけではAM/PMが明確ではありませんが、フォーマットでは「HH24」とすることで24時間表記の12時（正午をまわったところ）であることを明示できます。
```
ossdb=# INSERT INTO date_sample
VALUES (to_timestamp('23-JAN-2018 12:34:56','DD-MON-YYYY HH24:MI:SS'));
INSERT 0 1
ossdb=# SELECT * FROM date_sample;
          ts_test
----------------------------
 2018-02-19 02:55:32.907503
 2018-01-23 00:00:00
 2018-01-23 12:34:56
(3 rows)
```
さらに2行のデータを追加します。今度はAM/PMを明記して12時間表記でフォーマットを指定しています。
```
ossdb=# INSERT INTO date_sample
 VALUES (to_timestamp('23-JAN-2018 AM12:34:00','DD-MON-YYYY AMHH:MI:SS')),
        (to_timestamp('23-JAN-2018 PM12:34:00','DD-MON-YYYY AMHH:MI:SS'));
INSERT 0 2
ossdb=# SELECT * FROM date_sample;
          ts_test
----------------------------
 2018-02-19 02:55:32.907503
 2018-01-23 00:00:00
 2018-01-23 12:34:56
 2018-01-23 00:34:00
 2018-01-23 12:34:00
(5 rows)
```

## 複雑な結合
JOIN句による通常の結合の他にも、外部結合や自己結合といった結合が存在します。

### 外部結合
JOIN句による通常の結合（等価結合）では、結合する表の両方に、結合条件に合うような行データが存在しないと検索結果には含まれません。  
以下の例では、customer表に新たな行データを追加し、通常の結合でどの店舗でどの商品がいくつ売れたかを取得しています。しかし、cusotmer表に追加したばかりの藤原流通は、orders表を見ても販売実績がありませんのでこの結果には藤原流通という行がまったく現れません。
```
ossdb=# INSERT INTO customer(customer_id,customer_name) VALUES (4,'藤原流通');
INSERT 0 1
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
           1 | 佐藤商事
           2 | 鈴木物産
           3 | 高橋商店
           4 | 藤原流通
(4 rows)
ossdb=# SELECT c.customer_name,o.prod_id,o.qty
FROM customer c
JOIN orders   o ON c.customer_id = o.customer_id;
 customer_name | prod_id | qty
---------------+---------+-----
 佐藤商事      |       1 |  10
 鈴木物産      |       2 |   5
 高橋商店      |       3 |   8
 鈴木物産      |       1 |   3
 高橋商店      |       2 |   4
(5 rows)
```
外部結合は、片方の表にしか存在しないため結合で消えてしまった行データも検索結果に含むことができる結合方式です。LEFT OUTER JOIN句を使うと、結合の左側に来た表の行データがすべて検索結果に含まれるようになります。  
customer表を左側にしたorders表との左外部結合を行っています。上の例と異なるのは、「JOIN」を「LEFT OUTER JOIN」に変更しただけですが、こうすることでorders表に該当する行が存在しない場合も、customer表に含むデータはもれなく結果に含むようになります。藤原流通という店舗があって検索結果には載っているものの、販売実績が無いことがわかるのです。
```
ossdb=# SELECT c.customer_name,o.prod_id,o.qty
FROM customer c
LEFT OUTER JOIN orders   o ON c.customer_id = o.customer_id;
 customer_name | prod_id | qty
---------------+---------+-----
 佐藤商事      |       1 |  10
 鈴木物産      |       2 |   5
 高橋商店      |       3 |   8
 鈴木物産      |       1 |   3
 高橋商店      |       2 |   4
 藤原流通      |         |
(6 rows)
```
複数表の外部結合も可能です。
以下の例では、さらに別のprod表をLEFT OUTER JOIN句で結合しています。prod_idを商品名に置き換えています。
```
ossdb=# SELECT c.customer_name,p.prod_name,o.qty
FROM customer c
LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
LEFT OUTER JOIN prod   p ON o.prod_id = p.prod_id;
 customer_name | prod_name | qty
---------------+-----------+-----
 鈴木物産      | みかん    |   3
 佐藤商事      | みかん    |  10
 高橋商店      | りんご    |   4
 鈴木物産      | りんご    |   5
 高橋商店      | メロン    |   8
 藤原流通      |           |
(6 rows)
```
状況に応じて、FULL OUTER JOINやRIGHT OUTGER JOINも同じような考え方で使うことができます。

### クロス結合
全ての店舗と商品の組み合わせを取得するような問い合わせでは、結合条件を指定しないクロス結合を使用します。
以下の例では、curotmer表（4行）とprod表（4行）から取得されうる全組み合わせのパターン（4×4=16行）を取得しています。先の外部結合の結果から、「藤原流通で販売されたバナナ」という組み合わせは実際のデータには存在しないことがわかっていますが、クロス結合の場合はすべての可能性のある組み合わせを取得しているのです。
```
ossdb=# SELECT customer_name,prod_name
FROM customer c
CROSS JOIN prod p;
 customer_name | prod_name
---------------+-----------
 佐藤商事      | みかん
 鈴木物産      | みかん
 高橋商店      | みかん
 藤原流通      | みかん
 佐藤商事      | りんご
 鈴木物産      | りんご
 高橋商店      | りんご
 藤原流通      | りんご
 佐藤商事      | メロン
 鈴木物産      | メロン
 高橋商店      | メロン
 藤原流通      | メロン
 佐藤商事      | バナナ
 鈴木物産      | バナナ
 高橋商店      | バナナ
 藤原流通      | バナナ
(16 rows)
```
以下のように、結合にJOIN句を用いず、FROM句の後にカンマ区切りで複数の表を並べることでも同じ結果が得られます。（この場合、結合条件が必要な場合はON句のかわりにWHERE句を用います。）
```
ossdb=# SELECT customer_name,prod_name
FROM customer c, prod p;
 customer_name | prod_name
---------------+-----------
 佐藤商事      | みかん
 鈴木物産      | みかん
 高橋商店      | みかん
　：
```

### 自己結合
自己結合は1つの表を2つの表に見立てて結合する結合方式です。このとき、２つの表として区別するため、表に別名を使う必要があります。

以下の例では、すべての商品の組み合わせのうち、価格の合計が100未満となる組み合わせのみを検索しています。prod表は1つしかありませんが、prod表を別名でp1表とp2表の2つの表に見立てて、p1とp2を単純結合（すべての組み合わせを取り出す結合）し、価格の合計に対してWHERE句の条件で絞り込みを行っています。
```
ossdb=# SELECT p1.prod_name,p2.prod_name,p1.price + p2.price AS pricesum
FROM prod p1,prod p2
WHERE p1.price + p2.price < 100;
 prod_name | prod_name | pricesum
-----------+-----------+----------
 みかん    | バナナ    |       80
 バナナ    | みかん    |       80
 バナナ    | バナナ    |       60
(3 rows)
```
これだけでは少しわかりにくいかもしれませんが、途中経過を実行してみるとよくわかります。prod表には以下のデータが入っています。
```
ossdb=# SELECT prod_name,price FROM prod;
 prod_name | price
-----------+-------
 みかん    |    50
 りんご    |    70
 メロン    |   100
 バナナ    |    30
(4 rows)
```
これを自己結合することで、2つの商品を選ぶ場合の組み合わせを生成します。組み合わせにはクロス結合を使います。
```
ossdb=# SELECT p1.prod_name,p1.price,
               p2.prod_name,p2.price
FROM prod p1,prod p2;
 prod_name | price | prod_name | price
-----------+-------+-----------+-------
 みかん    |    50 | みかん    |    50
 みかん    |    50 | りんご    |    70
 みかん    |    50 | メロン    |   100
 みかん    |    50 | バナナ    |    30
 りんご    |    70 | みかん    |    50
   ：
```
さらにこの結果の右に、行ごとの合計金額を表示してみましょう。
```
ossdb=# SELECT p1.prod_name,p1.price "価格1",
               p2.prod_name,p2.price "価格2",
               p1.price + p2.price   "合計"
FROM prod p1,prod p2;
 prod_name | 価格1 | prod_name | 価格2 | 合計
-----------+-------+-----------+-------+------
 みかん    |    50 | みかん    |    50 |  100
 みかん    |    50 | りんご    |    70 |  120
 みかん    |    50 | メロン    |   100 |  150
 みかん    |    50 | バナナ    |    30 |   80
 りんご    |    70 | みかん    |    50 |  120
   ：
```
この結果に対して、「合計金額が100円未満」というWHERE条件を追加します。
```
ossdb=# SELECT p1.prod_name,p1.price "価格1",
               p2.prod_name,p2.price "価格2",
               p1.price + p2.price   "合計"
FROM prod p1,prod p2
WHERE p1.price + p2.price < 100;
 prod_name | 価格1 | prod_name | 価格2 | 合計
-----------+-------+-----------+-------+------
 みかん    |    50 | バナナ    |    30 |   80
 バナナ    |    30 | みかん    |    50 |   80
 バナナ    |    30 | バナナ    |    30 |   60
(3 rows)
```
あとはSELECTリストに指定するものを必要なものに絞れば元の結果が得られます。

## LIMIT句による検索行数制限
LIMIT句を使うと、検索で取り出す行データの数を制限することができます。通常のSQL文の検索では、条件に当てはまる行データはすべて表示されてしまいますが、LIMIT句を指定すると必要とする行数だけを取り出せます。

### LIMITと並び順の指定
問い合わせの結果は順番が保証されていませんから、確実に指定した行を取り出すには、ORDER BY句を使って行データの並びを指定する必要があります。

以下の例では、orders表から3行だけ行データを取り出しています。順序を確定させるために、order_id列で並べ替えを行っています。
```
ossdb=# SELECT * FROM orders ORDER BY order_id;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2018-01-22 12:34:51.510398 |           1 |       1 |  10
        2 | 2018-01-22 12:34:58.875188 |           2 |       2 |   5
        3 | 2018-01-22 12:35:07.440391 |           3 |       3 |   8
        4 | 2018-01-22 12:35:16.847541 |           2 |       1 |   3
        5 | 2018-01-22 12:35:26.164922 |           3 |       2 |   4
(5 rows)

ossdb=# SELECT * FROM orders ORDER BY order_id LIMIT 3;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        1 | 2018-01-22 12:34:51.510398 |           1 |       1 |  10
        2 | 2018-01-22 12:34:58.875188 |           2 |       2 |   5
        3 | 2018-01-22 12:35:07.440391 |           3 |       3 |   8
(3 rows)
```

### OFFSET句
OFFSET句を組み合わせることで、先頭から不要な行数を飛ばしてから行データを取り出すことができます。

以下の例では、OFFSET句の値として1を与えているので、1行飛ばして2行目から3行の行データを取り出しています。
```
ossdb=# SELECT * FROM orders ORDER BY order_id LIMIT 3 OFFSET 1;
 order_id |         order_date         | customer_id | prod_id | qty
----------+----------------------------+-------------+---------+-----
        2 | 2018-01-22 12:34:58.875188 |           2 |       2 |   5
        3 | 2018-01-22 12:35:07.440391 |           3 |       3 |   8
        4 | 2018-01-22 12:35:16.847541 |           2 |       1 |   3
(3 rows)
```

<!--8/1ここまで-->

\pagebreak
