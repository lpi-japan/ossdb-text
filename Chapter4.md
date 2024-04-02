# 表

## 表の作成（CREATE TABLE）
前の章では例文中で簡単な表を作成し、その表に対してSQL文を実行していました。実際のデータベースでは利用者が目的に応じて表を作成します。表の作成方法を見ていましょう。

### 表を作成する
表の作成は、CREATE TABLE文を使用します。

#### CREATE TABLE文の構文
```
CREATE TABLE 表名
	(列名 データ型 [NULL|NOT NULL]
		| [UNIQUE]
		| [PRIMARY KEY (列名[,...])]
		| [REFERNCES 外部参照表名 (参照列名)]
	[,...])
```

表を作成するには、列の名前と、その列にどのようなデータが入るのかを決めなければいけません。ここでは、以下のような3つの列を持つテーブルを作成します。

#### staff表の定義

|    |列名     |データ型   |
|----|--------|----------|
|社員番号|id      |integer型|
|氏名  |name    |text型   |
|誕生日 |birthday|date型   |

これをSQL文にすると、以下のようになります。作成ができたら、表の一覧に入っていることと、表の定義を確認しておきましょう。
```
ossdb=# CREATE TABLE staff
                    (id       integer,
                     name     text,
                     birthday date);
CREATE TABLE

ossdb=# \d
            List of relations
 Schema |     Name     | Type  |  Owner
--------+--------------+-------+----------
 public | char_test    | table | postgres
 public | customer     | table | postgres
 public | date_test    | table | postgres
 public | numeric_test | table | postgres
 public | orders       | table | postgres
 public | prod         | table | postgres
 public | staff        | table | postgres
 public | varchar_test | table | postgres
(8 rows)

ossdb=# \d staff
                Table "public.staff"
  Column  |  Type   | Collation | Nullable | Default
----------+---------+-----------+----------+---------
 id       | integer |           |          |
 name     | text    |           |          |
 birthday | date    |           |          |
```

### staff表にデータを格納する
INSERT文を使ってstaff表にデータを格納してみましょう。
```
ossdb=# INSERT INTO staff (id,name,birthday) VALUES (1,'宮原徹','1972-01-09');
INSERT 0 1
ossdb=# SELECT * FROM staff;
 id |  name  |  birthday
----+--------+------------
  1 | 宮原徹 | 1972-01-09
(1 row)
```

## 表定義の修正（ALTER TABLE）
表を作成した後で表定義を修正するにはALTER TABLE文を使用します。

### ALTER TABLEによる変更
ALTER TABLE文では表そのものの定義や動作の修正に加え、表内の列定義の修正も可能で、その分指定の方法が複雑になっています。

メタコマンド\\hで構文のヘルプを確認してみましょう。ここでは詳細を覚える必要はありませんが、変更対象の表を指定し、さらに「新しい列を追加する（=ADD COLUMN）」のようなactionを指定することをヘルプから読み取ってみてください。
```
ossdb=# \h ALTER TABLE
Command:     ALTER TABLE
Description: change the definition of a table
Syntax:
ALTER TABLE [ IF EXISTS ] [ ONLY ] name [ * ]
    action [, ... ]

（略）

where action is one of:

    ADD [ COLUMN ] [ IF NOT EXISTS ] column_name data_type [ COLLATE collation ] [ column_constraint [ ... ] ]
    DROP [ COLUMN ] [ IF EXISTS ] column_name [ RESTRICT | CASCADE ]
    ALTER [ COLUMN ] column_name [ SET DATA ] TYPE data_type [ COLLATE collation ] [ USING expression ]

（略）    
```

