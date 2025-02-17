#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

VALUE=$1
echo "" > ${SCRIPT_DIR}/${VALUE}.txt  

echo "{}"
