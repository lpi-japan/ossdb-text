# How to Build the Practice Environment
In this textbook, you will build a practice environment in which the database runs and proceed with the exercises by actually executing SQL statements. In this chapter, you will install PostgreSQL and create the database used in the exercises in order to build the practice environment.

## Creating an OS User
If you install PostgreSQL as an RPM package using the `dnf` command or similar, the `postgres` user is created in the OS, and ownership and access permissions are set for the related directories. By creating this `postgres` user in advance, it becomes easier to manage settings for the OS user, such as the home directory and environment variables.

In the following example, after logging in as the `admin` user, the `postgres` user is created with the `useradd` command, and the user's password is set with the `passwd` command. After that, the `su` command is used to switch to the `postgres` user to check the prompt display and the location of the home directory, and then the session returns to the `admin` user.

```
[admin@host1 ~]$ sudo useradd postgres
[sudo] Password for admin: Enter the admin user password
[admin@host1 ~]$ sudo passwd postgres
Changing password for user postgres.
Changing password for user postgres.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
[admin@host1 ~]$ su - postgres
Password: Enter the password set for the postgres user
Last login: 2024/04/06 (Sat) 13:49:14 JST on pts/1
[postgres@host1 ~]$ pwd
/home/postgres
[postgres@host1 ~]$ exit
[admin@host1 ~]$
```

## Installing PostgreSQL
On AlmaLinux 9.3, PostgreSQL 13 is provided as a standard distribution package. Install this package using the `dnf` command.

Install it by specifying `postgresql-server` as the required package argument to the `dnf` command. Its dependencies are resolved, and the `postgresql` and `postgresql-private-libs` packages are installed together.

| Package Name | Description
|---|---
| postgresql | Client programs and libraries required to use PostgreSQL
| postgresql-private-libs | Shared libraries required to use PostgreSQL
| postgresql-server | The server program itself
| postgresql-contrib | Extensions (installation is optional)

```
[admin@host1 ~]$ sudo dnf install postgresql-server
Last metadata expiration check: 3:20:56 ago on Sat Apr 06 11:06:42 2024.
Dependencies resolved.
================================================================================
 Package                  Arch        Version            Repository    Size
================================================================================
Installing:
 postgresql-server        aarch64     13.14-1.el9_3      appstream     5.6 M
Installing dependencies:
 postgresql               aarch64     13.14-1.el9_3      appstream     1.5 M
 postgresql-private-libs  aarch64     13.14-1.el9_3      appstream     130 k

Transaction Summary
================================================================================
Install  3 Packages

Total download size: 7.2 M
Installed size: 30 M
Is this ok [y/N]: y
Downloading Packages:
(1/3): postgresql-private-libs-13.14-1.el9_3.aa 251 kB/s | 130 kB     00:00
(2/3): postgresql-13.14-1.el9_3.aarch64.rpm     664 kB/s | 1.5 MB     00:02
(3/3): postgresql-server-13.14-1.el9_3.aarch64. 2.1 MB/s | 5.6 MB     00:02
--------------------------------------------------------------------------------
Total                                            1.9 MB/s | 7.2 MB     00:03
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Installing       : postgresql-private-libs-13.14-1.el9_3.aarch64          1/3
  Installing       : postgresql-13.14-1.el9_3.aarch64                       2/3
  Running scriptlet: postgresql-server-13.14-1.el9_3.aarch64                3/3
  Installing       : postgresql-server-13.14-1.el9_3.aarch64                3/3
  Running scriptlet: postgresql-server-13.14-1.el9_3.aarch64                3/3
  Verifying        : postgresql-13.14-1.el9_3.aarch64                       1/3
  Verifying        : postgresql-private-libs-13.14-1.el9_3.aarch64          2/3
  Verifying        : postgresql-server-13.14-1.el9_3.aarch64                3/3

Installed:
  postgresql-13.14-1.el9_3.aarch64
  postgresql-private-libs-13.14-1.el9_3.aarch64
  postgresql-server-13.14-1.el9_3.aarch64

Complete!
```


