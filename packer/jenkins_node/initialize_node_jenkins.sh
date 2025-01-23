#!/bin/bash


# Script Variables: 
#     - jenkins.pkr.hcl will handle the Variables, 
#       this is only here for testing purposes
# HOME_DIRECTORY="/home/admin/"
# DOCKER_VERSION_STRING="5:27.4.0-1~debian.12~bookworm"
# GITHUB_URL_NGINX="https://github.com/thehenrylam/SimpleNginx.git"
# GITHUB_URL_JENKINS="https://github.com/thehenrylam/SimpleJenkins.git"
NGINX_FOLDER="nginx/"

# Helper Log Functions
# Named as hlog (instead of hlog_info) for ergonomic purposes
#   Easier to type and most calls for hlog will be for an INFO message
function hlog() { 
    hlog_print "INFO" "$1"
}
function hlog_error() { 
    hlog_print "ERROR" "$1"
}
function hlog_print() {
    __timestamp=$(date "+%Y-%m-%d %H:%M:%S.%3N")
    __log_level="$1"
    __message="$2"
    echo "${__timestamp} - ${__log_level} : ${__message}"    
}

function apt_update_upgrade() {
    # Update the apt repository (enables software installation)
    sudo apt update -y
    # Upgrade software using apt (make sure everything is up-to-date)
    sudo apt upgrade -y
}

function apt_install_qol() {
    # Installs Quality of Life software
    qol_software_list=(
        "neofetch"
        "htop"
    )
    sudo apt install -y "${qol_software_list[@]}"
}
function apt_install_required() {
    # Installs Required software 
    required_software_list=(
        "git"
    )
    sudo apt install -y "${required_software_list[@]}"

    # Install docker (since we expect it to be present)
    apt_install_docker
}
function apt_install_docker() {
    if [ -z $DOCKER_VERSION_STRING ]; then
        hlog_error "Variable 'DOCKER_VERSION_STRING' is empty! Aborting Docker Installation!"
        exit 1
    fi 

    # Set up keyring for Docker
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install the docker software
    sudo apt-get install docker-ce=$DOCKER_VERSION_STRING docker-ce-cli=$DOCKER_VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
}

function deploy_nginx() {
    if [ -z $GITHUB_URL_NGINX ]; then
        hlog_error "Variable 'GITHUB_URL_NGINX' is empty! Aborting Nginx Deployment!"
        exit 1
    fi 

    # Assumed that this is a public repo
    git clone "${GITHUB_URL_NGINX} ${NGINX_FOLDER}"

    # Move into the nginx directory
    cd "./${NGINX_FOLDER}"
    # Delete the ./config/ folder
    rm -rf ./config/

    ## TODO: Setup a new ./config/ folder
}

function deploy_jenkins() {
    if [ -z $GITHUB_URL_JENKINS ]; then
        hlog_error "Variable 'GITHUB_URL_JENKINS' is empty! Aborting Jenkins Deployment!"
        exit 1
    fi 
    # Assumed that this is a public repo
    git clone "${GITHUB_URL_JENKINS}"
}

function initialize() {
    if [ -z ${HOME_DIRECTORY} ]; then
        hlog_error "Variable 'HOME_DIRECTORY' is empty! Aborting Initialization!"
        exit 1
    fi 
    # Make sure that we're in the home directory
    cd "${HOME_DIRECTORY}"

    # Recommended by Hashicorp/Packer: `sleep 30` is recommended 
    # because this script will immediately execute 
    # while the EC2 instance is still being set up, 
    # so waiting a bit is recommended to 
    # prevent inconsistent behavior on execution
    hlog "Sleeping for 30s"
    sleep 30

    # Perform standard apt update/upgrade
    hlog "Executing APT update and upgrade"
    apt_update_upgrade

    # Install software
    hlog "Installing QoL software"
    apt_install_qol
    hlog "Installing Required software"
    apt_install_required

    # Deploy Nginx (Used to access Jenkins via the HTTPS port)
    deploy_nginx

    # Deploy Jenkins 




}

# Recommended by Hashicorp/Packer: `sleep 30` is recommended 
# because this script will immediately execute 
# while the EC2 instance is still being set up, 
# so waiting a bit is recommended to 
# prevent inconsistent behavior on execution
sleep 30

# Update the apt repository (enables software installation)
sudo apt update -y
# Upgrade software using apt (make sure everything is up-to-date)
sudo apt upgrade -y

# Install Needed software
sudo apt install -y git
# Install QoL software
sudo apt install -y neofetch htop 

# Enable 2GB of SWAP 
sudo fallocate -l 2G /swapfile
sudo mkswap /swapfile
sudo chmod 0600 /swapfile
sudo swapon /swapfile
cp /etc/fstab /etc/fstab_bck20250106
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab



# Confirm that this initialization script has been executed
cd /home/admin/




