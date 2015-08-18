# Bash Scripts for repetitive tasks

These bash scripts are just small helpers i use when setting up a server.
In the files i have hardcoded some paths because i make a few assumptions.
  - All domains are stored in: /var/www/domains
  - Backups are stored in: /var/www/backups
  - Certificates are stored in: /var/www/certs


## Instructions

To Provision a server with:
 - mysql 5.6
 - php5.6 (nginx + php5-fpm)
 - mongodb 3.0
 - memcached
 - nodejs
 - beanstalk (queues)
 - supervisord

### Provision Server
```sh
sh provision.sh my.main.hostname.com MyMysqlPassword
```


### Create Host (port 80)
```sh
sh host.sh example.com example_dir
```

### Create Host (port 443)

This will look for the certificate and the certificate key named:
 - /var/www/certs/example.com.crt
 - /var/www/certs/example.com.key

```sh
sh ssl_host.sh example.com example_dir
```

### Backup Files

My preference is to backup files for the entire week.
And I also like to back it up without compression. So if a file or two are missing for some reason
I can easily find it and move it back.
The backup will create a new folder and specify the day number of the week.
0 is monday, 1 is tuesday, 2 is wed... etc..
So just stick the command into a cronjob and that's it...
As the week passes. The old ones will be overwrite by itself.

**Example**
 - /var/www/backups/files/example.com/1/*

```sh
sh filebackup.sh example.com
```


### Backup MongoDB

This script assumes that you don't have a password on your MongoDatabase
Since this is a database. It will backup multiple version on the same day.
Since DB is more dynamic then files. The backup creates multiple files.
It uses the same Week logic as file backup but adds a hour so you can store multiple version.
As the week passes. The old ones will be overwrite by itself.

**Example**
 - /var/www/backups/db/example.com/1_14.tar.gz

```sh
sh mongobackup.sh example_db
```


### Create Supervisor

This create a new Supervisor conf.
This creates a default conf only with the name and the command. Anything extra you have to do it manually for now.

```sh
sh supervisor.sh example_job "sh run/my/queue.sh"
```


