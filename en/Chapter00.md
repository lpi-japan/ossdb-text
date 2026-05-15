
# Preface {.unlisted .unnumbered}
LPI Japan (NPO) has developed and is now publishing on the Internet the "Open Source Database Standard Textbook" (hereinafter, this textbook), with the goal of having it used for education in open source database technologies.

This textbook was developed for people learning about databases for the very first time, in response to the growing need to acquire database skills. It is one title in the standard textbook series, which also includes the already released and well-received "Linux Standard Textbook," "Linux Server Construction Standard Textbook," "Linux System Administration Standard Textbook," "High Availability System Construction Standard Textbook," and "Linux Security Standard Textbook."

For publication, this textbook is released under the license attached to it (Creative Commons License: Attribution - Non-Commercial - No Derivatives).

This material will be updated from time to time to keep up with the latest technology trends.

For the latest information on this textbook, please refer to the following web page.

Open Source Database Standard Textbook
```
https://oss-db.jp/ossdbtext
```

## Purpose of this textbook {.unlisted .unnumbered}
The purpose of this textbook is to help engineers with no database experience learn basic database operations through hands-on exercises. You will learn the basics of operating a database using SQL statements, as well as creating and administering databases.

It is also useful for education and study toward obtaining the certification "OSS-DB Silver," which proves your skills as a database engineer working with PostgreSQL.

## Assumed practice environment {.unlisted .unnumbered}
This textbook uses the following environment for hands-on exercises.

### Database {.unlisted .unnumbered}
This textbook uses PostgreSQL version 13. Since there is very little content that depends on the version, you can also study with other versions, although some displayed output and other details may differ.
Installation is performed from packages, but you may also install it yourself from source code.

### Shared environment with the "Linux Server Construction Standard Textbook" {.unlisted .unnumbered}
This textbook assumes that you will proceed with the hands-on exercises using the virtual machine and installed OS created in the sister volume, the "Linux Server Construction Standard Textbook." For specific instructions on how to build the environment, refer to Chapters 1 through 3 of the "Linux Server Construction Standard Textbook."

Linux Server Construction Standard Textbook
```
https://linuc.org/textbooks/server/
```

