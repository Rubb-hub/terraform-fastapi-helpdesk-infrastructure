#!/bin/bash 
#Necesary for the user_data script to run on instance launch.

#update and upgrade the system packages
set -e

apt-get update
apt-get upgrade -y

#Install Docker and Docker Compose
apt-get install -y \
  ca-certificates \
  curl \
  git

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

cd /home/ubuntu

git clone https://github.com/Rubb-hub/fastapi-helpdesk-api.git

cd fastapi-helpdesk-api

cp .env.example .env

docker compose up -d --build