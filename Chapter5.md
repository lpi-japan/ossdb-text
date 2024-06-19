# 基礎編 演習
これまでの章で、SQLを使ったデータベースの基礎について学びました。

2つの演習問題で、学習した内容を確認してみましょう。

## 演習1：データ操作 {.unnumbered}

以下の操作をSQLで行ってみましょう。

1. prod表のすべての商品の価格を10%アップします
2. prod表の価格が100以上の商品の価格を元に戻します
3. prod表のデータをファイルにセーブします
4. prod表を削除します
5. prod表を再度作成します
6. prod表にデータをファイルからロードします

表の定義はあらかじめ確認しておきましょう。また、第1章の表を作成するためのCREATE TABLE文の例も参考にしてください。

### 演習1-1： prod表のすべての商品の価格を10%アップします {.unnumbered}
prod表のprice列を指定してUPDATEを実行する。

```
ossdb=# \d prod
                    テーブル"public.prod"
    列     | タイプ  | 照合順序 | Null 値を許容 | デフォルト
-----------+---------+----------+---------------+------------
 prod_id   | integer |          |               |
 prod_name | text    |          |               |
 price     | integer |          |               |

ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    50
       2 | りんご    |    70
       3 | メロン    |   100
       4 | バナナ    |    31
(4 行)

ossdb=# UPDATE prod SET price = price * 1.1;
UPDATE 4
ossdb=# SELECT * FROM prod;
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    55
       2 | りんご    |    77
       3 | メロン    |   110
       4 | バナナ    |    34
(4 行)
```

### 演習1-2： prod表の価格が100以上の商品の価格を元に戻します {.unnumbered}
price表のpriceの値が100以上の商品を指定してUPDATEを実行する。

```
ossdb=# UPDATE prod SET price = price/1.1 WHERE price >= 100;
UPDATE 1
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    55
       2 | りんご    |    77
       4 | バナナ    |    34
       3 | メロン    |   100
(4 行)
```

### 演習1-3： prod表のデータをファイルにセーブします {.unnumbered}
COPY TO文でデータをファイルにセーブします。

```
ossdb=# COPY prod TO '/tmp/prod.csv' (FORMAT csv);
COPY 4
ossdb=# \\! cat /tmp/prod.csv
1,みかん,55
2,りんご,77
4,バナナ,34
3,メロン,100
```

### 演習1-4： prod表を削除します {.unnumbered}
DROP TABLE文でprod表を削除します。

```
ossdb=# DROP TABLE prod;
DROP TABLE
ossdb=# SELECT * FROM prod;
ERROR:  リレーション"prod"は存在しません
行 1: SELECT * FROM prod;
                    ^
```

### 演習1-5： prod表を再度作成します {.unnumbered}
表の作成時は列ごとに格納するデータに合わせた型を指定します。IDのような整数にはinteger型、文字にはtext型、計算に用いる数値はnumeric型を指定します。

```
ossdb=# CREATE TABLE prod ( prod_id     integer,
                            prod_name   text,
                            price       numeric );
CREATE TABLE
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
(0 行)
```

### 演習1-6： prod表にデータをファイルからロードします {.unnumbered}
COPY FROM文を使用してデータをファイルからロードします。
```
ossdb=# COPY prod FROM '/tmp/prod.csv' (FORMAT csv);
COPY 4
ossdb=# SELECT * FROM prod;
 prod_id | prod_name | price
---------+-----------+-------
       1 | みかん    |    55
       2 | りんご    |    77
       4 | バナナ    |    34
       3 | メロン    |   100
(4 行)
```

## 演習2：郵便番号データベース {.unnumbered}
郵便番号データベースを設計してみましょう。

郵便番号のデータはCSV形式で公開されています。この郵便番号データを格納するデータベースを設計し、実際にデータを格納してみましょう。

### 演習2-1： 郵便番号データのダウンロード {.unnumbered}
郵便番号データは以下のWebページからダウンロードできます。

```
https://www.post.japanpost.jp/zipcode/download.html
```

データは様々な形式のものが配布されています。「住所の郵便番号（1レコード1行、UTF-8形式）（CSV形式）」にある「住所の郵便番号（1レコード1行、UTF-8形式）」のリンクをクリックします。

「データのダウンロード」にある「最新データのダウンロード」のリンクから、ZIP形式でアーカイブされたCSVファイルがダウンロードできます。ダウンロードはサーバーで行うか、ダウンロードしたファイルをサーバーにコピーする必要があります。

```
https://www.post.japanpost.jp/zipcode/dl/utf/zip/utf_ken_all.zip
```

以下の例は、サーバーでwgetコマンドを使って郵便番号CSVデータをダウンロードして、unzipコマンドで解凍しています。

