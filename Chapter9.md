# パフォーマンスチューニング
データベースの性能を高めるためには、様々な性能向上のための仕組みやパフォーマンスチューニングの方法について理解しておく必要があります。この章ではパフォーマンスチューニングについて解説します。

## インデックス（索引）
インデックスは、検索の際に目的となる行データを素早く見つけるための仕組みです。その名の通り、本の索引のようにデータがどこにあるかを直接指し示してくれます。

インデックスが無いと、検索する度に表全体を検索する必要があります。行データが多いと検索対象のデータが増えるため、性能が大幅に劣化して遅くなります。このように表全体を検索することを「シーケンシャルスキャン」や「フルスキャン」、インデックスから検索することを「インデックススキャン」と呼びます。

### 主キーのインデックス
インデックススキャンが意図したとおりに行なわれるよう設計し、インデックスを作成しなければなりません。正しく正規化された表でインデックスが最も有効に働くのは、主キーに対して作成したインデックスです。主キーは検索の条件検索や表の結合などで検索されることが多いので、インデックスを作成しておくとインデックススキャンで高速に必要な行データを見つけ出すことができます。

以下の例のように、主キーを定義していると自動的にインデックスが作成されます。

```
ossdb=# \d prod
                    テーブル"public.prod"
    列     | タイプ  | 照合順序 | Null 値を許容 | デフォルト
-----------+---------+----------+---------------+------------
 prod_id   | integer |          | not null      |
 prod_name | text    |          |               |
 price     | integer |          |               |
インデックス:
    "prod_pkey" PRIMARY KEY, btree (prod_id)
参照元:
    TABLE "orders" CONSTRAINT "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

### インデックスの作成
手動でインデックスを作成するには、CREATE INDEX文を使用します。

インデックスの作成の構文は以下の通りです。

```
CREATE INDEX インデックス名 ON 表名(列名[,...]);
```

インデックスを作成したい表の列を指定します。列は1列でも良いですし、複数列を指定することもできます。複数列を指定したインデックスを「複合インデックス」と呼びます。複合インデックスは指定された列の一部だけを検索条件にすると有効にならない場合もあるので、検索時のSQL文がどのような検索条件となるかを考慮して作成する必要があります。

以下の例では、orders表のcustomer_id列にインデックスを作成しています。

```
ossdb=# CREATE INDEX orders_customer_id_idx
ON orders(customer_id);
CREATE INDEX
ossdb=# \d orders
                              テーブル"public.orders"
     列      |           タイプ            | 照合順序 | Null 値を許容 | デフォルト
-------------+-----------------------------+----------+---------------+------------
 order_id    | integer                     |          | not null      |
 order_date  | timestamp without time zone |          |               |
 customer_id | integer                     |          |               |
 prod_id     | integer                     |          |               |
 qty         | integer                     |          |               |
インデックス:
    "orders_pkey" PRIMARY KEY, btree (order_id)
    "orders_customer_id_idx" btree (customer_id)
外部キー制約:
    "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

### インデックスを削除する
インデックスを削除するにはDROP INDEX文を使用します。

インデックスの削除の構文は以下の通りです。

```
DROP INDEX インデックス名;
```

以下の例では、orders_customer_id_idxインデックスを削除しています。

