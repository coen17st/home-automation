# home-automation
Home Automation Applications on CENTOS 7

### Server installation

### INSTALL OPEN SSH
sudo yum –y install openssh-server openssh-clients \
sudo systemctl enable sshd \
sudo systemctl start sshd \
reboot 

### INSTALL DOCKER
sudo yum remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-engine 

sudo yum install -y yum-utils 

sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo 

sudo yum install docker-ce docker-ce-cli containerd.io -y

sudo systemctl start docker 
sudo systemctl enable docker 

sudo groupadd docker 

sudo usermod -aG docker $USER

# INSTALL DOCKER COMPOSE
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version

### HOME ASSISTANT

git clone https://github.com/coen17st/home-assistant.git && cd home-assistant

docker build -t home-assistant .

docker-compose up -d

### OPEN PORTS FOR HOME ASSISTANT
firewall-cmd --permanent --add-port=8123/tcp && firewall-cmd --permanent --add-port=5353/udp 
firewall-cmd --reload        


