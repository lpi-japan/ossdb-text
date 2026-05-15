# Multi-User Usage
PostgreSQL is a multi-user database. By using multiple users appropriately, you can vary the database operations allowed for each user—for example, allowing one user to update table data while another can only query it. This chapter explains how to use a database in a multi-user environment.

## Creating Users
To create a PostgreSQL user, use the `CREATE USER` statement. You can also create users from the Linux command line with the `createuser` command.

To check users, execute the `\du` meta-command.

In the following example, the user `sato` is created. The password required when logging in as this user is also specified.

```
ossdb=# CREATE USER sato PASSWORD 'sato';
CREATE ROLE
ossdb=# \du
                                    List of roles
 Role name |                         Attributes                          | Member of
-----------+-------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 sato      |                                                             | {}
```

In the following example, the user `suzuki` is created from the Linux command line using the `createuser` command. If you specify the `-P` option, you can interactively enter the password required when logging in as this user.

```
[postgres@host1 ~]$ createuser -P suzuki
Enter password for new role:
Enter it again:
[postgres@host1 ~]$ psql ossdb
ossdb=# \du
                                     List of roles
 Role name |                         Attributes                          | Member of
-----------+-------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 sato      |                                                             | {}
 suzuki    |                                                             | {}
```

### Users and Roles
In the output of the `CREATE USER` statement and the `createuser` command, `role (ROLE)` is displayed instead of `user`. In PostgreSQL, a role with the login attribute is called a user. Ideal access control is achieved by properly distinguishing between roles as sets of privileges (group roles) and roles with the ability to log in (user roles).

For example, you can create a group role that combines access privileges for multiple tables required to operate a service (such as allowing updates on table A while allowing only reference access on table B), and then grant that group role to a specific administrative user. This allows you to respond flexibly when reviewing users or changing a service (such as reviewing the table structure).

In this textbook, following the goal of simply connecting to the database and learning the basics of SQL, we emphasize the concept of a user used at login and explain this as creating users.

### Superusers
When a database is initialized for the very first time, a user is created with all privileges on the database. This is called a superuser. You can think of it as being like the `root` user in Linux or the `Administrator` user in Windows.

In PostgreSQL, the superuser is created with the name of the OS user on Linux that initialized the database (executed the `initdb` command). By convention, this user is named `postgres`.

## Connections and Authentication
When using PostgreSQL in a multi-user environment, connections to PostgreSQL from outside over a network and authentication at connection time are required. These are not configured by default, so this section explains how to configure them.

### Reviewing Connection Authentication Settings
Connection authentication settings in PostgreSQL are described in `pg_hba.conf`, one of the configuration files. By default, the configuration is written as follows.

```
[postgres@host1 ~]$ cat /var/lib/pgsql/data/pg_hba.conf
(output omitted)
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            ident
# IPv6 local connections:
host    all             all             ::1/128                 ident
(output omitted)
```

The settings for each item are as follows from left to right.

- Connection method (TYPE)
Specifies how the client connects to PostgreSQL.

| Connection type | Description
|---|---
| local | connection from the same host where PostgreSQL is running |
| host | connection from outside using TCP/IP |
| hostssl | connection from outside using SSL |

- Database (DATABASE)
Specifies the database subject to connection authentication. If `all` is written, all databases are targeted.

- User (USER)
Specifies the user subject to connection authentication. If `all` is written, all users are targeted.

- Client address (ADDRESS)
Specifies the address of the client allowed to connect. If omitted, all clients are targeted.

- Authentication method (METHOD)  
Specifies the authentication method.

| Authentication method | Description
|---|---
| trust | connect without authentication |
| reject | reject the connection |
| scram-sha-256 | SCRAM authentication |
| md5 | MD5 password authentication |
| password | plain-text password authentication |
| gss | GSSAPI authentication |
| sspi | SSPI |
| ident | IDENT authentication |
| peer | peer authentication |
| ldap | LDAP authentication |
| radius | RADIUS authentication |
| cert | SSL client certificate authentication |
| pam | PAM authentication |
| bsd | BSD authentication |

In the practice environment configuration, peer authentication is configured for localhost connections (`local`) for all databases and users. Peer authentication verifies that the OS user name matches the database user name.

### Specifying the Connection User
When connecting to a database with `psql`, you normally need to specify which user to connect as. However, if it is not specified explicitly, the Linux user name that ran `psql` is implicitly used.

You can check the connection user by executing the `\set` meta-command and looking at the value of the `USER` variable.

