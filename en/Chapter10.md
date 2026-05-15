# Backup and Restore
Backup and restore are critical operations for databases that handle important data. When data is lost due to a hard disk failure or similar issue, you must ensure that it can be reliably restored from a backup taken in advance. This chapter explains backup and restore.

## Organizing Backup Methods
Database data may be updated simultaneously by many users, so a simple method such as copying a text document or spreadsheet file to a USB memory device does not constitute a proper backup.

You need to understand backup methods such as the following and use them appropriately depending on the purpose.

| Method | Recovery point | Description
|---|---|---
| File copy | Point in time when the backup was taken | A method of stopping the database and copying files with OS commands. If the system can be stopped, this is the simplest method.
| SELECT statement | Point in time when the backup was taken | Writes the results of a SELECT to a file without stopping the database. Uses the COPY statement or the \o meta-command.
| pg_dump | Point in time when the backup was taken | Writes data to a file with a dedicated command without stopping the database. Internally, processing equivalent to the COPY statement is performed. You can flexibly choose the backup target and output format, making this a strong option depending on the required recovery point.
| pg_basebackup | Immediately before a failure occurs | An effective option for failures that occur after the backup is taken. By applying change history to the backup file in sequence, you can recover to the state immediately before the failure occurred. You can also specify a time or transaction position to recover to any point included in the change history.
| Replication | Real time to a specified interval | Use replication features to create copies of the database or individual tables. Standard features include streaming replication and logical replication, and various other replication tools are also available. Depending on the tool, characteristics include high real-time capability or storage in the cloud.

As examples of backup methods, this section introduces "file copy" and "pg_dump," which can be tried easily without environment preparation or advance configuration.

## File Copy
The most reliable and simplest backup is a file-level backup. You can create a backup by copying all necessary files. However, PostgreSQL must be completely stopped before copying files.

In the following example, after stopping PostgreSQL as the OS user admin, the OS user postgres uses the tar command to archive everything under the data directory where PostgreSQL-related files are stored.

```
[admin@host1 ~]$ sudo systemctl stop postgresql
[admin@host1 ~]$ sudo systemctl status postgresql
○ postgresql.service - PostgreSQL database server
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; disabled; preset: disabled)
     Active: inactive (dead)

[admin@host1 ~]$ su - postgres
Password:
[postgres@host1 ~]$ tar cvf backup.tar /var/lib/pgsql/data
tar: Removing leading `/' from member names
/var/lib/pgsql/data/
/var/lib/pgsql/data/pg_wal/
/var/lib/pgsql/data/pg_wal/archive_status/
(output omitted)
/var/lib/pgsql/data/postgresql.conf
/var/lib/pgsql/data/pg_hba.conf
/var/lib/pgsql/data/current_logfiles
[postgres@host1 ~]$ ls -l backup.tar
-rw-r--r--. 1 postgres postgres 94341120 Apr 21 13:27 backup.tar
```

## Backup with the pg_dump Command
The pg_dump command is used to back up a database as SQL statements. Unlike file copying, it can create a backup without stopping the database. When you run the pg_dump command, you can output a database or individual tables to a file in the specified format.

The pg_dump command backs up only the specified database or tables, but if you use the pg_dumpall command, you can back up all databases together with information such as created users.

In the following example, the database ossdb is backed up with the pg_dump command. If you do not specify options and so on, text SQL statements are output.

```
[postgres@host1 ~]$ pg_dump ossdb > backup.sql
Password: *enter postgres
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

The pg_dump command supports execution options such as specifying the output format and output file destination, and parallelizing processing. See the manual for details.


## Restoring with psql
A file backed up with the pg_dump command can be restored by redirecting it into the psql command. To perform a restore, create a new database from the template database template0, and then restore into that database. A template database is a database used as a model when creating a new database. Normally, template1 is used as the model for standard database creation, but template0 is used when restoring from a pg_dump backup.

In the following example, a new database named ossdb2 is created for the restore, and the restore is performed.

```
[postgres@host1 ~]$ createdb -T template0 ossdb2
Password:
[postgres@host1 ~]$ psql ossdb2 < backup.sql
Password for user postgres:
SET
SET
SET
(output omitted)
CREATE INDEX
ALTER TABLE
ALTER TABLE
```

Connect to the restored database and verify that it has been restored.

```
[postgres@host1 ~]$ psql ossdb2
Password for user postgres:
psql (13.14)
Type "help" for help.

ossdb2=# \d
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

ossdb2=# SELECT count(*) FROM zip;
 count
--------
 124370
(1 row)
```

\pagebreak
