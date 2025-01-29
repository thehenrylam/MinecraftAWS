#!/bin/bash

# Refer to the external function script that exists in the same directory as this script
source "$(dirname $0)/common_functions.sh"

# Standard NGINX application directory
NGINX_FOLDER="nginx/"

function deploy_nginx {
    __home_dir="${1}"
    __repo_url="${2}"
    __var_filepath="${3}"

    # Pre-checks
    if [ -z "${__home_dir}" ]; then
        hlog_error "Variable '__home_dir' in function 'deploy_nginx' is empty! Aborting Nginx Deployment!"
        exit 1
    elif [ ! -d "${__home_dir}" ]; then
        hlog_error "Variable '__home_dir' in function 'deploy_nginx' is not valid (${__home_dir})! Aborting Nginx Deployment!"
        exit 1
    fi 
    if [ -z "${__repo_url}" ]; then
        hlog_error "Variable '__repo_url' in function 'deploy_nginx' is empty! Aborting Nginx Deployment!"
        exit 1
    fi 
    if [ -z "${__var_filepath}" ]; then
        hlog_error "Variable '__var_filepath' in function 'deploy_nginx' is empty! Aborting Nginx Deployment!"
        exit 1
    elif [ ! -e "${__var_filepath}" ]; then
        hlog_error "Variable '__var_filepath' in function 'deploy_nginx' is not valid (${__var_filepath})! Aborting Nginx Deployment!"
        exit 1
    fi 

    cd "${__home_dir}"

    # Assumed that this is a public repo
    git clone "${__repo_url}" "${NGINX_FOLDER}"

    # Move into the nginx directory
    cd "${NGINX_FOLDER}"

    hlog "$(pwd)"

    # Deploy using ansible playbook
    ansible-playbook ./ansible/playbooks/deploy-config_jenkins.yml --extra-vars="@${__var_filepath}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    __HOME_DIRECTORY=$(realpath "${1}") 
    __GITHUB_URL_NGINX="https://github.com/thehenrylam/SimpleNginx.git" 
    __VARIABLES_FILEPATH=$(realpath "${2}")
    #deploy_nginx "$@"
    deploy_nginx "${__HOME_DIRECTORY}" "${__GITHUB_URL_NGINX}" "${__VARIABLES_FILEPATH}"
fi