```
[postgres@host1 ~]$ wget https://www.post.japanpost.jp/zipcode/dl/utf/zip/utf_ken_all.zip
--2024-04-10 15:23:02--  https://www.post.japanpost.jp/zipcode/dl/utf/zip/utf_ken_all.zip
www.post.japanpost.jp (www.post.japanpost.jp) をDNSに問いあわせています... 43.253.212.144
www.post.japanpost.jp (www.post.japanpost.jp)|43.253.212.144|:443 に接続しています... 接続しました。
HTTP による接続要求を送信しました、応答を待っています... 200 OK
長さ: 2183402 (2.1M) [application/zip]
`utf_ken_all.zip' に保存中

utf_ken_all.zip     100%[===================>]   2.08M  9.69MB/s 時間 0.2s

2024-04-10 15:23:02 (9.69 MB/s) - `utf_ken_all.zip' へ保存完了 [2183402/2183402]

[postgres@host1 ~]$ ls
utf_ken_all.zip
[postgres@host1 ~]$ unzip utf_ken_all.zip
Archive:  utf_ken_all.zip
  inflating: utf_ken_all.csv
[postgres@host1 ~]$ ls -l utf_ken_all.csv
-rw-r--r--. 1 postgres postgres 18335216  3月 22 10:40 utf_ken_all.csv
```

### 演習2-2： 郵便番号データベース表の作成 {.unnumbered}
郵便番号データを格納するための表をデータベースに作成します。

郵便番号データのデータ項目は以下の通りです。

| 内容 |備考 |
|---|---|
| 全国地方公共団体コード(JIS X0401、X0402)| 半角数字 |
| (旧)郵便番号(5桁) | 半角数字 |
| 郵便番号(7桁) | 半角数字 |
| 都道府県名 | 半角カタカナ(コード順に掲載) |
| 市区町村名 | 半角カタカナ(コード順に掲載) |
| 町域名 | 半角カタカナ(五十音順に掲載) |
| 都道府県名 | 漢字(コード順に掲載) |
| 市区町村名 | 漢字(コード順に掲載) |
| 町域名 | 漢字(五十音順に掲載) |
| 一町域が二以上の郵便番号で表される場合の表示 | |
| 小字毎に番地が起番されている町域の表示 | |
| 丁目を有する町域の場合の表示 | |
| 一つの郵便番号で二以上の町域を表す場合の表示 | |
| 更新の表示 | |
| 変更理由 | |

このデータ項目に基づいて、表を作成します。

以下の例は、固定長の文字列データをchar型、固定長ではない文字列データをtext型で定義した、表作成のためのCREATE TABLE文です。

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

### 演習2-3： 郵便番号データの内容確認 {.unnumbered}
データは以下のような内容です。

```
[postgres@host1 ~]$ head -5 utf_ken_all.csv
01101,"060  ","0600000","ホッカイドウ","サッポロシチュウオウク",
"イカニケイサイガナイバアイ","北海道","札幌市中央区","以下に掲載がない場合",0,0,0,0,0,0
01101,"064  ","0640941","ホッカイドウ","サッポロシチュウオウク","アサヒガオカ","北海道","札幌市中央区","旭ケ丘",0,0,1,0,0,0
01101,"060  ","0600041","ホッカイドウ","サッポロシチュウオウク","オオドオリヒガシ","北海道","札幌市中央区","大通東",0,0,1,0,0,0
01101,"060  ","0600042","ホッカイドウ","サッポロシチュウオウク","オオドオリニシ（１−１９チョウメ）","北海道","札幌市中央区","大通西（１〜１９丁目）",1,0,1,0,0,0
01101,"064  ","0640820","ホッカイドウ","サッポロシチュウオウク","オオドオリニシ（２０−２８チョウメ）","北海道","札幌市中央区","大通西（２０〜２８丁目）",1,0,1,0,0,0
```

### 演習2-4： データのロード {.unnumbered}
psqlを使って、CSVファイルをロードします。

以下の例では、\\copyメタコマンドを使ってCSVファイルからデータをロードしています。

```
ossdb=# \copy zip from utf_ken_all.csv with csv
COPY 124370
```

### 演習2-5： 郵便番号データの確認 {.unnumbered}
ロードされた郵便番号データを確認します。

以下の例では、現在使用されている郵便番号のデータが格納されているnewzip列で絞り込み検索を行っています。

```
ossdb=# SELECT * FROM zip WHERE newzip = '1500002';
 lgcode | oldzip | newzip  |   prefkana   | citykana |           areakana           |  pref  |  city  |          area          | largearea | koaza | choume | smallarea | change | reason
--------+--------+---------+--------------+----------+------------------------------+--------+--------+------------------------+-----------+-------+--------+-----------+--------+--------
 13113  | 150    | 1500002 | トウキョウト | シブヤク | シブヤ（ツギノビルヲノゾク） | 東京都 | 渋谷区 | 渋谷（次のビルを除く） |         0 |     0 |      1 |         0 |      0 |      0
(1 行)
```

\pagebreak
