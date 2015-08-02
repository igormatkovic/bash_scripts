#!/usr/bin/env bash

#
# Server Provision Script
#
# run:
# sh provision.sh $myhostname $mysql_password
#
#
#
# Upgrade The Base Packages

apt-get update
apt-get upgrade -y

# Add A Few PPAs To Stay Current

apt-get install -y software-properties-common

apt-add-repository ppa:nginx/stable -y
apt-add-repository ppa:ondrej/php5-5.6 -y

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list

# Update Package Lists

apt-get update

# Base Packages
apt-get install -y build-essential curl fail2ban gcc git libmcrypt4 libpcre3-dev \
make python-pip supervisor ufw unattended-upgrades unzip whois zsh

# Install Python Httpie
pip install httpie

# Set The Hostname If Necessary
echo "$1" > /etc/hostname
sed -i 's/127\.0\.0\.1.*localhost/127.0.0.1	$1 localhost/' /etc/hosts
hostname $1

# Set The Timezone
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime


# Setup Unattended Security Upgrades

cat --> /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
	"Ubuntu trusty-security";
};
Unattended-Upgrade::Package-Blacklist {
	//
};
EOF

cat > /etc/apt/apt.conf.d/10periodic << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Setup UFW Firewall

ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

# Install Base PHP Packages

apt-get install -y php5-cli php5-dev php-pear \
php5-mysqlnd php5-pgsql php5-sqlite \
php5-apcu php5-json php5-curl php5-dev php5-gd \
php5-gmp php5-imap php5-mcrypt php5-memcached php5-mongo

# Make The MCrypt Extension Available

ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt
sudo service nginx restart

# Install Composer Package Manager

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Misc. PHP CLI Configuration

sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/cli/php.ini



# Install Nginx & PHP-FPM & Mongo

apt-get install -y nginx php5-fpm mongodb-org

# Disable The Default Nginx Site

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
service nginx restart

# Tweak Some PHP-FPM Settings

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
sed -i "s/\;session.save_path = .*/session.save_path = \"\/var\/lib\/php5\/sessions\"/" /etc/php5/fpm/php.ini


# Configure A Few More Server Things

sed -i "s/;request_terminate_timeout.*/request_terminate_timeout = 60/" /etc/php5/fpm/pool.d/www.conf
sed -i "s/worker_processes.*/worker_processes auto;/" /etc/nginx/nginx.conf
sed -i "s/# multi_accept.*/multi_accept on;/" /etc/nginx/nginx.conf


# Restart Nginx & PHP-FPM Services

service php5-fpm restart
service nginx restart



# Install Node

apt-get install -y nodejs

# Install Grunt CLI & Gulp

npm install -g pm2
npm install -g grunt-cli
npm install -g gulp


# Install & Configure Beanstalk

apt-get install -y beanstalkd
sed -i "s/BEANSTALKD_LISTEN_ADDR.*/BEANSTALKD_LISTEN_ADDR=0.0.0.0/" /etc/default/beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start




# Install & Configure Memcached

apt-get install -y memcached
sed -i 's/-l 127.0.0.1/-l 0.0.0.0/' /etc/memcached.conf
service memcached restart


# Upstart Services

update-rc.d memcached defaults
update-rc.d nginx defaults
update-rc.d php5-fpm defaults


if [ ! -v "$2" ]
then
    echo "Mysql Password is not set... Skipping Install"
elif [ ! -z "$2" ]
then
    # Install MySQL
	debconf-set-selections <<< "mysql-server mysql-server/root_password password $2"
	debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $2"

	apt-get  -y install mysql-server-5.6


	# Configure Access Permissions For Root
	sed -i '/^bind-address/s/bind-address.*=.*/bind-address = */' /etc/mysql/my.cnf
	mysql --user="root" --password="$2" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '$2';"
	service mysql restart

	mysql --user="root" --password="$2" -e "FLUSH PRIVILEGES;"
fi

