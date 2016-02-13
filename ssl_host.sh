#!/usr/bin/env bash

#
# Create a new SSL Website with certificates
#!/usr/bin/env bash

mkdir /etc/nginx/ssl 2>/dev/null
openssl genrsa -out "/var/www/certs/etc/nginx/ssl/$1.key" 1024 2>/dev/null
openssl req -new -key /var/www/certs/$1.key -out /var/www/certs/$1.csr -subj "/CN=$1/O=Vagrant/C=UK" 2>/dev/null
openssl x509 -req -days 365 -in /var/www/certs/$1.csr -signkey /var/www/certs/$1.key -out /var/www/certs/$1.crt 2>/dev/null

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl;
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

    ssl_certificate     /var/www/certs/$1.crt;
    ssl_certificate_key /var/www/certs/$1.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
service nginx restart
service php5-fpm restart
