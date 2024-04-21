# 実習環境の構築方法
本書では、データベースが動作する実習環境を構築して、実際にSQL文を実行して実習を進めます。この章では実習環境を構築するために、PostgreSQLのインストールと、実習で使用するデータベースを作成します。

## OSユーザーの作成
dnfコマンドなどを使ってRPMパッケージでPostgreSQLをインストールすると、OSでpostgresユーザーが作成され、関連するディレクトリの所有権やアクセス権が設定されます。このpostgresユーザーをあらかじめ作成しておくことで、OSユーザーとしての設定（ホームディレクトリや環境変数など）の管理がしやすくなります。

以下の例では、adminユーザーでログイン後、useraddコマンドでpostgresユーザーを作成し、passwdコマンドでユーザーのパスワードを設定しています。その後、suコマンドでpostgresユーザーに切り替えてプロンプトの表示やホームディレクトリ位置を確認し、adminユーザーに戻しています。

```
[admin@host1 ~]$ sudo useradd postgres
[sudo] admin のパスワード: ※adminユーザーのパスワードを入力
[admin@host1 ~]$ sudo passwd postgres
ユーザー postgres のパスワードを変更。
ユーザー postgres のパスワードを変更。
新しい パスワード:
新しい パスワードを再入力してください:
passwd: すべての認証トークンが正しく更新できました。
[admin@host1 ~]$ su - postgres
パスワード: ※設定したpostgresユーザーのパスワードを入力
最終ログイン: 2024/04/06 (土) 13:49:14 JST 日時 pts/1
[postgres@host1 ~]$ pwd
/home/postgres
[postgres@host1 ~]$ exit
[admin@host1 ~]$
```

## PostgreSQLのインストール
AlmaLinux 9.3では、ディストリビューションの標準パッケージとしてPostgreSQL 13が提供されています。このパッケージをdnfコマンドを使ってインストールします。

dnfコマンドの引数に必要なパッケージとしてpostgresql-serverを指定してインストールします。依存関係が解消されて、postgresqlパッケージとpostgresql-private-libsパッケージも一緒にインストールされます。

| パッケージ名 | 説明
|---|---
| postgresql | PostgreSQLを利用する上で必須のクライアントプログラムやライブラリ
| postgresql-private-libs | PostgreSQLを利用する上で必須の共有ライブラリ
| postgresql-server | サーバープログラムの本体
| postgresql-contrib | 拡張機能（インストールは必須ではありません）

```
[admin@host1 ~]$ sudo dnf install postgresql-server
メタデータの期限切れの最終確認: 3:20:56 前の 2024年04月06日 11時06分42秒 に実施しました。
依存関係が解決しました。
================================================================================
 パッケージ                  Arch        バージョン         リポジトリー  サイズ
================================================================================
インストール:
 postgresql-server           aarch64     13.14-1.el9_3      appstream     5.6 M
依存関係のインストール:
 postgresql                  aarch64     13.14-1.el9_3      appstream     1.5 M
 postgresql-private-libs     aarch64     13.14-1.el9_3      appstream     130 k

トランザクションの概要
================================================================================
インストール  3 パッケージ

ダウンロードサイズの合計: 7.2 M
インストール後のサイズ: 30 M
これでよろしいですか? [y/N]: y
パッケージのダウンロード:
(1/3): postgresql-private-libs-13.14-1.el9_3.aa 251 kB/s | 130 kB     00:00
(2/3): postgresql-13.14-1.el9_3.aarch64.rpm     664 kB/s | 1.5 MB     00:02
(3/3): postgresql-server-13.14-1.el9_3.aarch64. 2.1 MB/s | 5.6 MB     00:02
--------------------------------------------------------------------------------
合計                                            1.9 MB/s | 7.2 MB     00:03
トランザクションの確認を実行中
トランザクションの確認に成功しました。
トランザクションのテストを実行中
トランザクションのテストに成功しました。
トランザクションを実行中
  準備             :                                                        1/1
  インストール中   : postgresql-private-libs-13.14-1.el9_3.aarch64          1/3
  インストール中   : postgresql-13.14-1.el9_3.aarch64                       2/3
  scriptletの実行中: postgresql-server-13.14-1.el9_3.aarch64                3/3
  インストール中   : postgresql-server-13.14-1.el9_3.aarch64                3/3
  scriptletの実行中: postgresql-server-13.14-1.el9_3.aarch64                3/3
  検証             : postgresql-13.14-1.el9_3.aarch64                       1/3
  検証             : postgresql-private-libs-13.14-1.el9_3.aarch64          2/3
  検証             : postgresql-server-13.14-1.el9_3.aarch64                3/3

インストール済み:
  postgresql-13.14-1.el9_3.aarch64
  postgresql-private-libs-13.14-1.el9_3.aarch64
  postgresql-server-13.14-1.el9_3.aarch64

完了しました!
```


## データベースクラスターの初期化
インストールが終わったら、データベースクラスターの初期化を行います。PostgreSQLが管理するデータベースそのもの（実体はOS上のファイル）や各種設定ファイル、変更履歴ファイル、ログファイルなどをひとまとめにしたものをデータベースクラスタと呼びます。

インストールしたPostgreSQLは、OSユーザーpostgresが初期化ユーザーとして管理権限を持っています。このユーザーをPostgreSQLのスーパーユーザーと呼びます。suコマンドでユーザーpostgresに変更して操作を行います。

以下の例では、データベースクラスターの初期化はpostgresql-setupスクリプトに--initdbオプションを付けて実行します。データベースクラスターを構成するすべてのファイルやディレクトリは1つのディレクトリ配下にまとめて配置されます。/var/lib/pgsql/dataディレクトリにデータベースクラスターが作成されているのが分かります。

```
[admin@host1 ~]$ su - postgres
[postgres@host1 ~]$ postgresql-setup --initdb
 * Initializing database in '/var/lib/pgsql/data'
 * Initialized, logs are in /var/lib/pgsql/initdb_postgresql.log
[postgres@host1 ~]$ ls /var/lib/pgsql/data/
PG_VERSION        pg_hba.conf    pg_snapshots  pg_xact
base              pg_ident.conf  pg_stat       postgresql.auto.conf
current_logfiles  pg_logical     pg_stat_tmp   postgresql.conf
global            pg_multixact   pg_subtrans   postmaster.opts
log               pg_notify      pg_tblspc     postmaster.pid
pg_commit_ts      pg_replslot    pg_twophase
pg_dynshmem       pg_serial      pg_wal
```

## サービスの起動
データベースクラスターを作成したら、PostgreSQLのサービスを起動します。

以下の例では、systemctlコマンドでpostgresqlサービスを起動しています。

```
[postgres@host1 ~]$ systemctl start postgresql
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
'postgresql.service'を開始するには認証が必要です。
Authenticating as: ADMIN (admin)
Password: ※adminユーザーのパスワードを入力
==== AUTHENTICATION COMPLETE ====
[postgres@host1 ~]$ systemctl status postgresql
● postgresql.service - PostgreSQL database server
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; disabled; pres>
     Active: active (running) since Sat 2024-04-06 14:43:06 JST; 9s ago
    Process: 5145 ExecStartPre=/usr/libexec/postgresql-check-db-dir postgresql >
   Main PID: 5147 (postmaster)
      Tasks: 8 (limit: 10552)
     Memory: 16.7M
        CPU: 41ms
     CGroup: /system.slice/postgresql.service
             ├─5147 /usr/bin/postmaster -D /var/lib/pgsql/data
             ├─5148 "postgres: logger "
             ├─5150 "postgres: checkpointer "
             ├─5151 "postgres: background writer "
             ├─5152 "postgres: walwriter "
             ├─5153 "postgres: autovacuum launcher "
             ├─5154 "postgres: stats collector "
             └─5155 "postgres: logical replication launcher "
lines 1-17/17 (END)
```

### PostgreSQLサービスの自動起動の設定
PostgreSQLサービスはデフォルトでは手動起動になっているので、システムの起動毎に自動的に起動したい場合にはsystemctlでenableサブコマンドを指定します。自動起動を無効にする場合はdisableを指定します。

```
[postgres@host1 ~]$ systemctl enable postgresql
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ====
Authentication is required to manage system service or unit files.
Authenticating as: ADMIN (admin)
Password: ※adminユーザーのパスワードを入力
==== AUTHENTICATION COMPLETE ====
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ====
Authentication is required to reload the systemd state.
Authenticating as: ADMIN (admin)
Password: ※adminユーザーのパスワードを入力
==== AUTHENTICATION COMPLETE ====
```

## 動作の確認
データベースの動作確認を行います。

以下の例では、psqlに-lオプションを付けて実行し、作成されているデータベースを確認します。

```
[postgres@host1 ~]$ psql -l
                                         データベース一覧
   名前    |  所有者  | エンコーディング |  照合順序   | Ctype(変換演算子) |     アクセス権限
-----------+----------+------------------+-------------+-------------------+-----------------------
 postgres  | postgres | UTF8             | ja_JP.UTF-8 | ja_JP.UTF-8       |
 template0 | postgres | UTF8             | ja_JP.UTF-8 | ja_JP.UTF-8       | =c/postgres          +
           |          |                  |             |                   | postgres=CTc/postgres
 template1 | postgres | UTF8             | ja_JP.UTF-8 | ja_JP.UTF-8       | =c/postgres          +
           |          |                  |             |                   | postgres=CTc/postgres
(3 行)
```

## 実習用データベースの作成
実習用のデータベースossdbを作成します。作成後、psqlコマンドで接続できることを確認しておきます。

```
[postgres@host1 ~]$ createdb ossdb
[postgres@host1 ~]$ psql ossdb
psql (13.14)
"help"でヘルプを表示します。

ossdb=#
```

## 表の作成
表を作成します。prod表、customer表、orders表の3つを作成します。

以下のSQL文をpsqlを実行している端末にコピー＆ペーストすれば、必要な表が作成されます。
```
CREATE TABLE prod
(prod_id   integer,
 prod_name text,
 price     integer);

CREATE TABLE customer
 (customer_id   integer,
 customer_name text);

CREATE TABLE orders
 (order_id    integer,
 order_date  timestamp,
 customer_id integer,
 prod_id     integer,
 qty         integer);
```

以下は実行例です。

```
ossdb=# CREATE TABLE prod
 (prod_id   integer,
  prod_name text,
  price     integer);
CREATE TABLE
（略）
```

## データの入力
作成した表に初期データを入力します。以下のSQL文をpsqlを実行している端末にコピー＆ペーストすれば、初期データがそれぞれの表に入力されます。

```
INSERT INTO customer(customer_id,customer_name) VALUES
 (1,'佐藤商事'),
 (2,'鈴木物産'),
 (3,'高橋商店');

INSERT INTO prod(prod_id,prod_name,price) VALUES
 (1,'みかん',50),
 (2,'りんご',70),
 (3,'メロン',100);

INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (1,CURRENT_TIMESTAMP,1,1,10);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (2,CURRENT_TIMESTAMP,2,2,5);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (3,CURRENT_TIMESTAMP,3,3,8);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (4,CURRENT_TIMESTAMP,2,1,3);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (5,CURRENT_TIMESTAMP,3,2,4);
```

以下は実行例です。
```
ossdb=# INSERT INTO customer(customer_id,customer_name) VALUES
 (1,'佐藤商事'),
 (2,'鈴木物産'),
 (3,'高橋商店');
INSERT 0 3
（略）
```

\pagebreak
