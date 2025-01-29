#!/bin/bash

source "$(dirname $0)/common_functions.sh"
source "$(dirname $0)/deploy_app_jenkins.sh"
source "$(dirname $0)/deploy_app_nginx.sh"

# Script Variables: 
#     - jenkins.pkr.hcl will handle the Variables, 
#       this is only here for testing purposes
# HOME_DIRECTORY="/home/admin/"
# DOCKER_VERSION_STRING="5:27.4.0-1~debian.12~bookworm"
# GITHUB_URL_NGINX="https://github.com/thehenrylam/SimpleNginx.git"
# GITHUB_URL_JENKINS="https://github.com/thehenrylam/SimpleJenkins.git"

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
        "software-properties-common"
        "git"
        "rsync"
    )
    sudo apt install -y "${required_software_list[@]}"

    # Install docker (since we expect it to be present)
    apt_install_docker
    # Install ansible 
    apt_install_ansible
}
function apt_install_docker() {
    if [ -z $DOCKER_VERSION_STRING ]; then
        hlog_error "Variable 'DOCKER_VERSION_STRING' is empty! Aborting Docker Installation!"
        exit 1
    fi 

    # Set up keyring for Docker
    sudo apt update -y
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    VERSION_CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y

    # Install the docker software
    sudo apt-get install -y docker-ce=$DOCKER_VERSION_STRING docker-ce-cli=$DOCKER_VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
}
function apt_install_ansible() {
    # Taken from https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian
    UBUNTU_CODENAME=jammy
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
    sudo apt update -y
    sudo apt install -y ansible
}

function setup_swapfile() {
    ALLOC_AMOUNT="$1"

    sudo fallocate -l "$ALLOC_AMOUNT" /swapfile
    sudo chmod 0600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo cp /etc/fstab /etc/fstab_backup
    echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
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

    # Initialize SWAPFILE
    setup_swapfile "2G"

    # Perform standard apt update/upgrade
    hlog "Executing APT update and upgrade"
    apt_update_upgrade

    # Install software
    hlog "Installing QoL software"
    apt_install_qol
    hlog "Installing Required software"
    apt_install_required

    cd ${HOME_DIRECTORY}

    # Deploy Nginx (Used to access Jenkins via the HTTPS port)
    deploy_nginx "${HOME_DIRECTORY}" "${GITHUB_URL_NGINX}" "${HOME_DIRECTORY}/scripts/config/nginxconfig_jenkins.yml"

    # Deploy Jenkins 
    deploy_jenkins "${HOME_DIRECTORY}" "${GITHUB_URL_JENKINS}"

}

# Kick off the initialization
initialize