ここでは新たに列を追加するALTER TABLE文を試してみましょう。staff表に所属部署コードを表すdept_cd列を追加し、その列にUPDATE文で値を格納しています。
```
ossdb=# ALTER TABLE staff ADD COLUMN dept_cd integer;
ALTER TABLE
ossdb=# \d staff
                Table "public.staff"
  Column  |  Type   | Collation | Nullable | Default
----------+---------+-----------+----------+---------
 id       | integer |           |          |
 name     | text    |           |          |
 birthday | date    |           |          |
 dept_cd  | integer |           |          |

 ossdb=# UPDATE staff SET dept_cd = 1 WHERE id = 1;
 UPDATE 1
 ossdb=# SELECT * FROM staff;
  id |  name  |  birthday  | dept_cd
 ----+--------+------------+---------
   1 | 宮原徹 | 1972-01-09 |       1
 (1 row)
```

### 表定義の修正は原則として行わない
ALTER TABLE文で修正できる内容は様々ですが、すでにデータが格納されている状態で安易に列の定義を修正することは望ましくありません。少なくとも以下のような設計の面や、作業による影響を考慮して実施方法を検討しましょう。

* 正しい設計になっているか  
例えば、上記ではstaff表にdept_cd列を追加しましたが、所属部門をstaff表で管理することは理想的な対応だったでしょうか。SELECT * FROM staff;とすれば所属情報込みでスタッフを一覧表示できることは確かに便利かもしれません。しかし、1名のスタッフが複数部門に所属するケースは起こりえないでしょうか。  
このような場合は、新たに所属部門表を作成し「01番のスタッフはAという組織に所属する」という事実を表すようにします。「01番のスタッフは同時にCという組織に所属する」場合はもう一行追加すればよいのです。

#### 所属部門表の例
スタッフID | 部門コード | 意味
--- | --- | ---
01 | A | スタッフ01はAという組織に所属
02 | B | スタッフ02はBという組織に所属
03 | C | スタッフ03はCという組織に所属
01 | C | スタッフ01はCという組織に所属（同時にAとCに所属していることがわかる）


![ALTER TABLEは行うべきか](./Pict/alter-01.png)

* 表定義の変更作業そのものがどんな影響を及ぼすか  
仮に、スタッフ一覧に部門コードを持つことが適切であったとして、変更作業そのものがシステム全体に悪影響を及ぼす可能性があります。  
小規模なスタッフ表であれば問題は少ないかもしれませんが、数百万人のデータを収めたウェブサービスの会員表である場合はどうでしょうか。利用者がログインするたびに参照されているような場合、表の変更作業中は誰もログインできなくなり社会的影響にまで及ぶことを考慮します。（これは極端な例で、実際のデータベース製品の実装では変更中の参照は許されていることが多いです。しかし、データの更新などはブロックされてしまいますので無視できるものではありません。）  
この場合もやはり上記のような所属部門表を新規に作成することで、利用者の操作を妨げることなく必要なデータは保持することができます。

* 短期の対策と中長期の対策  
さしあたって必要なデータを格納するために、新規に所属部門表を作成したとします。しかし、やはり設計上はスタッフ一覧に部門コードを持つことが最適という場合もあるでしょう。  
大規模メンテナンスのためのサービス休止期間を利用者にアナウンスし、理想的な表に変更することは長期的な対策としては有用です。

ある操作が他のSQLやプログラムにどのような影響を与えるかは、いかなる操作であっても考慮が必要です。その中でも特に表のメンテナンスは影響範囲が大きくなりやすいですので十分に注意しましょう。

## 表の削除

### DROP TABLE文による表の削除
表を削除するには、DROP TABLE文を使用します。
表を削除すると、表に格納されているデータも一緒に削除されて元に戻すことができません。
```
ossdb=# \d
            List of relations
 Schema |     Name     | Type  |  Owner
--------+--------------+-------+----------
 public | char_test    | table | postgres
 public | customer     | table | postgres
 public | date_test    | table | postgres
 public | numeric_test | table | postgres
 public | orders       | table | postgres
 public | prod         | table | postgres
 public | staff        | table | postgres
 public | varchar_test | table | postgres
(8 rows)

ossdb=# DROP TABLE staff;
DROP TABLE
ossdb=# \d
            List of relations
 Schema |     Name     | Type  |  Owner
--------+--------------+-------+----------
 public | char_test    | table | postgres
 public | customer     | table | postgres
 public | date_test    | table | postgres
 public | numeric_test | table | postgres
 public | orders       | table | postgres
 public | prod         | table | postgres
 public | varchar_test | table | postgres
(7 rows)
```

