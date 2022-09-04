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

# Install docker
amazon-linux-extras install docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Start docker with system
systemctl enable docker
service docker start

# Install nginx
amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

echo End: update and install packages