In the following example, you can verify from the result of the `id` command that the Linux user name is `postgres`, and that the connection user is also `postgres`. Because only `ossdb` is specified as the database name for `psql`, you can see that the OS user `postgres` who executed the command is implicitly specified as the connection user.

```
[postgres@host1 ~]$ id
uid=1001(postgres) gid=1001(postgres) groups=1001(postgres) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[postgres@ host1 ~]$ psql ossdb
psql (13.14)
Type "help" for help.

ossdb=# \set
Unnecessary settings have been removed.
DBNAME = 'ossdb'
USER = 'postgres'
```

Next is an example of connecting as user `sato`. The user name to use for the connection is specified as the second argument to `psql`. Because peer authentication is used, the connection fails.

```
[postgres@host1 ~]$ psql ossdb sato
psql: error: FATAL:  Peer authentication failed for user "sato"
```

## Configuring Password Authentication
Now let's configure password authentication so that you can connect to the database using different user names.

### Setting User Passwords
Once password authentication is enabled, users without a password set will no longer be able to connect to the database, so first set passwords for the users.

For existing users, set the password with the `ALTER USER` statement. Because the initial user `postgres` does not have a password set, you should normally perform this operation immediately after installation.

The syntax for setting a password with the `ALTER USER` statement is as follows.

```
ALTER USER user_name PASSWORD 'password'
```

In the following example, the password for user `postgres` is set to `postgres`.

```
ossdb=# ALTER USER postgres PASSWORD 'postgres';
ALTER ROLE
```

### Configuring Password Authentication
Now let's configure the database to use password authentication when connecting. To configure password authentication, change the authentication method in `pg_hba.conf` from `peer` to `md5`. Make this setting change while logged in as the OS user `postgres`.

```
[postgres@host1 ~]$ vi /var/lib/pgsql/data/pg_hba.conf
(output omitted)
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5  ← changed from peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5  ← changed from peer
# IPv6 local connections:
host    all             all             ::1/128                 md5  ← changed from peer
```

The changed settings do not take effect until PostgreSQL is restarted (or the settings are reloaded). Be careful: if you reload this configuration without setting passwords first, peer authentication will be disabled and you will no longer be able to connect to the database.

### Reloading Settings
For each PostgreSQL setting, the timing at which the setting takes effect is defined. Most parameters are read at startup, while settings in `pg_hba.conf` and some other parameters are applied when the settings are reloaded.

In the following example, the OS administrative user `admin` reloads the PostgreSQL configuration with the `systemctl` command. Note that the OS user is not `postgres`.

```
[admin@host1 ~]$ sudo systemctl reload postgresql
```

When PostgreSQL is stopped or restarted while other users are using the database, by default running operations are interrupted and shutdown takes priority. It is important to schedule maintenance windows so that important processing is not affected, but methods are also provided that can minimize the impact on other processing, such as reloading settings.

### Connecting with Password Authentication
Verify that password authentication has been enabled.

In the following example, the connection as user `postgres` is checked.

```
[postgres@host1 ~]$ psql ossdb
Password for user postgres:  *enter postgres
psql (13.14)
Type "help" for help.

ossdb=#
```

### Other Users
Set passwords for other users as well so that they can connect.

In the following example, a password is set for user `sato`, and the connection user is switched to `sato`.

```
ossdb=# ALTER USER sato PASSWORD 'postgres';
ALTER ROLE
ossdb=# \q
[postgres@host1 ~]$ psql ossdb sato
Password for user sato:  *enter postgres
psql (13.14)
Type "help" for help.

ossdb=>
```

The `psql` prompt is `=>` rather than `=#`, which indicates that user `sato` is a regular user rather than a superuser.

## Connections over a Network
PostgreSQL can also accept connections over a network using TCP/IP.

To accept connections over a network, configure `listen_addresses` in `postgresql.conf` and restart PostgreSQL.

By default, `listen_addresses = 'localhost'` is set, so only local loopback connections on the host where PostgreSQL is running are enabled. By setting the value to `*` (asterisk), PostgreSQL will accept connections from all interfaces provided by the host. If you want to accept connections only from a specific interface, specify the IP address configured on that interface.

The listening port number is set to `5432` by default. If you want to change the port number, change the value of `port`.

In the following example, PostgreSQL is configured to accept connections from all interfaces.
```
[postgres@host1 ~]$ vi /var/lib/pgsql/data/postgresql.conf
(output omitted)
#listen_addresses = 'localhost'         # what IP address(es) to listen on;
listen_addresses = '*'          # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
#port = 5432                            # (change requires restart)
(output omitted)
```

