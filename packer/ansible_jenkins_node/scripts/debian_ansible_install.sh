#!/bin/bash

# ANSIBLE INSTALLATION (Debian 12)
# NOTE: This script only works for Debian 12 !!!
# 
# Due to the significant variations among Linux distro
# Its better and faster to recreate installation scripts that work best with the target distro
# than attempting to make a universal installer 
# (If its already done, then there wouldn't be so many different installation instructions for each distro)
# 
# Finally, be honest with yourself, are you really going to form a habit of distro-hopping for this project? (hint: I highly doubt it)


# Exit immediately if anything results in a non-zero return code
set -e

UBUNTU_CODENAME=jammy # 'jammy' is the codename for Debian 12

# Import the Ansible repository GPG key non-interactively
wget -qO- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" \
  | sudo gpg --batch --yes --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg

# Add the Ansible repository to your sources list
echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" \
  | sudo tee /etc/apt/sources.list.d/ansible.list

# Update the packages
sudo apt update -y

# Install ansible
sudo DEBIAN_FRONTEND=noninteractive apt install -y ansible

# Verify ansible installation
ansible --version


