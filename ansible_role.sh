#!/bin/bash

######################### PURPOSE #########################
# - Helper script that kicks off a range of ansible roles #
# - Lists all roles that it has access to                 #
###########################################################

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Immediately move to the SCRIPT_DIR
cd ${SCRIPT_DIR}

ANSIBLE_ROOT_DIR="${SCRIPT_DIR}/ansible"
ANSIBLE_ROLE_DIR="${ANSIBLE_ROOT_DIR}/roles"

MASTER_VARIABLE_FILE="${ANSIBLE_ROOT_DIR}/group_vars/master.yml"

# Function to display help message
function help_message() {
    # Get the list of roles, and then add "    * " as its prefix (to make the output into bullet points)
    LIST_OF_ROLES=$(list_ansible_roles | sed 's/^/    * /')
    cat <<EOF
# An ADHOC method to starting ansible roles 
Usage: $0 [-h] [(OPTIONAL: -m 'master_variable_file') -p 'aws cli profile name' -r 'ansible role name' (OPTIONAL: -e 'extra_variable=value')]

Description:
    -h : Prints out this help screen and lists out the roles 
    -m : OPTIONAL: The master file that every file needs to use (default: ${ANSIBLE_ROOT_DIR}/group_vars/master.yml)
    -p : The AWS CLI profile name (You must create one yourself if you haven't already)
    -r : The ansible role that will be kicked off
    -e : OPTIONAL: The extra variables (and values that the ansible role needs)

Examples:
    # Display this help message
    $0 -h
    # Kick off the terraform job that creates the foundational pieces of the deployment
    $0 -p <PROFILE_NAME> -r apply-terraform_foundation 
    # Kick off a terraform job that requires more extra variables (make sure you separate the variable/value by spaces)
    $0 -p <PROFILE_NAME> -r <ROLE_NAME> -e "random_variable=random_value another_variable=another_value"

Role Names:
${LIST_OF_ROLES}
EOF
}

# Function to list all the roles
function list_ansible_roles() {
    # This finds all directories named "tasks", prints their parent directory, and sorts uniquely.
    find "${ANSIBLE_ROLE_DIR}" -type d -name "tasks" | sed -n 's#.*/\([^/]*\)/tasks/*$#\1#p' | sort -u
}

# Function to execute the role
function execute_ansible_role() {
    # Check if AWS CLI is installed
    if ! command -v ansible &> /dev/null; then
        echo "Error: ansible is not installed. Please install it and try again."
        exit 1
    fi

    # Check if debug mode (-x flag) is on:
    debug_is_on=false
    if [[ "$-" != *x* ]]; then
        debug_is_on=true
    fi 

    set -x

    ansible localhost \
        --module-name include_role \
        --args name="$ROLE_NAME" \
        --extra-vars "@${MASTER_VARIABLE_FILE}" \
        --extra-vars "{\"aws_profile\": \"$PROFILE_NAME\", $EXTRA_VARS}"

    if [[ "$debug_is_on" == true ]]; then
        set +x 
    fi
    
}

args=`getopt hp:r:e: $*`
# you should not use `getopt abo: "$@"` since that would parse
# the arguments differently from what the set command below does.
if [ $? -ne 0 ]; then
    help_message
    exit 2
fi
set -- $args

PROFILE_NAME=""
ROLE_NAME=""
EXTRA_VARS=""

# You cannot use the set command with a backquoted getopt directly,
# since the exit code from getopt would be shadowed by those of set,
# which is zero by definition.
while true; do
    case "$1" in
        -h)
            help_message
            exit 2
            ;;
        -m)
            MASTER_VARIABLE_FILE="$2"
            shift 2
            ;;
        -p)
            PROFILE_NAME="$2"
            shift 2
            ;;
        -r)
            ROLE_NAME="$2"
            shift 2
            ;;
        -e)
            EXTRA_VARS="$2"
            shift 2
            ;;
        --)
            shift; break
            ;;
        esac
done
if [ -z "$PROFILE_NAME" ] || [ -z "$ROLE_NAME" ]; then
    help_message
    exit 2
fi 

echo "PROFILE_NAME : $PROFILE_NAME"
echo "ROLE_NAME : $ROLE_NAME"
echo "EXTRA_VARS : $EXTRA_VARS"

cd "${ANSIBLE_ROOT_DIR}"

execute_ansible_role

