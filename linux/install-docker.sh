#!/bin/bash

LOGFILE="/var/log/docker_install.log"

# ANSI color codes
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
RESET='\e[0m'

log() {
    echo -e "${GREEN}$(date +'%Y-%m-%d %H:%M:%S') $1${RESET}" | tee -a $LOGFILE
}

error() {
    echo -e "${RED}$(date +'%Y-%m-%d %H:%M:%S') ERROR: $1${RESET}" | tee -a $LOGFILE
}

notification() {
    echo -e "${YELLOW}$(date +'%Y-%m-%d %H:%M:%S') $1${RESET}" | tee -a $LOGFILE
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run this script as root or using sudo"
    exit 1
fi

# Detect the OS
if cat /etc/*release | grep ^NAME | grep CentOS; then
    OS=centos
elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
    OS=ubuntu
elif cat /etc/*release | grep ^NAME | grep Debian ; then
    OS=debian
else
    error "Unsupported operating system"
    exit 1
fi

# Ensure curl is installed
log "Ensuring curl is installed..."
if [ "$OS" == "centos" ]; then
    yum install -y curl
else
    apt-get update -y
    apt-get install -y curl
fi

# Install Docker
log "Starting Docker installation..."
if [ "$OS" == "centos" ]; then
    yum update -y
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
else
    apt-get update -y
    apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$OS $(lsb_release -cs) stable"
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
fi
log "Docker installation completed!"

# Install Docker Compose
log "Starting Docker Compose installation..."
curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

# Create a symlink for Docker Compose
if [ -f "$(which dc)" ]; then
    rm -rf "$(which dc)"
fi
ln -s /usr/local/bin/docker-compose /usr/local/bin/dc
log "Docker Compose installation completed!"

notification "Installation process finished!"
