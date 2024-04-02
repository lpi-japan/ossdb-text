# 基礎編 演習
これまでの章で、SQLを使ったデータベースの基礎について学びました。2つの演習問題で、学習した内容を確認してみましょう。

## 演習1：データ操作

### データ操作演習

1. すべての商品の価格を10%アップします
2. 価格が100以上の商品の価格を元に戻します
3. prod表のデータをファイルにコピーします
4. prod表を削除します
5. prod表を再度作成します
6. データをファイルからコピーします

表の定義はあらかじめ確認しておきましょう。また、巻末の付録にも表を作成するためのCREATE TABLE 文の例がありますので、参考にしてください。

### 解答例

* 演習1-1： すべての商品の価格を10%アップします  
 * 商品表の価格列を指定してUPDATE  
``` {.haskell}
ossdb=# \d prod
                 Table "public.prod"
  Column   |  Type   | Collation | Nullable | Default
-----------+---------+-----------+----------+---------
 prod_id   | integer |           |          |
 prod_name | text    |           |          |
 price     | integer |           |          |
　
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    50
       2 | りんご    |    70
       3 | メロン    |   100
       4 | バナナ    |    31
(4 rows)
ossdb=# UPDATE prod SET price = price * 1.1;
UPDATE 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    55
       2 | りんご    |    77
       3 | メロン    |   110
       4 | バナナ    |    34
(4 rows)
```

* 演習1-2： 価格が100以上の商品の価格を元に戻します  
 * 価格が100以上の商品を指定してUPDATE  
``` {.haskell}
ossdb=# UPDATE prod SET price = price/1.1 WHERE price >= 100;
UPDATE 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    55
       2 | りんご    |    77
       4 | バナナ    |    34
       3 | メロン    |   100
(4 rows)
```

* 演習1-3： prod表のデータをファイルにコピーします  
 * COPYコマンドでデータをファイルにセーブ  
``` {.haskell}
ossdb=# COPY prod TO '/home/postgres/prod.csv' (FORMAT csv);
COPY 4
ossdb=# \! ls -l prod.csv
-rw-r--r--. 1 postgres postgres 61  1月 29 02:01 prod.csv
```

* 演習1-4： prod表を削除します  
 * 表の削除にはDROP TABLEを使用  
``` {.haskell}
ossdb=# DROP TABLE prod;
DROP TABLE
```

* 演習1-5： 表を再度作成します  
 * 表の作成時は列ごとに格納するデータに合わせた型を指定する  
 * IDのような整数にはinteger型、文字にはtext型、計算に用いる数値はnumeric型  
``` {.haskell}
ossdb=# CREATE TABLE prod ( prod_id     integer,
                            prod_name   text,
                            price       numeric  );
CREATE TABLE
```

* 演習1-6： データをファイルからコピーします  
 * セーブ時と同様、COPYコマンドを使用  
``` {.haskell}
ossdb=# COPY prod FROM '/home/postgres/prod.csv' (FORMAT csv);
COPY 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    55
       2 | りんご    |    77
       4 | バナナ    |    34
       3 | メロン    |   100
(4 rows)
```

## 演習2：郵便番号データベース
郵便番号データベースを設計してみましょう。
郵便番号のデータはCSV形式で公開されています。この郵便番号データを格納するデータベースを設計し、実際にデータを格納してみましょう。

### 郵便番号データのダウンロード
郵便番号データは以下のWebページからダウンロードできます。