```
ossdb=# DROP INDEX orders_customer_id_idx;
DROP INDEX
ossdb=# \d orders
                              テーブル"public.orders"
     列      |           タイプ            | 照合順序 | Null 値を許容 | デフォルト
-------------+-----------------------------+----------+---------------+------------
 order_id    | integer                     |          | not null      |
 order_date  | timestamp without time zone |          |               |
 customer_id | integer                     |          |               |
 prod_id     | integer                     |          |               |
 qty         | integer                     |          |               |
インデックス:
    "orders_pkey" PRIMARY KEY, btree (order_id)
外部キー制約:
    "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

### インデックスは万能ではない
インデックスは検索を高速化する手段ですが、万能ではありません。

まず、インデックスの対象となる列の値が頻繁に書き換わる場合、インデックスも頻繁に更新する必要があります。行データが増えればそれだけインデックス更新の負荷も高くなるため、あまり書き換わることのない列の方がインデックスに向いているということになります。

また、列の値が適度にばらついていないと、インデックススキャンよりもシーケンシャルスキャンの方が効率が良い場合があります。

インデックスが有効に働いているかどうかは、次に説明するSQL実行プランの分析などを行って確認する必要があるでしょう。

## SQL実行プランの分析
SQLが実際にどのようにデータベース内部で実行されているかを確認するには、SQL実行プランを分析します。分析を行うには、分析したいSQL文の前にEXPLAIN文をつけて実行します。

### インデックスが存在しない場合のSQL実行プラン
インデックスが存在しない表に対する検索は、フルスキャンになることが分かります。

以下の例では、郵便番号データベースの検索を行うSELECT文を分析しています。インデックスは存在しないのでシーケンシャルスキャン（Seq Scan）になっています。

```
ossdb=# EXPLAIN SELECT * FROM zip WHERE newzip = '1500002';
                       QUERY PLAN
--------------------------------------------------------
 Seq Scan on zip  (cost=0.00..4226.62 rows=1 width=140)
   Filter: (newzip = '1500002'::bpchar)
(2 行)
```

### インデックスが存在する場合のSQL実行プラン
インデックスが存在していて、インデックスを利用した方が良いと判断される場合には、インデックススキャンが行われることが分かります。

```
ossdb=# CREATE INDEX zip_newzip_idx ON zip(newzip);
CREATE INDEX
ossdb=# EXPLAIN SELECT * FROM zip WHERE newzip = '1500002';
                                 QUERY PLAN
----------------------------------------------------------------------------
 Index Scan using zip_newzip_idx on zip  (cost=0.42..8.44 rows=1 width=140)
   Index Cond: (newzip = '1500002'::bpchar)
(2 行)
```

### インデックスが存在しても必ず使われるわけではない
インデックスが存在していても、検索条件によってはインデックスを使う必要は無いと判断されます。

以下の例では、zip表のlargearea列にインデックスを作成していますが、largearea列は0か1といずれかの値しか持たない列のため、必ずインデックスが使われるとは限らなくなっています。最後に0、1それぞれ何件格納されているかをcount関数を使って調べています。largearea列の値はほとんどが0のため、インデックスを利用しても性能が出ないと判断してフルスキャンを選択しています。また、largearea列の値が1の行データは比較的少ないため、インデックススキャンが選択されています。

```
ossdb=# CREATE INDEX zip_largearea ON zip(largearea);
CREATE INDEX
ossdb=# EXPLAIN SELECT * FROM zip WHERE largearea = 0;
                         QUERY PLAN
-------------------------------------------------------------
 Seq Scan on zip  (cost=0.00..4226.62 rows=121597 width=140)
   Filter: (largearea = 0)
(2 行)

ossdb=# EXPLAIN SELECT * FROM zip WHERE largearea = 1;
                                   QUERY PLAN
--------------------------------------------------------------------------------
 Index Scan using zip_largearea on zip  (cost=0.29..719.21 rows=2773 width=140)
   Index Cond: (largearea = 1)
(2 行)

ossdb=# SELECT largearea,count(*) FROM zip GROUP BY largearea;
 largearea | count
-----------+--------
         0 | 121714
         1 |   2656
