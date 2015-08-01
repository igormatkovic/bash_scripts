#!/usr/bin/env bash

#!/usr/bin/env bash

#
# Create a new  Website
#
#
#
#  sh host.sh example.com example
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
    root \"/var/www/domains/$2\";

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
        fastcgi_param PHP_VALUE "newrelic.appname=$1";
        fastcgi_param PHP_VALUE "newrelic.capture_params=true";
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
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
