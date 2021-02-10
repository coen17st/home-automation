#!/bin/bash

# CHANGE THE VARIABLES BELOW TO YOUR NEEDS (OPTIONAL)
base_dir="${HOME}/docker"

# DON'T CHANGE ANYTHING BELOW
home_automation_tools_repository="https://github.com/coen17st/home-automation-tools.git"
home_automation_tools_dir="${base_dir}/home-automation-tools"
home_assistant_config_repository="https://github.com/coen17st/home-assistant-config.git"
home_assistant_config_dir="${base_dir}/home-assistant-config"
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

# MAKE DOCKER DIRECTORY IN HOME FOLDER
mkdir ${base_dir} 2>/dev/null


# UPDATE AND UPGRADE SYSTEM
printf "${color_green}Update system\n${color_no}"
sleep ${sleepseconds}
sudo apt update -y \
&& sudo apt upgrade -y
printf "\n"


# PULL OR CLONE HOME ASSISTANT FROM GITHUB
if cd ${home_assistant_config_dir}/.git 2>/dev/null
then 
printf "${color_green}Updating Home Assistant Config repository\n${color_no}"
cd ${home_assistant_config_dir} \
&& git config pull.rebase false
else 
printf "${color_green}Home Assistant Config repository not found, downloading it now\n${color_no}"
cd ${base_dir} \
&& git clone ${home_assistant_config_repository}
printf "\n\n"
fi


# PULL OR CLONE HOME AUTOMATION TOOLS FROM GITHUB
if cd ${home_automation_tools_dir}/.git 2>/dev/null
then 
printf "${color_green}Updating Home Automation Tools repository\n${color_no}"
cd ${home_automation_tools_dir} \
&& git config pull.rebase false
else 
printf "${color_green}Home Automation Tools repository not found, downloading it now\n${color_no}"
cd ${base_dir} \
&& git clone ${home_automation_tools_repository}
printf "\n\n"
fi
printf "\n"


# CREATE DEFAULT .ENV FILE FOR HOME AUTOMATION TOOLS, THIS FILE WILL BE USED IN DOCKER-COMPOSE
if [ ! -f "${home_automation_tools_dir}/.env" ]; 
then
cat << EOF > ${home_automation_tools_dir}/.env
### MARIADB ###
MYSQL_USER=
MYSQL_ROOT_PASSWORD=
MYSQL_PASSWORD=
MYSQL_DATABASE=

### PLEX ###
PLEX_CLAIMTOKEN=
EOF
fi


# ASK USER FOR VARIABLES:
# MYSQL USER
if grep -qFx "MYSQL_USER=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a MYSQL USER:${color_no}"
read mysql_user
sudo sed -i "s/MYSQL_USER=/MYSQL_USER=$mysql_user/" ${home_automation_tools_dir}/.env
fi

# MYSQL ROOT PASSWORD
if grep -qFx "MYSQL_ROOT_PASSWORD=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a MYSQL_ROOT_PASSWORD:${color_no}"
read -s mysql_root_password
sudo sed -i "s/MYSQL_ROOT_PASSWORD=/MYSQL_ROOT_PASSWORD=$mysql_root_password/" ${home_automation_tools_dir}/.env
printf "\n"
fi

# MYSQL PASSWORD
if grep -qFx "MYSQL_PASSWORD=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a MYSQL_PASSWORD:${color_no}"
read -s mysql_password
sudo sed -i "s/MYSQL_PASSWORD=/MYSQL_PASSWORD=$mysql_password/" ${home_automation_tools_dir}/.env
printf "\n"
fi

# MYSQL DATABASE
if grep -qFx "MYSQL_DATABASE=" ${home_automation_tools_dir}/.env
then
printf "${color_green}enter a name for the Home Assistant MYSQL_DATABASE:${color_no}"
read mysql_database
sudo sed -i "s/DATABASE=/DATABASE=$mysql_database/" ${home_automation_tools_dir}/.env
fi

