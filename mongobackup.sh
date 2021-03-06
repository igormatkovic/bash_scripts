#!/bin/sh

backup_name=`date '+%w_%H'`


mkdir /var/www/backup/tmp/$1
mkdir /var/www/backup/db/$1

#Dump DB to the current folder
mongodump -d $1 -o /var/www/backup/tmp/$1

#Tar it with the Date Name
cd /var/www/backup/tmp/ && tar -zcvf /var/www/backup/db/$1/${backup_name}.tar.gz $1

rm -rf /var/www/backup/tmp/$1