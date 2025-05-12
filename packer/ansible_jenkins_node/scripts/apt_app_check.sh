#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "${SCRIPT_DIR}/apt_app_install.sh"

function check_software() {
    # Aggregate all items in the list and form a search query "^${item_1}$|^${item_2}$|...|^${item_n}$" 
    search_query=""
    for s in ${1}; do
	search_query+="^${s}$|"
    done
    # Remove the last character if its "|"
    search_query=$(echo ${search_query} | sed 's/|$//')

    # Perform the search and check if everything is properly installed
    apt search "${search_query}"
}

check_software "${QOL_SOFTWARE_LIST[*]}"

check_software "${REQ_SOFTWARE_LIST[*]}"