# PLEX CLAIM TOKEN
if grep -qFx "PLEX_CLAIMTOKEN=" ${home_automation_tools_dir}/.env
then
printf "${color_green}Enter your Plex Claimtoken, you can obtain a claim token to login your server to your plex account by visiting https://www.plex.tv/claim ${color_no}"
printf "${color_green}\nPLEX CLAIMTOKEN:${color_no}"
read plex_claimtoken
sudo sed -i "s/PLEX_CLAIMTOKEN=/PLEX_CLAIMTOKEN=$plex_claimtoken/" ${home_automation_tools_dir}/.env
printf "\n"
fi


# CHECK IF DOCKER IS INSTALLED
docker --version 2>&1 >/dev/null
if [ $? -ne 0 ]
then
# IF NOT, DOWNLOAD AND INSTALL DOCKER
printf "${color_green}Install docker\n\n${color_no}"
sleep ${sleepseconds}./
sudo apt install docker.io -y
# START/ENABLE DOCKER
sudo systemctl enable --now docker
# SET USER PREVLILEGES
sudo groupadd docker
sudo usermod -aG docker ${USER}
su ${USER}
# CHECK DOCKER VERSION
docker --version
else
# IF DOCKER ALREADY IS INSTALLED SHOW DOCKER VERSION
dockerversion=$(docker --version)
printf "${color_green}${dockerversion} is installed\n\n${color_no}"
fi


# CHECK IF DOCKER-COMPOSE IS INSTALLED
docker-compose --version 2>&1 >/dev/null
if [ $? -ne 0 ]
then
# IF NOT, DOWNLOAD AND INSTALL DOCKER-COMPOSE
printf "${color_green}Installing Docker Compose\n\n${color_no}"
sleep ${sleepseconds}
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# SHOW DOCKER-COMPOSE VERSION
docker-compose --version
else
dockercomposeversion=$(docker-compose --version)
printf "${color_green}${dockercomposeversion} is installed\n\n${color_no}"
fi


# BUILD PORTAINER IMAGE AND START THE CONTAINER
cd ${home_automation_tools_dir} \
&& docker-compose -f docker-compose-portainer.yml up -d 
if [ $? -ne 0 ]
then
printf "${color_green}failed to bring up Portainer\n\n${color_no}"
exit 1
else
printf "${color_green}Portainer succefully running, you can visit it at http://${ip4}:9000\n\n${color_no}"
fi


# BUILD HOME ASSISTANT IMAGE
printf "${color_green}Building custom Home Assistant image\n\n${color_no}"
sleep ${sleepseconds}
# GO INTO HOME-ASSISTANT-CONFIG REPOSITORY DIRECTORY
cd ${home_assistant_config_dir}
# BUILD DOCKER IMAGE
docker build -t prd-home-assistant .
# BACK TO BASE DIR
cd ${base_dir}


# CREATE EMPTY SECRETS.YAML FOR HOME ASSISTANT IF NOT EXISTS
if [ ! -f "${home_assistant_config_dir}/config/secrets.yaml" ] 
then
cat << EOF > ${home_assistant_config_dir}/config/secrets.yaml
### MARIADB ###
db_url: empty
EOF
    if [ $? -ne 0 ]
    then
    printf 'failed to create a empty template secret.yaml for Home Assistant\n\n'
    exit 1
    fi
fi


# BUILD DB_URL SECRET
if [ -f "${home_assistant_config_dir}/config/secrets.yaml" ] \
&& grep -qFx "db_url: empty" ${home_assistant_config_dir}/config/secrets.yaml
then
mysql_user=$(grep 'MYSQL_USER=' ${home_automation_tools_dir}/.env | cut -d "=" -f2)
mysql_password=$(grep 'MYSQL_PASSWORD=' ${home_automation_tools_dir}/.env | cut -d "=" -f2)
mysql_database=$(grep 'MYSQL_DATABASE=' ${home_automation_tools_dir}/.env | cut -d "=" -f2)
sudo sed -i "s|db_url: empty|db_url: mysql://${mysql_user}:${mysql_password}@prd-mariadb/${mysql_database}?charset=utf8|g" ${home_assistant_config_dir}/config/secrets.yaml
    if [ $? -ne 0 ]
    then
    printf 'failed to put the db_url secret in the Home Assistant secret.yaml\n\n'
    exit 1
    fi
fi