## Initializing the Data Cluster
Once the installation is complete, initialize the data cluster. The term data cluster refers to the collection of the database itself managed by PostgreSQL (its actual form is files on the OS), various configuration files, change history files, log files, and so on.

The installed PostgreSQL is managed by the OS user `postgres`, which has administrative privileges as the initialization user. This user is called the PostgreSQL superuser. Use the `su` command to switch to the `postgres` user and perform the operations.

In the following example, the data cluster is initialized by running the `postgresql-setup` script with the `--initdb` option. All files and directories that make up the data cluster are placed together under a single directory. You can see that the data cluster has been created in the `/var/lib/pgsql/data` directory.

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

## Starting the Service
After creating the data cluster, start the PostgreSQL service.

In the following example, the `postgresql` service is started with the `systemctl` command.

```
[postgres@host1 ~]$ systemctl start postgresql
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'postgresql.service'.
Authenticating as: ADMIN (admin)
Password: Enter the admin user password
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

## Configuring Automatic Startup of the PostgreSQL Service
Because the PostgreSQL service is set to manual startup by default, if you want it to start automatically each time the system starts, specify the `enable` subcommand with `systemctl`. To disable automatic startup, specify `disable`.

```
[postgres@host1 ~]$ systemctl enable postgresql
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-unit-files ====
Authentication is required to manage system service or unit files.
Authenticating as: ADMIN (admin)
Password: Enter the admin user password
==== AUTHENTICATION COMPLETE ====
==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ====
Authentication is required to reload the systemd state.
Authenticating as: ADMIN (admin)
Password: Enter the admin user password
==== AUTHENTICATION COMPLETE ====
```

## Verifying Operation
Verify that the database is operating correctly.

In the following example, `psql` is run with the `-l` option to check the databases that have been created.

```
[postgres@host1 ~]$ psql -l
                                          List of databases
   Name    |  Owner   | Encoding |   Collate   | Ctype |      Access privileges
-----------+----------+----------+-------------+-------+------------------------
 postgres  | postgres | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8       |
 template0 | postgres | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8       | =c/postgres          +
           |          |          |             |                   | postgres=CTc/postgres
 template1 | postgres | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8       | =c/postgres          +
           |          |          |             |                   | postgres=CTc/postgres
(3 rows)
```

## Creating the Exercise Database
Create the `ossdb` database for the exercises. After creating it, verify that you can connect to it with the `psql` command.

```
[postgres@host1 ~]$ createdb ossdb
[postgres@host1 ~]$ psql ossdb
psql (13.14)
Type "help" for help.

ossdb=#
```

## Creating Tables
Create tables. Create the three tables `prod`, `customer`, and `orders`.

If you copy and paste the following SQL statements into the terminal running `psql`, the required tables will be created.
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

The following is an example.

```
ossdb=# CREATE TABLE prod
 (prod_id   integer,
  prod_name text,
  price     integer);
CREATE TABLE
(output omitted)
```

## Entering Data
Enter the initial data into the created tables. If you copy and paste the following SQL statements into the terminal running `psql`, the initial data will be entered into each table.

```
INSERT INTO customer(customer_id,customer_name) VALUES
 (1,'Sato Trading'),
 (2,'Suzuki Products'),
 (3,'Takahashi Store');

INSERT INTO prod(prod_id,prod_name,price) VALUES
 (1,'orange',50),
 (2,'apple',70),
 (3,'melon',100);

INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (1,CURRENT_TIMESTAMP,1,1,10);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (2,CURRENT_TIMESTAMP,2,2,5);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (3,CURRENT_TIMESTAMP,3,3,8);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (4,CURRENT_TIMESTAMP,2,1,3);
INSERT INTO orders(order_id,order_date,customer_id,prod_id,qty) VALUES (5,CURRENT_TIMESTAMP,3,2,4);
```

The following is an example.
```
ossdb=# INSERT INTO customer(customer_id,customer_name) VALUES
 (1,'Sato Trading'),
 (2,'Suzuki Products'),
 (3,'Takahashi Store');
INSERT 0 3
(output omitted)
```

\pagebreak
