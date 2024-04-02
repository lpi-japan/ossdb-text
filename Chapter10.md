# バックアップとリストア
データベースのバックアップとリストアは、重要なデータを扱うデータベースにとって重要な作業です。ハードディスクの障害などでデータが失われた時、あらかじめ取得しておいたバックアップから確実にリストアが行えるようにしておく必要があります。

## バックアップ手法の整理
データベースのデータは、多数のユーザーにより同時に更新される可能性があり、テキスト文書や表計算ソフトのファイルをUSBメモリにコピーするような単純な手法ではバックアップになりません。

以下のようなバックアップ手法を知り、利用目的に応じて使い分ける必要があります。

### 主なバックアップ手法一覧

手法 | 復旧ポイント | 説明
------------ | --------------- |---------------------------------------------------
ファイルコピー | バックアップ取得時点 | データベースを停止して、OSコマンドでファイルをコピーする方法。アプリケーションを停止できる場合は最も簡単。
SELECT文 | バックアップ取得時点 | データベースを停止せずに、SELECTした結果をファイルに書き出す。COPY文や\oメタコマンドを使用。
pg_dump | バックアップ取得時点 | データベースを停止せずに専用のコマンドでデータをファイルに書き出す。内部的にはCOPY文相当の処理が行われる。バックアップ対象や出力形式を柔軟に選択でき、復旧ポイント次第では有力な選択肢である。
pg_basebackup | 障害発生直前 | バックアップ取得以降に発生した障害に対して有効な選択肢である。バックアップファイルに変更履歴を順に適用することで障害発生直前の状態まで復旧することができるほか、時刻やトランザクション位置を指定して、変更履歴に含まれる任意の時点に復旧することもできる。
レプリケーション | リアルタイム～指定間隔 | レプリケーション機能でデータベースまたはテーブル単位の複製を作成する。標準機能ではストリーミングレプリケーションやロジカルレプリケーション、他にもさまざまなレプリケーションツールが公開されており、リアルタイム性の高いものやクラウドで保管するなどツールにより特徴がある。

本書では、バックアップ手法の一例として、環境準備や事前設定が不要で簡単に試すことができる「ファイルコピー」と「pg_dump」を紹介します。

## ファイルのコピー
最も確実で簡単なバックアップは、ファイルレベルでのバックアップです。必要となるファイルをすべてコピーすることでバックアップができます。ただし、ファイルのコピーを行うにはPostgreSQLを完全に停止する必要があります。

以下の例では、tarコマンドを使用してPostgreSQLの関連ファイルが格納されているデータディレクトリ$PGDATA以下をアーカイブしています。
```
[postgres@localhost ~]$ pg_ctl stop -m fast
サーバ停止処理の完了を待っています....完了
サーバは停止しました
[postgres@localhost ~]$ tar cvf backup.tar $PGDATA
tar: メンバ名から先頭の / を取り除きます
/var/lib/pgsql/10/data/
/var/lib/pgsql/10/data/pg_wal/
/var/lib/pgsql/10/data/pg_wal/archive_status/
/var/lib/pgsql/10/data/pg_wal/000000010000000000000003
/var/lib/pgsql/10/data/pg_wal/000000010000000000000004
　　：
[postgres@localhost ~]$ ls -l backup.tar
-rw-rw-r--. 1 postgres postgres 95887360  1月  23 12:34 backup.tar
[postgres@localhost ~]$ pg_ctl start
サーバの起動完了を待っています....
2018-02-05 02:09:45.616 JST [4866] LOG:  redirecting log output to logging collector process
2018-02-05 02:09:45.616 JST [4866] HINT:  Future log output will appear in directory "log".
完了
サーバ起動完了
```

注意： この方法はデータベースを構成する *すべてのファイル* を利用者自身が指定する必要があります。テーブルスペース機能を用いて複数ディレクトリに分かれて保持されているデータがある場合、もれなく取得しなければなりません。


## pg_dumpコマンドによるバックアップ
pg_dumpコマンドは、データベースをSQL文としてバックアップするコマンドです。ファイルのコピーと違い、データベースを停止することなくバックアップすることができます。
pg_dumpコマンドを実行すると、データベースまたは表単位で、指定した形式でファイルに出力することができます。

