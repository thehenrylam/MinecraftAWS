#!/bin/bash

set -x

sudo apt remove -y ansible
sudo apt purge -y ansible

sudo rm /etc/apt/sources.list.d/ansible.list

sudo rm /usr/share/keyrings/ansible-archive-keyring.gpg

sudo apt update -y

set +x

