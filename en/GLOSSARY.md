# Japanese-English Glossary for OSS-DB Standard Textbook Translation
#
# Format: Japanese term | English translation | Notes
# This is the authoritative reference for all translation work.
# When translating, always use the English term listed here.
# When a new term is encountered, add it here before translating.

## Document / Publication Terms

| Japanese | English | Notes |
|---|---|---|
| オープンソースデータベース標準教科書 | Open Source Database Standard Textbook | Full title |
| 本教科書 | this textbook | |
| 実習 | hands-on exercise | or "exercise" in context |
| 演習 | exercise | |
| 演習問題 | exercise problem | |
| 解答例 | sample answer | |
| 章 | chapter | |
| まえがき | preface | |
| 全体の流れ | overview | or "chapter overview" |
| 著作権 | copyright | |
| 使用に関する権利 | terms of use | |
| 表示 | attribution | (CC license term) |
| 非営利 | non-commercial | (CC license term) |
| 改変禁止 | no derivatives | (CC license term) |
| フィードバック | feedback | |
| 執筆者・制作担当者 | authors and contributors | |

## Organization / Proper Nouns

| Japanese | English | Notes |
|---|---|---|
| 特定非営利活動法人エルピーアイジャパン | LPI Japan (NPO) | |
| LPI-Japan | LPI-Japan | keep as-is |
| OSS-DB | OSS-DB | keep as-is |
| びぎねっと | Begi.net | |
| 日本PostgreSQLユーザ会（JPUG） | Japan PostgreSQL Users Group (JPUG) | |

## Infrastructure / Environment Terms

| Japanese | English | Notes |
|---|---|---|
| 実習環境 | practice environment | |
| 仮想マシン | virtual machine | |
| データベース | database | |
| データベースエンジン | database engine | |
| データベースサーバー | database server | |
| クラウド環境 | cloud environment | |
| ネットワーク | network | |
| パッケージ | package | |
| ソースコード | source code | |
| インストール | installation / install | |
| サービス | service | |
| 起動 | start / startup | |
| 停止 | stop | |
| 再起動 | restart | |
| 自動起動 | automatic startup | |
| 設定ファイル | configuration file | |
| ポート番号 | port number | |
| ユーザー | user | |
| パスワード | password | |
| ホスト名 | hostname | |
| IPアドレス | IP address | |

## PostgreSQL Specific Terms

| Japanese | English | Notes |
|---|---|---|
| psql | psql | keep as-is |
| pg_dump | pg_dump | keep as-is |
| pg_restore | pg_restore | keep as-is |
| createdb | createdb | keep as-is |
| createuser | createuser | keep as-is |
| dropdb | dropdb | keep as-is |
| dropuser | dropuser | keep as-is |
| スーパーユーザー | superuser | |
| データクラスター | data cluster | |
| initdb | initdb | keep as-is |
| PostgreSQLのデータ管理方式 | PostgreSQL data management | |
| データディレクトリ | data directory | |
| 認証 | authentication | |
| pg_hba.conf | pg_hba.conf | keep as-is |
| postgresql.conf | postgresql.conf | keep as-is |

## SQL / Database Object Terms

| Japanese | English | Notes |
|---|---|---|
| SQL文 | SQL statement | |
| SQL | SQL | keep as-is |
| 表 | table | |
| 列 | column | |
| 行 | row | |
| レコード | record | |
| データ | data | |
| データ型 | data type | |
| 主キー | primary key | |
| 外部キー | foreign key | |
| 制約 | constraint | |
| NOT NULL制約 | NOT NULL constraint | |
| 一意制約 | UNIQUE constraint | |
| 一意 | unique | |
| 一意キー | unique key | |
| 参照整合性 | referential integrity | |
| インデックス（索引） | index | |
| インデックス | index | |
| 索引 | index | |
| シーケンス | sequence | |
| ビュー | view | |
| スキーマ | schema | |
| トランザクション | transaction | |
| コミット | commit | |
| ロールバック | rollback | |
| ロック | lock | |
| デッドロック | deadlock | |
| 並行処理 | concurrent processing | |

