# バックアップとリストア
データベースのバックアップとリストアは、重要なデータを扱うデータベースにとって重要な作業です。ハードディスクの障害などでデータが失われた時、あらかじめ取得しておいたバックアップから確実にリストアが行えるようにしておく必要があります。この章ではバックアップとリストアについて解説します。

## バックアップ手法の整理
データベースのデータは、多数のユーザーにより同時に更新される可能性があり、テキスト文書や表計算ソフトのファイルをUSBメモリにコピーするような単純な手法ではバックアップになりません。

以下のようなバックアップ手法を知り、利用目的に応じて使い分ける必要があります。

| 手法 | 復旧ポイント | 説明
|---|---|---
| ファイルコピー | バックアップ取得時点 | データベースを停止して、OSコマンドでファイルをコピーする方法。システムを停止できる場合は最も簡単。
| SELECT文 | バックアップ取得時点 | データベースを停止せずに、SELECTした結果をファイルに書き出す。COPY文や\\oメタコマンドを使用。
| pg_dump | バックアップ取得時点 | データベースを停止せずに専用のコマンドでデータをファイルに書き出す。内部的にはCOPY文相当の処理が行われる。バックアップ対象や出力形式を柔軟に選択でき、復旧ポイント次第では有力な選択肢である。
| pg_basebackup | 障害発生直前 | バックアップ取得以降に発生した障害に対して有効な選択肢である。バックアップファイルに変更履歴を順に適用することで障害発生直前の状態まで復旧することができるほか、時刻やトランザクション位置を指定して、変更履歴に含まれる任意の時点に復旧することもできる。
| レプリケーション | リアルタイム～指定間隔 | レプリケーション機能でデータベースまたはテーブル単位の複製を作成する。標準機能ではストリーミングレプリケーションやロジカルレプリケーション、他にもさまざまなレプリケーションツールが公開されており、リアルタイム性の高いものやクラウドで保管するなどツールにより特徴がある。

バックアップ手法の一例として、環境準備や事前設定が不要で簡単に試すことができる「ファイルコピー」と「pg_dump」を紹介します。

## ファイルのコピー
最も確実で簡単なバックアップは、ファイルレベルでのバックアップです。必要となるファイルをすべてコピーすることでバックアップができます。ただし、ファイルのコピーを行うにはPostgreSQLを完全に停止する必要があります。

以下の例では、OSユーザーadminでPostgreSQLを停止した後、OSユーザーpostgresでtarコマンドを使用してPostgreSQLの関連ファイルが格納されているデータディレクトリ以下をアーカイブしています。

```
[admin@host1 ~]$ sudo systemctl stop postgresql
[admin@host1 ~]$ sudo systemctl status postgresql
○ postgresql.service - PostgreSQL database server
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; disabled; preset: disabled)
     Active: inactive (dead)

[admin@host1 ~]$ su - postgres
パスワード:
[postgres@host1 ~]$ tar cvf backup.tar /var/lib/pgsql/data
tar: メンバ名から先頭の `/' を取り除きます
/var/lib/pgsql/data/
/var/lib/pgsql/data/pg_wal/
/var/lib/pgsql/data/pg_wal/archive_status/
（略）
/var/lib/pgsql/data/postgresql.conf
/var/lib/pgsql/data/pg_hba.conf
/var/lib/pgsql/data/current_logfiles
[postgres@host1 ~]$ ls -l backup.tar
-rw-r--r--. 1 postgres postgres 94341120  4月 21 13:27 backup.tar
```

## pg_dumpコマンドによるバックアップ
pg_dumpコマンドは、データベースをSQL文としてバックアップするコマンドです。ファイルのコピーと違い、データベースを停止することなくバックアップすることができます。pg_dumpコマンドを実行すると、データベースまたは表単位で、指定した形式でファイルに出力することができます。

pg_dumpコマンドは指定したデータベースや表だけをバックアップするコマンドですが、pg_dumpallコマンドを使うと、すべてのデータベース、作成したユーザーなどの情報をまとめてバックアップすることができます。

以下の例では、pg_dumpコマンドでデータベースossdbをバックアップしています。オプションなどを指定しないと、テキストのSQL文が出力されます。

```
[postgres@host1 ~]$ pg_dump ossdb > backup.sql
パスワード: ※postgresと入力
[postgres@host1 ~]$ head backup.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 13.14
-- Dumped by pg_dump version 13.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
[postgres@host1 ~]$ tail backup.sql
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_prod_id_fkey FOREIGN KEY (prod_id) REFERENCES public.prod(prod_id);


--
-- PostgreSQL database dump complete
--
```

pg_dumpは実行時オプションとして、出力形式やファイルでの出力先の指定、処理の並列化などを指定できます。詳しくはマニュアルを参照してください。


## psqlによるリストア
pg_dump コマンドを使ってバックアップしたファイルは、psqlコマンドにリダイレクトで読み込ませることでリストアすることができます。リストアをするには、テンプレートデータベースtemplate0から新しいデータベースを作成し、そのデータベースにリストアを行います。テンプレートデータベースは新規にデータベースを作成する際に雛形となるデータベースです。通常のデータベース作成ではtemplate1が雛形として使用されますが、pg_dumpコマンドのバックアップからのリストアの際にはtemplate0を使用します。

以下の例では、バックアップ用に新たにデータベースossdb2を作成し、リストアを行っています。

```
[postgres@host1 ~]$ createdb -T template0 ossdb2
パスワード:
[postgres@host1 ~]$ psql ossdb2 < backup.sql
ユーザ postgres のパスワード:
SET
SET
SET
（略）
CREATE INDEX
ALTER TABLE
ALTER TABLE
```

リストアできたデータベースに接続して、リストアされたことを確認します。

```
[postgres@host1 ~]$ psql ossdb2
ユーザ postgres のパスワード:
psql (13.14)
"help"でヘルプを表示します。

ossdb2=# \d
                リレーション一覧
 スキーマ |     名前     |   タイプ   |  所有者
----------+--------------+------------+----------
 public   | char_test    | テーブル   | postgres
 public   | customer     | テーブル   | postgres
 public   | date_test    | テーブル   | postgres
 public   | numeric_test | テーブル   | postgres
 public   | order_id_seq | シーケンス | postgres
 public   | orders       | テーブル   | postgres
 public   | prod         | テーブル   | postgres
 public   | student      | テーブル   | postgres
 public   | varchar_test | テーブル   | postgres
 public   | zip          | テーブル   | postgres
(10 行)

ossdb2=# SELECT count(*) FROM zip;
 count
--------
 124370
(1 行)
```

\pagebreak