* 郵便番号データダウンロード Webページの利用  
データはZIP形式で配布されています。「住所の郵便番号（CSV形式）」-「読み仮名データの促音・拗音を小書きで表記するもの」をクリックしてZIP形式でダウンロードしてください。ここでは「全国一括」のデータを用います。
 * [http://www.post.japanpost.jp/zipcode/download.html](http://www.post.japanpost.jp/zipcode/download.html)


* 郵便番号データのダウンロード  
以下の例は、wgetコマンドを使って郵便番号CSVデータをダウンロードして、unzipコマンドで解凍しています。
``` {.haskell}
[postgres@localhost ~]$ wget http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
--2018-01-29 01:14:02--  http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip
www.post.japanpost.jp (www.post.japanpost.jp) をDNSに問いあわせています... 43.253.37.203
www.post.japanpost.jp (www.post.japanpost.jp)|43.253.37.203|:80 に接続しています... 接続しました。
HTTP による接続要求を送信しました、応答を待っています... 200 OK
長さ: 1686409 (1.6M) [application/zip]
`ken_all.zip' に保存中
　
100%[===============================================================================>] 1,686,409   10.4MB/s 時間 0.2s
　
2018-01-29 01:14:02 (10.4 MB/s) - `ken_all.zip' へ保存完了 [1686409/1686409]
　
[postgres@localhost ~]$ ls
customer.csv  ken_all.zip  test.sql
[postgres@localhost ~]$ unzip ken_all.zip
Archive:  ken_all.zip
  inflating: KEN_ALL.CSV
[postgres@localhost ~]$ ls -l KEN_ALL.CSV
-rw-rw-r--. 1 postgres postgres 12288638 12月 22 14:22 KEN_ALL.CSV
```

### 郵便番号データベース表の作成
郵便番号データを格納するための表をデータベースに作成します。

* 郵便番号データ項目  
データの項目は以下の通りです。

|内容                          |備考             |
|----------------------------|---------------|
|全国地方公共団体コード(JIS X0401、X0402)|半角数字           |
|(旧)郵便番号(5桁)                 |半角数字           |
|郵便番号(7桁)                    |半角数字           |
|都道府県名                       |半角カタカナ(コード順に掲載)|
|市区町村名                       |半角カタカナ(コード順に掲載)|
|町域名                         |半角カタカナ(五十音順に掲載)|
|都道府県名                       |漢字(コード順に掲載)    |
|市区町村名                       |漢字(コード順に掲載)    |
|町域名                         |漢字(五十音順に掲載)    |
|一町域が二以上の郵便番号で表される場合の表示      |               |
|小字毎に番地が起番されている町域の表示         |               |
|丁目を有する町域の場合の表示              |               |
|一つの郵便番号で二以上の町域を表す場合の表示      |               |
|更新の表示                       |               |
|変更理由                        | 　 |

* 郵便番号データ用の表定義  
以下の例は、文字列データをchar型およびtext型で定義した表作成のためのCREATE TABLE文です。
``` {.haskell}
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
                          reason    integer
                          );
CREATE TABLE
```

* 郵便番号データサンプル  
データは以下のような内容です。
``` {.haskell}
[postgres@localhost ~]$ head -5 KEN_ALL_UTF8.CSV
01101,"060  ","0600000","ホツカイドウ","サツポロシチユウオウク","イカニケイサイガナイバアイ","北海道","札幌市中央区","以下に掲載がない場合",0,0,0,0,0,0
01101,"064  ","0640941","ホツカイドウ","サツポロシチユウオウク","アサヒガオカ","北海道","札幌市中央区","旭ケ丘",0,0,1,0,0,0
01101,"060  ","0600041","ホツカイドウ","サツポロシチユウオウク","オオドオリヒガシ","北海道","札幌市中央区","大通東",0,0,1,0,0,0
01101,"060  ","0600042","ホツカイドウ","サツポロシチユウオウク","オオドオリニシ(1-19チヨウメ)","北海道","札幌市中央区","大通西（１～１９丁目）",1,0,1,0,0,0
01101,"064  ","0640820","ホツカイドウ","サツポロシチユウオウク","オオドオリニシ(20-28チヨウメ)","北海道","札幌市中央区","大通西（２０～２８丁目）",1,0,1,0,0,0
```

### データのロードと文字コードについて
ダウンロードできるCSVデータは、日本語部分がシフトJISで作成されています。一方、現在使用しているデータベースは日本語をUTF-8で格納するようにしているため、文字コードをUTF-8に揃える必要があります。

シフトJISのデータをUTF-8に変換するには、psqlで`\encoding`メタコマンドを使用する方法と、Linuxのコマンドで文字コード変換をする方法があります。

* psqlメタコマンドを使用する方法  
`\encoding`メタコマンドを使用すると、psqlが扱うデータの文字コードを変更できます。  
以下の例は、`\encoding`メタコマンドでpsqlが扱うデータの文字コードをシフトJISに変更しています。データベースはUTF-8で格納するので、シフトJISからUTF-8への文字コード変換が行われます。
``` {.haskell}
ossdb=# \encoding SJIS
ossdb=# \copy zip from KEN_ALL.CSV with csv
COPY 124165
ossdb=# \encoding UTF-8
```

* Linuxのコマンドを使用する方法  
Linuxであれば`nkf`コマンドで文字コード変換が行えます。他に`iconv`コマンドも使用できますが、改行コードを別途`dos2unix`コマンドで変換する必要があります。Linux環境によってはnkfコマンドがインストールされていない場合がありますので、その場合にはyumコマンドでインストールしてください。
 * nkfコマンドで郵便番号データをUTF-8に変換
``` {.haskell}
[postgres@localhost ~]$ nkf -w KEN_ALL.CSV > KEN_ALL_UTF8.CSV
```
 * iconvコマンドとdos2unixコマンドで郵便番号データをUTF-8に変換
``` {.haskell}
[postgres@localhost ~]$ iconv -f SHIFT-JIS -t UTF-8 KEN_ALL.CSV | dos2unix > KEN_ALL_UTF8.CSV
```
 * 変換後、psqlから`\copy`メタコマンドでロードします。
``` {.haskell}
ossdb=# \copy zip from KEN_ALL_UTF8.CSV with csv
```

### 郵便番号データの確認
ロードされた郵便番号データを確認します。

以下の例では、現在使用されている郵便番号のデータが格納されているnewzip列で絞り込み検索を行っています。

``` {.haskell}
ossdb=# SELECT * FROM zip WHERE newzip = '1500002';
 lgcode | oldzip | newzip  | prefkana | citykana | areakana |  pref  |  city  | area | largearea | koaza | choume | smallarea | change | reason
--------+--------+---------+----------+----------+----------+--------+--------+------+-----------+-------+--------+-----------+--------+--------
 13113  | 150    | 1500002 | ﾄｳｷｮｳﾄ   | ｼﾌﾞﾔｸ    | ｼﾌﾞﾔ     | 東京都 | 渋谷区 | 渋谷 |         0 |     0 |      1 |         0 |      0 |      0
(1 row)
```

\pagebreak
