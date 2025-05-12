#!/bin/bash

# List of quality of life software to be installed
QOL_SOFTWARE_LIST=(
    "neofetch"
    "htop"
)

# List of required software to be installed
REQ_SOFTWARE_LIST=(
    "software-properties-common"
    "git"
    "rsync"
    "python3"
)

function apt_update_upgrade() {
    # Update the apt repository (enables software installation)
    sudo DEBIAN_FRONTEND=noninteractive apt update -y
    # Upgrade software using apt (make sure everything is up-to-date)
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
}

function apt_install_qol() {
    # Installs Quality of Life software
    qol_software_list=(
        "neofetch"
        "htop"
    )
    sudo apt install -y "${qol_software_list[@]}"
}

function main() {
    apt_update_upgrade
    # Install required software
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${REQ_SOFTWARE_LIST[@]}"
    # Install quality of life software
    sudo DEBIAN_FRONTEND=noninteractive apt install -y "${QOL_SOFTWARE_LIST[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

