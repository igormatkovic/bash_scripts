#!/usr/bin/env bash

#
# Create a new SSL Website with certificates
#
# Make sure the SSL cert has the same name as the server_name.
# for example.com the certs should be:
# /var/www/certs/example.com.crt
# /var/www/certs/example.com.key
#
#
#  sh ssl_host.sh example.com example
#
# params:
#
#   - server_name: (example.com)
#   - path: (example_folder)
#
#

block="server {
    listen 80;
    server_name $1 www.$1;
    return 301 https://$1$request_uri;
}

server {
    listen 443;
    server_name $1 www.$1;
    root \"/var/www/domains/$2\";


    ssl on;
    ssl_certificate /var/www/certs/$1.crt;
    ssl_certificate_key /var/www/certs/$1.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param PHP_VALUE \"newrelic.appname=$1\";
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
    }

    location ~ /\.ht {
        deny all;
    }
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
service nginx restart
service php5-fpm restart
