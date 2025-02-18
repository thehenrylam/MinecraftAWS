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

# Function to display help message
function help_message() {
    # Get the list of roles, and then add "    * " as its prefix (to make the output into bullet points)
    LIST_OF_ROLES=$(list_ansible_roles | sed 's/^/    * /')
    cat <<EOF
# An ADHOC method to starting ansible roles 
Usage: $0 [-h] [-p 'aws cli profile name' -r 'ansible role name' (OPTIONAL: -e 'extra_variable=value')]

Description:
    -h : Prints out this help screen and lists out the roles 
    -p : The AWS CLI profile name (You must create one yourself if you haven't already)
    -r : The ansible role that will be kicked off
    -e : The extra variables (and values that the ansible role needs)

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

    # Executing ansible role
    echo 'EXECUTING: ansible localhost --module-name include_role --args name="$ROLE_NAME" --extra-vars "aws_profile=$PROFILE_NAME $EXTRA_VARS"'
    ansible localhost --module-name include_role --args name="$ROLE_NAME" --extra-vars "aws_profile=$PROFILE_NAME $EXTRA_VARS"
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

execute_ansible_role

