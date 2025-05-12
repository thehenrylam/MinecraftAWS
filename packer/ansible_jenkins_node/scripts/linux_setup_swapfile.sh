#!/bin/bash

ALLOC_AMOUNT="$1"

if [ -z ${ALLOC_AMOUNT} ]; then
    echo "ALLOC_AMOUNT cannot be empty, please set a value such as '2G'"
    exit 1
fi 

sudo fallocate -l "$ALLOC_AMOUNT" /swapfile
sudo chmod 0600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab_backup
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

