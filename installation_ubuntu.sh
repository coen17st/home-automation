#!/bin/bash

## change the variables below to your needs

base_dir="${HOME}/docker/"
home_automation_tools_repository="https://github.com/coen17st/home-automation-tools.git"
home_automation_tools_dir="${HOME}/docker/home-automation-tools"
home_assistant_config_repository="https://github.com/coen17st/home-assistant-config.git"
home_assistant_config_dir="${HOME}/docker/home-assistant-config"

## don't change anything below #####################################################

sleepseconds="2"
ip4=$(hostname -I | cut -d' ' -f1)
date=`date '+%Y-%m-%d %H:%M:%S'`
color_blue='\033[1;34m'
color_green='\033[1;32m'
color_no='\033[0m'

clear
printf "${color_blue}"
cat << "EOF"
 _   _                           _         _                        _   _               _____           _     
| | | | ___  _ __ ___   ___     / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __   |_   _|__   ___ | |___ 
| |_| |/ _ \| '_ ` _ \ / _ \   / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \    | |/ _ \ / _ \| / __|
|  _  | (_) | | | | | |  __/  / ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |   | | (_) | (_) | \__ \
|_| |_|\___/|_| |_| |_|\___| /_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|   |_|\___/ \___/|_|___/
==== written by Coen Stam ===================================================================================
EOF
cat << EOF

This script will install the following software on host:
- Docker
- Docker Compose

and the following images on Docker

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

# create default .env file for home automation tools, this file will be used in docker-compose
if [ ! -f "${home_automation_tools_dir}/.env" ]; 
then
cat << EOF > ${home_automation_tools_dir}/.env
### MARIADB ###
#MYSQL_USER=
#MYSQL_ROOT_PASSWORD=
#MYSQL_PASSWORD=

### PLEX ###
#PLEX_CLAIMTOKEN=
EOF
fi

# ask variables - mysql user
if grep -qFx "MYSQL_USER=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a MYSQL USER:${color_no}"
read mysql_user
sudo sed -i "s/MYSQL_USER=/MYSQL_USER=$mysql_user/" ${home_automation_tools_dir}/.env
printf "${color_green}MYSQL USER set correctly\n${color_no}"
fi

# ask variables - mysql root password
if grep -qFx "MYSQL_ROOT_PASSWORD=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a MYSQL_ROOT_PASSWORD:${color_no}"
read -s mysql_root_password
sudo sed -i "s/MYSQL_ROOT_PASSWORD=/MYSQL_ROOT_PASSWORD=$mysql_root_password/" ${home_automation_tools_dir}/.env
printf "\n${color_green}MYSQL_ROOT_PASSWORD set correctly\n${color_no}"
fi

# ask variables - mysql password
if grep -qFx "MYSQL_PASSWORD=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a MYSQL_PASSWORD:${color_no}"
read -s mysql_password
sudo sed -i "s/MYSQL_PASSWORD=/MYSQL_PASSWORD=$mysql_password/" ${home_automation_tools_dir}/.env
printf "\n${color_green}MYSQL_PASSWORD set correctly\n${color_no}"
fi

# ask variables - plex claim token
if grep -qFx "PLEX_CLAIMTOKEN=" ${home_automation_tools_dir}/.env
then
printf "${color_green}You can obtain a claim token to login your server to your plex account by visiting https://www.plex.tv/claim${color_no}"
printf "${color_green}enter your PLEX CLAIMTOKEN:${color_no}"
read plex_claimtoken
sudo sed -i "s/PLEX_CLAIMTOKEN=/PLEX_CLAIMTOKEN=$plex_claimtoken/" ${home_automation_tools_dir}/.env
printf "\n${color_green}PLEX_CLAIMTOKEN set correctly\n${color_no}"
fi

## INSTALL DOCKER

# make docker directory in home folder
mkdir ${base_dir} 2>/dev/null

# update and upgrade system
printf "${color_green}Update system\n\n${color_no}"

sleep ${sleepseconds}
sudo apt update -y
sudo apt upgrade -y

# download and install docker
printf "${color_green}Install docker\n\n${color_no}"
sleep ${sleepseconds}
sudo apt install docker.io -y

# launch docker
sudo systemctl enable --now docker

# set user prevlileges
sudo groupadd docker 
sudo usermod -aG docker ${USER}

# check docker version
docker --version

# install docker-compose
printf "${color_green}Installing Docker Compose\n\n${color_no}"
sleep ${sleepseconds}
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# pull or clone home assistant from github
if cd ${home_assistant_config_dir}/.git
then 
printf "${color_green}Updating Home Assistant Config repository\n\n${color_no}"
cd ${home_assistant_config_dir} \
&& git config pull.rebase false
else 
printf "${color_green}Home Assistant Config repository not found, downloading it now\n\n${color_no}"
cd ${HOME}/docker/ \
&& git clone ${home_assistant_config_repository}
fi

printf "${color_green}Building custom Home Assistant image\n\n${color_no}"
sleep ${sleepseconds}
# go into home-assistant-config repository directory
cd home-assistant-config
# build docker image
docker build -t prd-home-assistant .
# back to base dir
cd ${base_dir}

# pull or clone home automation tools from github
if cd ${home_automation_tools_dir}/.git
then 
printf "${color_green}Updating Home Automation Tools repository\n\n${color_no}"
cd ${home_automation_tools_dir} \
&& git pull
else 
printf "${color_green}Home Automation Tools repository not found, downloading it now\n\n${color_no}"
cd ${HOME}/docker/ \
&& git clone ${home_automation_tools_repository}
fi

# build and start up portainer docker container
cd ${home_automation_tools_dir} \
&& docker-compose -f docker-compose-portainer.yml up -d
if [ $? -ne 0 ]
then
printf "${color_green}failed to bring up Portainer\n\n${color_no}"
exit 1
else
printf "${color_green}Portainer succefully running, you can visit it at http://${ip4}:9000\n\n${color_no}"
fi

# back to base dir
cd ${base_dir}
