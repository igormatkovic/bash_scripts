#!/bin/sh

backup_folder=`date '+%w'`


mkdir -p /var/www/backup/files/$1/${backup_folder}/

#Move files to the backup Folder
rsync -arv /var/www/domains/$1 /var/www/backup/files/$1/${backup_folder}/