At the same time, configure connection authentication as well. Set the `host` access control in `pg_hba.conf`.

In the following example, it is configured to use password authentication when accessing over a network from the local loopback addresses (`127.0.0.1/32` and `::1/128`). Reloading is sufficient to apply changes to `pg_hba.conf`, but this time `postgresql.conf` has also been changed, so PostgreSQL must be restarted to apply the settings.
```
[postgres@host1 ~]$ vi /var/lib/pgsql/data/pg_hba.conf
(output omitted)
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
(output omitted)
```

### Restarting PostgreSQL
Restart PostgreSQL to apply the configuration changes.

In the following example, the OS administrative user `admin` restarts PostgreSQL with the `systemctl` command. Note that the OS user is not `postgres`.

```
[admin@host1 ~]$ sudo systemctl restart postgresql
```

### Network Connections Using psql
To connect to PostgreSQL over a network with `psql`, specify the host name with `-h`, the port number with `-p`, and the user name with `-U` (uppercase). The combination of user, database, and client terminal must be allowed in `pg_hba.conf`.

```
psql -h hostname -p port_number -U user_name database_name
```

In the following example, a network connection is made to the server's local loopback address (`127.0.0.1`). This connection path differs from the local connections used so far (UNIX domain socket connections) and local loopback address connections (TCP/IP connections).

```
[postgres@host1 ~]$ psql -h localhost -p 5432 -U postgres ossdb
Password for user postgres:  *enter postgres
psql (13.14)
Type "help" for help.

ossdb=#
```

## Access Privileges
When multiple users can connect to a single database, you can control operations on tables and other objects by setting access privileges.

### Granting Access Privileges
Use the `GRANT` statement to grant access privileges.

The syntax of the `GRANT` statement is as follows.

```
GRANT {ALL | SELECT | INSERT | DELETE | UPDATE}
	ON object TO {user | PUBLIC}
```

In the following example, all privileges on the `prod` table are granted to user `sato`. The operation is performed by the `postgres` user, which is the owner of the `prod` table, and privileges are granted to user `sato`.

```
ossdb=# \dt prod
          List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | prod | table | postgres
(1 row)

ossdb=# GRANT all ON prod TO sato;
GRANT
```

### Checking Access Privileges
Use the `\dp` meta-command to check access privileges.
```
ossdb=# \dp prod
                                 Access privileges
 Schema | Name | Type  |       Access privileges       | Column privileges | Policies
--------+------+-------+-------------------------------+-------------------+----------
 public | prod | table | postgres=arwdDxt/postgres+    |                   |
        |      |       | sato=arwdDxt/postgres         |                   |
(1 row)
```

Access privilege notation is as follows.

```
user_granted_privileges=privilege_types/user_who_granted_the_privileges
```

When the user granted the privileges is blank, it indicates that the privileges are granted to `public` (all users).
`/postgres` after the access privileges indicates the user who granted the privileges. This will be the table owner or a user who is allowed to perform the corresponding operation.

Privilege type | Description
---- | -------
a	| INSERT (Append)
r	| SELECT (Read)
w	| UPDATE (Write)
d	| DELETE
D	| TRUNCATE
x	| REFERENCES
t	| TRIGGER

The `REFERENCES` privilege requires privileges on both tables when creating a foreign key constraint.

The `TRIGGER` privilege is the privilege that allows creation of a trigger on a table, which is a feature that performs another process when an operation on the table acts as a trigger.

### Revoking Access Privileges
Use the `REVOKE` statement to revoke granted access privileges.

The syntax of the `REVOKE` statement is as follows.

```
REVOKE {ALL | SELECT | INSERT | DELETE | UPDATE}
	ON object FROM {user|PUBLIC}
```

In the following example, all privileges on the `prod` table are revoked from user `sato`.
```
ossdb=# REVOKE all ON prod FROM sato;
REVOKE
ossdb=# \dp prod
                                 Access privileges
 Schema | Name | Type  |       Access privileges       | Column privileges | Policies
--------+------+-------+-------------------------------+-------------------+----------
 public | prod | table | postgres=arwdDxt/postgres     |                   |
(1 row)
```

## Transactions
A transaction is a unit consisting of one or more operations on the database. A transaction starts (`BEGIN`) when processing against the database begins, and it continues until a `COMMIT`, which finalizes the result of the grouped processing, or a `ROLLBACK`, which discards the processing.

