#!/bin/bash
# Server installation
# Home automation tools on CENTOS 7

### Install open SSH
echo "Installing Open SSH-Server"
sudo yum –y install openssh-server openssh-clients \
&& sudo systemctl enable sshd \
&& sudo systemctl start sshd

### Intall Docker
echo "Installing Docker"
sudo yum remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-engine \

sudo yum install -y yum-utils 

sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo 

sudo yum install docker-ce docker-ce-cli containerd.io -y

sudo systemctl start docker 
sudo systemctl enable docker 

sudo groupadd docker 

sudo usermod -aG docker $USER

### Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version
    
### Open firewall ports for Home Assistant
firewall-cmd --permanent --add-port=8123/tcp \
&& firewall-cmd --permanent --add-port=5353/udp \
&& firewall-cmd --reload    

### Home Assistant
#docker build -t home-assistant .
#docker-compose up -d