#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo Begin: user-data

echo Begin: update and install packages

yum update -y

# Install pre-reqs
sudo yum install -y jq
sudo yum install -y dos2unix
sudo yum install -y wget
sudo yum install -y nano
sudo yum install -y httpd httpd-tools mod_ssl


# Start httpd/php with system
# sudo systemctl enable httpd
# sudo systemctl start httpd

# Install php
# sudo yum install amazon-linux-extras -y
# sudo amazon-linux-extras enable php7.4
# sudo yum clean metadata
# sudo yum install php php-common php-pear -y
# sudo yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} -y

# Install nginx
amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo End: update and install packages