The SQL statements used so far to operate PostgreSQL had auto-commit (`AUTOCOMMIT`) enabled by default, so a `COMMIT` was automatically issued whenever all operations succeeded. To disable auto-commit, you must execute the `psql` meta-command `\set AUTOCOMMIT=off` or explicitly start a transaction with `BEGIN`.

In the following example, one row is `INSERT`ed into the `customer` table, and because it is started with `BEGIN`, it is executed as a transaction. One example ends with `ROLLBACK`, where the `INSERT` is canceled, and another ends with `COMMIT`, where the inserted result is finalized.

```
ossdb=# BEGIN;
BEGIN
ossdb=# INSERT INTO customer VALUES (5,'Tanaka Industries');
INSERT 0 1
ossdb=# SELECT * FROM customer WHERE customer_id = 5;
 customer_id |  customer_name
-------------+------------------
           5 | Tanaka Industries
(1 row)

ossdb=# ROLLBACK;
ROLLBACK
ossdb=# SELECT * FROM customer WHERE customer_id = 5;
 customer_id | customer_name
-------------+---------------
(0 rows)
```

You can confirm that the transaction was rolled back and the `INSERT` was canceled.

In the following example, the transaction is committed.

```
ossdb=# BEGIN;
BEGIN
ossdb=# INSERT INTO customer VALUES (5,'Tanaka Industries');
INSERT 0 1
ossdb=# COMMIT;
COMMIT
ossdb=# SELECT * FROM customer WHERE customer_id = 5;
 customer_id |  customer_name
-------------+------------------
           5 | Tanaka Industries
(1 row)
```

The transaction was committed, and the `INSERT` was finalized.

### Read Consistency
Read consistency means that data updates performed within a transaction do not affect other query transactions unless they are committed and finalized.

In the following example, a transaction is first started in one database connection. The price of `melon` is updated to 120 yen. Without doing either `COMMIT` or `ROLLBACK`, querying the `prod` table from another session in the middle of the transaction returns the original 100 yen. After the update transaction is finalized, other sessions can also see the updated 120 yen.
```
ossdb=# SELECT * FROM prod WHERE prod_id = 3;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   100
(1 row)

ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = 120 WHERE prod_id = 3;
UPDATE 1
ossdb=# SELECT * FROM prod WHERE prod_id = 3;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   120
(1 row)
```

Without committing, open another terminal, connect to the database, and try running a query.

```
[postgres@host1 ~]$ psql ossdb
Password for user postgres:
psql (13.14)
Type "help" for help.

ossdb=# SELECT * FROM prod WHERE prod_id = 3;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   100
(1 row)
```

The row data from before the `COMMIT` is queried.

Return to the terminal where the transaction was being executed and finalize the transaction.

```
ossdb=# COMMIT;
COMMIT
```

Now go back to the newer terminal again and try running the query once more.

```
* The following is the previous execution result
ossdb=# SELECT * FROM prod WHERE prod_id = 3;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   100
(1 row)
* The following is the execution result after `COMMIT` is executed in another terminal
ossdb=# SELECT * FROM prod WHERE prod_id = 3;
 prod_id | prod_name | price
---------+-----------+-------
       3 | melon     |   120
(1 row)
```

![Read consistency](./Pict/tx-01.png)

\pagebreak

In this way, even if the first transaction has added row data, that added row data is not visible from another transaction before the transaction is committed. If it were visible and was later rolled back, you would end up reading row data that ultimately does not exist. Reading row data before it is committed in this way is called a dirty read.

PostgreSQL maintains read consistency so that dirty reads do not occur. Although this section does not go into detail, as shown in the figure, PostgreSQL also controls old rows by skipping them after an update is finalized.

### Locking Mechanisms and Update Conflicts
The database locks the target of an earlier transaction to protect it from being overwritten by other transactions. If another transaction tries to update a locked data row, an update conflict occurs, and the processing waits until the lock is released by `COMMIT` or `ROLLBACK`.

In the following example, one transaction first updates a row in the `prod` table.

```
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.1 WHERE prod_id = 1;
UPDATE 1
ossdb=# SELECT * FROM prod WHERE prod_id =1;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    55
(1 row)
```

Update the same row in the `prod` table from another terminal.

```
ossdb=# SELECT * FROM prod WHERE prod_id =1;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    50
(1 row)

ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.2 WHERE prod_id = 1;
* No result is returned, and control does not come back
```
![Update conflict](./Pict/tx-02.png)