## SQL Clause / Keyword Terms

| Japanese | English | Notes |
|---|---|---|
| 検索 | query / search | |
| 絞り込み検索 | filtered search / WHERE filtering | |
| 並べ替え | sort / sorting | |
| 集約関数 | aggregate function | |
| 副問い合わせ | subquery | |
| 結合 | join | |
| 内部結合 | inner join | |
| 外部結合 | outer join | |
| 左外部結合 | left outer join | |
| 右外部結合 | right outer join | |
| クロス結合 | cross join | |
| 自己結合 | self join | |
| 選択 | SELECT | in context of SQL |
| 挿入 | INSERT | in context of SQL |
| 更新 | UPDATE | in context of SQL |
| 削除 | DELETE | in context of SQL |
| 項目リスト | column list | in SELECT context |
| 条件 | condition | |
| 演算子 | operator | |
| 関数 | function | |
| 日付 | date | |
| 時刻 | time | |

## Data Types

| Japanese | English | Notes |
|---|---|---|
| 整数型 | integer type | |
| 文字型 | character type | |
| 文字列 | character string / string | |
| 数値型 | numeric type | |
| 日付型 | date type | |
| 時刻型 | time type | |
| 論理値型 | boolean type | |
| NULL | NULL | keep as-is |
| 固定長文字列 | fixed-length string | |
| 可変長文字列 | variable-length string | |

## Backup / Restore Terms

| Japanese | English | Notes |
|---|---|---|
| バックアップ | backup | |
| リストア | restore | |
| ダンプ | dump | |
| アーカイブ | archive | |
| ファイルシステムレベルのバックアップ | file system-level backup | |
| 論理バックアップ | logical backup | |
| 復元 | recovery / restore | |

## Performance Terms

| Japanese | English | Notes |
|---|---|---|
| パフォーマンスチューニング | performance tuning | |
| 実行計画 | execution plan | |
| EXPLAINコマンド | EXPLAIN command | |
| VACUUM | VACUUM | keep as-is |
| ANALYZE | ANALYZE | keep as-is |
| シーケンシャルスキャン | sequential scan | |
| インデックススキャン | index scan | |
| コスト | cost | in query plan context |
| 統計情報 | statistics | |
| 断片化 | fragmentation | |
| 不要領域 | dead tuples / wasted space | |

## Access Control Terms

| Japanese | English | Notes |
|---|---|---|
| アクセス権限 | access privilege | |
| 権限 | privilege | |
| 付与 | grant | |
| 取り消し | revoke | |
| ロール | role | |
| 所有者 | owner | |
| 公開スキーマ | public schema | |

## General Technical Terms

| Japanese | English | Notes |
|---|---|---|
| コマンド | command | |
| ファイル | file | |
| ディレクトリ | directory | |
| パス | path | |
| 文字コード | character encoding | |
| UTF-8 | UTF-8 | keep as-is |
| 改行 | newline | |
| コメント | comment | |
| メタコマンド | meta-command | psql specific |
| プロンプト | prompt | |
| 出力 | output | |
| 入力 | input | |
| エラー | error | |
| 警告 | warning | |
| 確認 | confirmation / verify | |
| 管理者 | administrator | |
| root | root | keep as-is |
| OSユーザー | OS user | |
| スクリプト | script | |
| CSVファイル | CSV file | |
| ZIPファイル | ZIP file | |
| ログ | log | |

## UI / Instruction Terms

| Japanese | English | Notes |
|---|---|---|
| 以下 | the following / below | |
| 以上 | the above / or higher (version) | |
| 参照 | refer to / see | |
| 確認してください | verify / check | |
| 実行してください | execute / run | |
| 入力してください | enter / type | |
| 注意 | Note / Caution | |
| ヒント | Hint / Tip | |
| 例 | example | |
| 例文 | example statement | |
| サンプル | sample | |
| 試してみましょう | let's try | |