![https://linuc.org/textbooks/server/](Pict/linuxserver.png){width=20%}

### Using a virtual machine {.unlisted .unnumbered}
You will build the learning environment using a virtual machine. By using a virtual machine, you can install and run Linux on a virtual machine running on Windows, Linux, or macOS.

In the "Linux Server Construction Standard Textbook," VirtualBox is run on Windows. In this textbook, you can do the hands-on exercises with any virtual machine software.

### OS {.unlisted .unnumbered}
This textbook uses AlmaLinux version 9.3 as the Linux distribution.

The examples use a version compatible with the Intel/AMD x86_64 architecture, but you can also do the hands-on exercises with versions for other architectures such as ARM.

Any other distribution or OS is acceptable as long as PostgreSQL version 13 can run on it.

To download a PostgreSQL installer that runs on an OS other than Linux, please refer to the following web page.

```
https://www.postgresql.jp/download
```

### Network {.unlisted .unnumbered}
The network used for the hands-on exercises is assumed to be able to connect to the Internet.

If you cannot connect to the Internet, you can still proceed with the hands-on exercises by installing in advance the software required for the exercises during OS installation. Please install the software in advance according to the instructions in the OS installation guide. If you have already installed the OS, you can mount the ISO image used for OS installation and install from the required packages.

### Cloud environment  {.unlisted .unnumbered}
Another option is to use an environment prepared in the cloud. If PostgreSQL is installed in an environment running AlmaLinux or another Linux distribution, you can study the contents of this book.

## Overview {.unlisted .unnumbered}
In this textbook, the hands-on exercises proceed as follows.

### Chapter 1&nbsp;How to Build the Practice Environment {.unlisted .unnumbered}
Install PostgreSQL and create the database used in the hands-on exercises.

### Chapter 2&nbsp;Database Operations with SQL: Basics {.unlisted .unnumbered}
Learn the basic operations of a database through hands-on exercises.

### Chapter 3&nbsp;Data Types {.unlisted .unnumbered}
Learn about the various data types handled by a database.

### Chapter 4&nbsp;Tables {.unlisted .unnumbered}
Learn about tables, which store data in a database.

### Chapter 5&nbsp;Basic Exercises {.unlisted .unnumbered}
Review what you learned in the first half through exercises.

### Chapter 6&nbsp;Database Operations with SQL: Advanced {.unlisted .unnumbered}
Learn more detailed database operations.

### Chapter 7&nbsp;Advanced Database Definition {.unlisted .unnumbered}
Learn more detailed functions associated with creating tables and other database definitions.

### Chapter 8&nbsp;Using the Database with Multiple Users {.unlisted .unnumbered}
Learn about user creation and authentication, which are necessary when working with a database as multiple users.

### Chapter 9&nbsp;Performance Tuning {.unlisted .unnumbered}
Learn about database performance.

### Chapter 10&nbsp;Backup and Restore {.unlisted .unnumbered}
Learn how to back up and restore data.

## Authors and Contributors {.unlisted .unnumbered}
This textbook is developed in an open project style. From the planning stage onward, project members share the work of exchanging ideas, carrying out advance technical research, writing, and reviewing.

### Toru Miyahara (Version 3 author / Begi.net Co., Ltd.) {.unlisted .unnumbered}
This textbook was written with the goal of serving as a guide that even people touching a database for the first time can follow without getting lost, keeping explanations as concise and easy to understand as possible and helping readers understand by actually trying things out.
At the same time, databases are deep software, just like operating systems, so what this textbook can explain is only a very small introduction. In particular, for operations management, performance, and database design, please refer to more detailed books.
I would be very happy if this textbook helps those who pick it up acquire database skills.

More than 10 years have passed since the first edition was published in 2011, but because it was written with an emphasis on explaining standard SQL, the contents remain largely unchanged, and it has now been revised as the third edition. Today, more people study independently using virtual machines and the cloud, so the flow of the hands-on exercises has been adjusted to the current situation, such as creating the database used in the exercises at the beginning.

The SQL statements and other content are provided so that you can use them directly by copy and paste, so please try using the PDF version first to confirm that they work. After working through it once, try reviewing again in a copying-practice style by deliberately typing the SQL statements in by hand.

### Everyone Who Helped Develop the Textbook (3rd Edition) {.unlisted .unnumbered}
This textbook incorporated open source software development methods, and the structure planning and manuscript review were carried out through several face-to-face meetings and communication using Slack.

- Akio Itabashi
- Ushio Inoue (Tokyo Denki University)
- Takahiro Kujirai (Zeus Enterprise Co., Ltd.)
- Toshifumi Takemoto (Internous Inc.)
- Sho Naka (Freelance)
- Akiomi Fukunaga (Bold Co., Ltd.)

We have also received feedback from many authors, reviewers, and users from Version 1 through Version 2. We sincerely thank you all.

## Copyright {.unlisted .unnumbered}
The copyright of this textbook belongs to LPI Japan (NPO).

Copyright©️ LPI-Japan. All Rights Reserved.

## Terms of Use {.unlisted .unnumbered}
This textbook is licensed under the Creative Commons License "Attribution - Non-Commercial - No Derivatives 4.0 International (CC BY-NC-ND 4.0)."

![CC BY-NC-ND 4.0](Pict/by-nc-nd.png){width=200px}


### Attribution {.unlisted .unnumbered}
Please indicate that the copyright of this textbook belongs to LPI Japan (NPO).

### Non-Commercial {.unlisted .unnumbered}
This textbook may be freely used as educational material for non-commercial purposes.

Use for commercial purposes primarily intended for commercial gain or monetary compensation requires permission from LPI Japan (NPO). However, when education using this textbook does not charge for this textbook itself, it may generally be used even for for-profit education.  
In such cases as well, please feel free to contact the LPI-Japan office.

* Use for commercial purposes is defined as follows. 
Conducting training or lectures in a for-profit company or non-profit organization using copies of this textbook while charging students more than the actual printing cost of this textbook for the purpose of commercial gain or monetary compensation.

### No Derivatives {.unlisted .unnumbered}
Please use this textbook without modification. Modifications to this textbook are made by LPI Japan (NPO) or organizations approved by LPI Japan (NPO).

## Feedback {.unlisted .unnumbered}
Feedback is accepted via Slack, which anyone can join, so please participate actively. For details on joining Slack, please refer to the web page for this textbook below.

```
https://oss-db.jp/ossdbtext
```

![https://oss-db.jp/ossdbtext](Pict/ossdbtext.png){width=20%}

\pagebreak

## Contact for Inquiries About Using this textbook {.unlisted .unnumbered}
LPI Japan (NPO) (LPI-Japan) Office  

```
Contact: https://lpij.tayori.com/f/textbookinfo/
```

![https://lpij.tayori.com/f/textbookinfo/](Pict/toiawase.png){width=20%}

## Introduction to OSS-DB Certification {.unlisted .unnumbered}
OSS-DB Certification is an IT engineer certification that fairly, rigorously, and neutrally certifies technical ability and knowledge related to open source databases. Among open source databases, this exam uses "PostgreSQL" as its reference database, particularly because it excels at integration with commercial databases and is widely used in enterprise systems.


```{=latex}
\begin{center}
```

![](Pict/ossdblogo.png){width=25%}

```{=latex}
\end{center}
```

OSS-DB Certification consists of two levels.

### OSS-DB Silver {.unlisted .unnumbered}
It certifies that you are an engineer capable of designing, developing, implementing, and operating database systems. In particular, it certifies that you have skills in the following areas.

- Have basic knowledge of open source databases.
- Can perform basic operations management of open source databases such as PostgreSQL.
- Can perform SQL operations and transaction management on open source databases such as PostgreSQL.

### OSS-DB Gold {.unlisted .unnumbered}
It certifies that you are an engineer capable of improving, operating, administering, and consulting on large-scale database systems. In particular, it certifies that you have skills in the following areas.

- Have deep knowledge of open source databases.
- Can perform advanced operations management of open source databases such as PostgreSQL.
- Can check statistics and SQL execution plans for open source databases such as PostgreSQL.
- Can verify the state of open source databases such as PostgreSQL and perform performance tuning.
- Can verify the state of open source databases such as PostgreSQL and perform troubleshooting.

\pagebreak

For details on OSS-DB Certification, please refer to the following website.

![https://oss-db.jp/outline](Pict/outline.png){width=20%}

## Other Information Sources {.unlisted .unnumbered}
- Japan PostgreSQL Users Group (JPUG)
[https://www.postgresql.jp/](https://www.postgresql.jp/)

- PostgreSQL manual ("Japanese Documentation" from the JPUG site)
[https://www.postgresql.jp/document/](https://www.postgresql.jp/document/)

- Mailing list (pgsql-jp)
[https://www.postgresql.jp/npo/mailinglist](https://www.postgresql.jp/npo/mailinglist)

- Let's PostgreSQL
[https://lets.postgresql.jp/](https://lets.postgresql.jp/)

In addition, many books and other resources have been published, so please refer to them as well.

\pagebreak

