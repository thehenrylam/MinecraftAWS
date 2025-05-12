#!/bin/bash
set -e

# DOCKER INSTALLATION (Debian 12)
# NOTE: This script only works for Debian 12 !!!
# 
# Due to the significant variations among Linux distro
# Its better and faster to recreate installation scripts that work best with the target distro
# than attempting to make a universal installer 
# (If its already done, then there wouldn't be so many different installation instructions for each distro)
# 
# Finally, be honest with yourself, are you really going to form a habit of distro-hopping for this project? (hint: I highly doubt it)

# Docker Installation URL:
# https://docs.docker.com/engine/install/debian/#install-using-the-repository

DOCKER_VERSION_STRING="5:28.0.1-1~debian.12~bookworm" # 'bookworm' is the version compatible with Debian 12

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
sudo DEBIAN_FRONTEND=noninteractive apt install -y docker-ce=$DOCKER_VERSION_STRING docker-ce-cli=$DOCKER_VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin


