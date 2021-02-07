#!/bin/bash
# Server installation


sleepseconds="3"
home_automation_tools_repository="https://github.com/coen17st/home-automation-tools.git"
home_assistant_config_repository="https://github.com/coen17st/home-assistant-config.git"
date=`date '+%Y-%m-%d %H:%M:%S'`

cat << "EOF"
 _   _                           _         _                        _   _               _____           _     
| | | | ___  _ __ ___   ___     / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __   |_   _|__   ___ | |___ 
| |_| |/ _ \| '_ ` _ \ / _ \   / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \    | |/ _ \ / _ \| / __|
|  _  | (_) | | | | | |  __/  / ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |   | | (_) | (_) | \__ \
|_| |_|\___/|_| |_| |_|\___| /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|   |_|\___/ \___/|_|___/
==== written by Coen Stam ===================================================================================
=============================================================================================================
EOF
cat << EOF
$date - This script will install the following software on host:
- Docker
- Docker Compose

and the following docker images:

- portainer/portainer-ce:latest
- adminer:latest
- mariadb:latest
- jwilder/nginx-proxy
- jrcs/letsencrypt-nginx-proxy-companion
- plexinc/pms-docker
- Node-RED
- Home Assistant
- eclipse-mosquitto
=============================================================================================================
EOF

# make docker directory in home folder
mkdir ${HOME}/docker/ 2>/dev/null
cd ${HOME}/docker/

# update and upgrade system
echo "Update system"
sleep ${sleepseconds}
sudo apt update -y
sudo apt upgrade -y

# download and install docker
echo "Install docker"
sleep ${sleepseconds}

sudo apt install docker.io -y

# launch docker
sudo systemctl enable --now docker

# set user prevlileges
sudo groupadd docker 
sudo usermod -aG docker ${USER}

# check docker version
docker --version

# Install docker-compose
echo "Installing Docker-Compose"
sleep ${sleepseconds}
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

### Clone Home Automation Tools ###
echo "Clone Home Automation Tools from "$home-automation-tools-repository""
sleep ${sleepseconds}
# go into docker directory
cd ${HOME}/docker/
# git clone 
git clone ${home_automation_tools_repository}
# bring up portainer
docker-compose -f docker-compose-portainer.yml up -d


### Home Assistant ###
echo "Building custom Home Assistant image"
sleep ${sleepseconds}
git clone ${home_assistant_config_repository}
cd home-assistant-config
docker build -t prd-home-assistant .
cd ..