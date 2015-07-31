#!/usr/bin/env bash

#
# Create a new Supervisord Worker
#
# run: sh create_supervisor.sh $name "$my_command"
# example: sh create_supervisor.sh textbookapp "php /var/www/domains/loanapp/artisan queue:listen beanstalkd --timeout=60 --sleep=10 --quiet --tries=3 --queue='default'"
#

block="[program:$1]
command=$2
autostart=true
autorestart=true
user=forge
redirect_stderr=true
stdout_logfile=/var/log/supervisor-$1.log"

echo "$block" > "/etc/supervisor/conf.d/$1.conf"
service supervisor restart