### DROP TABLE、DELETE、TRUNCATEの利用
データを削除する操作には、表を定義ごと削除するDROP TABLEの他にも、WHERE条件に該当した行だけを削除するDELETE、表のデータのみ全件削除するTRUNCATEがあります。
条件に該当する特定の行のデータだけを削除したい場合にはDELETE文を使用しますが、DELETE文でのデータ削除は対象となるデータの件数が多いと時間がかかることがあります。例えば時系列に沿って蓄積されるデータのうち、保管期限を過ぎたものを一括削除するようなケースでは、表を月別などに分割しておき、月単位でTRAUNCATEすることも考えます。

DROP TABLE文は表と表データだけでなく、関連する索引やビューなど、その他のものも併せて削除してしまうため、再作成する場合はこれらも再定義する必要に時間がかかるなどの問題が発生することがあります。行データだけを一括で削除する場合にはTRUNCATE文を使用します。

#### TRUNCATE文の構文
```
TRAUNCATE 表名
```

以下の例では、char_test表のすべての行データをすべてTRUNCATE文で削除しています。
```
ossdb=# SELECT * FROM char_test;
 string
--------
 あ
 ABC
 あいう
(3 rows)

ossdb=# TRUNCATE char_test;
TRUNCATE TABLE
ossdb=# SELECT * FROM char_test;
 string
--------
(0 rows)
```

## 行データのセーブ・ロード
COPY文を使用すると、行データをファイルにセーブしたり、ファイルからロードすることができます。
FORMAT句でcsvを指定することで、CSV形式のファイルをセーブ、ロードができます。

注意： COPYはDBサーバー上のファイルに直接データを書き出す操作で、PostgreSQLのスーパーユーザーでのみ実行することができます。似た操作ではクライアント端末側にデータを出力するpsqlメタコマンド\copyや、バックアップの章で解説するpg_dumpなどが利用できますので、目的に応じて使い分けるようにしてください。


### 行データのセーブ
COPY TO文で行データをファイルにセーブできます。

#### COPY文によるデータのセーブ
```
COPY 表名 TO ファイル (FORMAT 形式)
```

以下の例は、customer表のデータをCSV形式でファイルにセーブしています。
\!メタコマンドはLinuxのシェルコマンドを実行しています。
```
ossdb=# COPY customer TO '/home/postgres/customer.csv' (FORMAT csv);
COPY 3
ossdb=# \! ls /home/postgres
customer.csv
ossdb=# \! cat /home/postgres/customer.csv
1,佐藤商事
2,鈴木物産
3,高橋商店
```

### CSVファイルのロード
COPY FROM文でファイルから行データをロードできます。

#### COPY文によるデータのロード
```
COPY 表名 FROM ファイル (FORMAT 形式)
```

以下の例は、customer表のデータをCSV形式のファイルからロードしています。
```
ossdb=# DELETE FROM customer;
DELETE 3
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
(0 rows)

ossdb=# COPY customer FROM '/home/postgres/customer.csv' (FORMAT csv);
COPY 3
ossdb=# SELECT * FROM customer;
 customer_id | customer_name
-------------+---------------
           1 | 佐藤商事
           2 | 鈴木物産
           3 | 高橋商店
(3 rows)
```

### \\copyメタコマンド
psqlはCOPY文と同様の動作をする\copyメタコマンドが使用できます。異なるのは以下の点です。

* COPY文はSQLであり、DBサーバーが実行する。出力ファイルはDBサーバー内に作成される。
* psqlメタコマンド\copyはクライアントからのデータ取得操作であり、出力ファイルはクライアント端末内に作成される。
* ファイル指定が絶対指定のほか、psql実行時のクライアント端末のカレントディレクトリからの相対指定でも可能
* 形式の指定がwith csv

具体的な使用例はこの後の演習で解説します。

\pagebreak
