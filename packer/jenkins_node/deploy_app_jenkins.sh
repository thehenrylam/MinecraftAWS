#!/bin/bash

# Refer to the external function script that exists in the same directory as this script
source "$(dirname $0)/common_functions.sh"

# Standard JENKINS application directory 
JENKINS_FOLDER="jenkins/"

function deploy_jenkins {
    __home_dir="${1}"
    __repo_url="${2}"

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

    cd "${__home_dir}"

    # Assumed that this is a public repo
    git clone "${__repo_url}" "${JENKINS_FOLDER}"

    # Move into the nginx directory
    cd "${JENKINS_FOLDER}"
}

# Closest python equivalent of `if __name__ == "__main__":`
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    test_jenkins "$@"
fi

