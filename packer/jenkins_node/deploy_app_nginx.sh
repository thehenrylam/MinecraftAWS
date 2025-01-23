# Refer to the external function script that exists in the same directory as this script
source "$(dirname $0)/common_functions.sh"

# Standard NGINX application directory
NGINX_FOLDER="nginx/"

function deploy_nginx {
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
    git clone "${__repo_url}" "${NGINX_FOLDER}"

    # Move into the nginx directory
    cd "${NGINX_FOLDER}"

}

__HOME_DIRECTORY="/Users/thehenrylam/Projects/MinecraftAWS/packer/test_directory/" # "$1"
__GITHUB_URL_NGINX="https://github.com/thehenrylam/SimpleNginx.git" # "$2"
deploy_nginx "${__HOME_DIRECTORY}" "${__GITHUB_URL_NGINX}"