pg_dumpコマンドは指定したデータベースや表だけをバックアップするコマンドですが、pg_dumpallコマンドを使うと、すべてのデータベース、作成したユーザーなどの情報をまとめてバックアップすることができます。

以下の例では、pg_dumpコマンドでデータベースossdbをバックアップしています。実行時オプションとして、-Fで出力形式「ディレクトリ」、-fで「ディレクトリ名」、最後の引数は対象データベース名を指定しています。
ディレクトリ形式とは、指定したディレクトリ配下にテーブル毎にダンプファイルを作成するものです。リストア時に対象テーブルがわかっていれば必要なファイルのみを渡せばよい点や、-jオプションと組み合わせることで複数コアを使った並列ダンプに対応しています。
```
[postgres@localhost ~]$ mkdir backup.d
[postgres@localhost ~]$ ls -l | grep backup.d
drwxrwxr-x. 2 postgres postgres     4096  1月 23 12:34 backup.d

[postgres@localhost ~]$ pg_dump -Fd -f backup.d ossdb
パスワード:<postgresユーザーのパスワード>

[postgres@localhost ~]$ ls backup.d
3711.dat.gz  3713.dat.gz  3715.dat.gz  3717.dat.gz  3719.dat.gz  toc.dat
3712.dat.gz  3714.dat.gz  3716.dat.gz  3718.dat.gz  3720.dat.gz
```

## pg_restoreによるリストア
pg_dumpコマンドを使ってバックアップしたファイルは、専用のpg_restoreコマンドでデータベースに読み込ませることができます。
pg_restoreの実行時オプションでは、ダンプファイルに含まれる「データベース」または「表」を指定して対象のみをリストアできます。ダンプファイルに含まれるデータベース定義を元にCREATE DATABSEから実施する方法や、データベースに対してCREATE TABLEしたり、既存のテーブルにデータのみINSERTする方法などが柔軟に指定可能です。

以下の例では、障害に見立ててossdbデータベースを削除した後、先ほど取得したバックアップ「backup.d」を指定してデータベース全体をリストアしています。pg_restoreコマンド実行時のポイントとしては、いまはossdbデータベースが存在しないため、リストア操作のために一時的にpostgresデータベースに接続し、-Cオプションで新規にossdbデータベースを作成していることです。
```
/* 障害に見立ててossdbデータベースを削除 */

[postgres@localhost ~]$ dropdb ossdb
パスワード:
[postgres@localhost ~]$ psql ossdb
Password:
psql: FATAL:  database "ossdb" does not exist

/* ossdbデータベースを復旧 */

[postgres@localhost ~]$ pg_restore -d postgres -c -C  backup.d
パスワード:
pg_restore: [アーカイバ(db)] TOC処理中にエラーがありました:
pg_restore: [アーカイバ(db)] TOCエントリ3726; 1262 16384 DATABASE ossdb postgresのエラーです
pg_restore: [アーカイバ(db)] could not execute query: ERROR:  database "ossdb" does not exist
   コマンド: DROP DATABASE ossdb;

警告: リストアにてエラーを無視しました: 1

/* ここではデータベースossdbが存在しない旨のエラーが表示されますが、問題ありません。
 * pg_restoreではリストア対象（今回はossdbデータベース）と重複するデータを最初に削除する処理（今回はdropdb ossdb）を実行しており、
 * 直前のdropdbコマンドで削除対象のossdbデータベースがすでに存在しないため、内部で実行しようとしたdropdb処理のみが失敗しているのです。
 */

[postgres@localhost ~]$ psql ossdb
Password:
psql (10.1)
Type "help" for help.

ossdb=# \d
              List of relations
 Schema |     Name     |   Type   |  Owner
--------+--------------+----------+----------
 public | char_test    | table    | postgres
 public | customer     | table    | postgres
 public | date_test    | table    | postgres
 public | numeric_test | table    | postgres
 public | order_id_seq | sequence | postgres
 public | orders       | table    | postgres
 public | prod         | table    | postgres
 public | student      | table    | postgres
 public | varchar_test | table    | postgres
 public | zip          | table    | postgres
(10 rows)

ossdb=# SELECT count(*) FROM zip;
 count
--------
 124165
(1 row)
```

\pagebreak