(2 行)
```

この例はたとえば書籍の索引と同じで、PostgreSQLに関する技術書で「PostgreSQL」という頻出する単語が書かれたページを巻末の索引で探すことはしないでしょう。ほとんどのページが該当してしまうことが予想できる場合はそのような探し方はせずに、先頭からページをめくって調べるか、異なる単語で目次や索引を見るほうがはるかに効率的だからです。

## バキューム処理
PostgreSQLを継続して利用していくには、バキューム処理が必要になってきます。バキューム処理は、必要の無くなった行データが格納されている領域を回収して、再度利用可能な状態にする処理です。バキューム処理は、PostgreSQLのデータ管理方式に密接に関わっています。

バキューム処理は自動的に行われるように設定されていますが、

### PostgreSQLのデータ管理方式
PostgreSQLでは、行データが更新されたり削除されたりした時に、実際の行データは消しません。それまでの行データに使用されなくなった印をつけて検索の対象から外すようにします。バキューム処理は、これらの不要な行データを回収する処理を行います。

この方式の利点は、更新や削除の段階で物理的に行データを削除せず印を付けておくだけなので、性能面では有利となります。反面、更新処理が多くなると、不要になった行データの量が増えすぎて物理的なデータ量が大きくなってしまうので、ディスク容量を圧迫したり、シーケンシャルスキャンの性能が劣化してしまいます。

### VACUUMとVACUUM FULL
バキューム処理を行うには、VACUUM文あるいはVACUUM FULL文を使用します。

VACUUM文は、不要な行データを回収して再利用可能な状態にします。データファイルのサイズは変わりません。

VACUUM FULL文はさらに行データの物理的な配置を移動させてデータファイルのサイズを縮小することができます。VACUUM FULL文は行データの移動を伴うため、実行すると表全体に強いロックが取得されて、他のユーザーが処理を行えなくなります。VACUUM FULL文は副作用が大きいので、大量にデータを削除した後、データファイルのサイズを縮小してディスクの空き容量を増やしたい場合などに使用すると良いでしょう。

### VACUUM ANALYZE
VACUUM文は、データの分布を調査してSQL実行プランの決定に役立てる統計情報を再作成するANALYZE文と同時実行できます。

以下の例は、データベースに対してVACUUM ANALYZEを実行しています。
```
ossdb=# VACUUM ANALYZE;
VACUUM
```

### 自動バキュームデーモン
自動バキュームデーモンは、VACUUMとANALYZEを自動的に実行してくれる仕組みです。

自動バキュームデーモンはデフォルトで動作しており、バキューム処理、統計情報再作成処理が必要になるタイミングを監視しています。

自動バキュームデーモンが動作しているかどうかを確認してみましょう。Linux上での動作しているautovacuumという名前のプロセスが自動バキュームデーモンです。
```
[postgres@host1 ~]$ ps ax | grep autovacuum
  37358 ?        Ss     0:10 postgres: autovacuum launcher
  60901 pts/1    S+     0:00 grep --color=auto autovacuum
```

## クラスタ
クラスタ化は、物理的なデータの配置をインデックスに従って再配置します。再配置により、インデックスを使って検索される行データが物理ディスク上でまとめられるため、ディスクアクセスが減り性能が向上することが期待できます。

クラスタ化を行うにはCLUSTER文を使用します。初めてクラスタ化を行う場合にはインデックスをUSING句で明示的に指定する必要があります。2回目以降はクラスタ化するために使用したインデックスが記録されているので、インデックスを指定しないでCLUSTER文を実行しても大丈夫です。

以下の例では、orders表のorders_pkeyインデックスを使用してクラスタ化を行っています。クラスタ化に使用したインデックスは、情報の後ろにCLUSTERと表示されます。

```
ossdb=# CLUSTER orders;
ERROR:  テーブル"orders"には事前にクラスタ化されたインデックスはありません
ossdb=# CLUSTER orders USING orders_pkey;
CLUSTER
ossdb=# \d orders
                              テーブル"public.orders"
     列      |           タイプ            | 照合順序 | Null 値を許容 | デフォルト
-------------+-----------------------------+----------+---------------+------------
 order_id    | integer                     |          | not null      |
 order_date  | timestamp without time zone |          |               |
 customer_id | integer                     |          |               |
 prod_id     | integer                     |          |               |
 qty         | integer                     |          |               |
インデックス:
    "orders_pkey" PRIMARY KEY, btree (order_id) CLUSTER
外部キー制約:
    "orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    "orders_prod_id_fkey" FOREIGN KEY (prod_id) REFERENCES prod(prod_id)
```

\pagebreak