When the second `UPDATE` statement is executed, an update conflict occurs and it waits until the previous transaction completes.

As shown below, when the previous transaction is committed or rolled back, the lock is released and the update in the `UPDATE` statement executed later completes.

```
* The following is the previous execution result
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.1 WHERE prod_id = 1;
UPDATE 1
ossdb=# SELECT * FROM prod WHERE prod_id =1;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    55
(1 row)
* `ROLLBACK` is executed below
ossdb=# ROLLBACK;
ROLLBACK
```

You can verify that when the previous transaction is rolled back, the update in the `UPDATE` statement executed later completes.

```
* The following is the previous execution result
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.2 WHERE prod_id = 1;
* No result is returned, and control does not come back
* When `ROLLBACK` is executed in another terminal, the `UPDATE` completes
UPDATE 1
ossdb=*# SELECT * FROM prod WHERE prod_id =1;
 prod_id | prod_name | price
---------+-----------+-------
       1 | orange    |    60
(1 row)

ossdb=# COMMIT;
COMMIT
```

Because the value of the `price` column when the later `UPDATE` statement was executed was 50, it was updated to 60, which is 1.2 times that value.

### Deadlocks
What happens if two transactions each try to update a data row locked by the other and the update conflicts occur at the same time? This state, in which transactions stop while waiting for each other to release locks, is called a deadlock.

When a deadlock occurs in PostgreSQL, one of the transactions is failed and forcibly rolled back. The locks held by that transaction are then released, allowing the other transaction to complete normally.

In the following example, a deadlock is generated by two transactions.

First, one transaction updates the row in the `prod` table where the value of the `prod_id` column is 1.

```
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.1 WHERE prod_id = 1;
UPDATE 1
```

Next, a transaction executed in another terminal updates the row in the `prod` table where the value of the `prod_id` column is 2.
```
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.1 WHERE prod_id = 2;
UPDATE 1
```

Next, the previous transaction updates the row in the `prod` table where the value of the `prod_id` column is 2. Because this row has already been updated and locked by the other transaction, an update conflict occurs.

```
* The following is the previous execution result
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.1 WHERE prod_id = 1;
UPDATE 1
* Execute an `UPDATE` that causes an update conflict
ossdb=# UPDATE prod SET price = price * 1.2 WHERE prod_id = 2;
* No result is returned, and control does not come back
```

When the other transaction tries to update the row in the `prod` table where the value of the `prod_id` column is 1, which is being updated by the previous transaction, a deadlock occurs and the transaction is rolled back. As a result, the previous transaction is released from waiting on the lock and the update is executed.

```
* The following is the previous execution result
ossdb=# BEGIN;
BEGIN
ossdb=# UPDATE prod SET price = price * 1.1 WHERE prod_id = 2;
UPDATE 1
* Execute an `UPDATE` that causes a deadlock
ossdb=# UPDATE prod SET price = price * 1.2 WHERE prod_id = 1;
ERROR:  deadlock detected
DETAIL:  Process 43233 waits for ShareLock on transaction 599; blocked by process 43040.
Process 43040 waits for ShareLock on transaction 600; blocked by process 43233.
HINT:  See server log for query details.
CONTEXT:  while updating tuple (0,8) in relation "prod"
```

When the deadlock is detected and the transaction is forcibly rolled back, the `UPDATE` that had encountered the update conflict is executed.

```
ossdb=# BEGIN;
BEGIN
ossdb=*# UPDATE prod SET price = price * 1.1 WHERE prod_id = 1;
UPDATE 1
ossdb=*# UPDATE prod SET price = price * 1.2 WHERE prod_id = 2;
UPDATE 1
```

![Deadlock](./Pict/tx-03.png)

\pagebreak

Several methods are discussed for preventing deadlocks or minimizing their impact, but it is also said to be difficult to prevent them completely.

One strong approach is to keep the update order consistent when updates are required in multiple places. As in the example, if the rows to be updated cross each other, deadlocks are more likely to occur. In the example above, if you define a rule such as "update in order from the smaller `prod_id` value," the later transaction will wait on the first update, so no deadlock occurs.

Another important point is to end transactions as quickly as possible so that the time during which a transaction locks data rows is kept short. The shorter the transaction time, the less likely a deadlock is to occur.

However, depending on the application, it may not be easy to decide which has the smaller `prod_id`, and in large-scale development there may also be cases where such rules are not followed. The example above involves multiple rows in the same table, but deadlocks can also occur across multiple tables, or can be caused unintentionally by indexes and constraints.

\pagebreak
