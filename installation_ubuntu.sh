#!/bin/bash
# Server installation
# Home automation tools on UBUNTU

### Uninstall old docker versions
sudo apt-get remove docker docker-engine docker.io containerd runc

### Intall Docker
echo "Installing Docker"
sleep 5

### SET UP THE REPOSITORY
echo "Update the apt package index and install packages to allow apt to use a repository over HTTPS"
sleep 5

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

echo "Add Docker’s official GPG key"
sleep 5
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "set up the stable repository"
sleep 5
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

### INSTALL DOCKER ENGINE
echo "Update the apt package index, and install the latest version of Docker Engine and containerd"
sleep 5

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

echo "Start docker and enable start docker on boot"
sleep 5
sudo systemctl start docker 
sudo systemctl enable docker 

echo "Add current user to Docker sudogroup"
sleep 5
sudo groupadd docker 
sudo usermod -aG docker ${USER}

### Install docker-compose
echo "Installing Docker-Compose"
sleep 5

sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
    
### Home Assistant
echo "Building Home Assistant docker image"
sleep 5
cd home-assistant
docker build -t prd-home-assistant .
cd ..

### Run Docker-compose
#docker-compose up -d
