#!/bin/bash
# list_instance_profiles.sh
#
# This script lists AWS instance profiles whose names match a provided regex.
# It requires two inputs:
#   1. A regex pattern for matching instance profile names.
#   2. An AWS CLI profile name that has permissions to view the instance profiles.
#
# Usage:
#   ./list_instance_profiles.sh "<regex_pattern>" "<aws_profile>"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <regex_pattern> <aws_profile>"
  exit 1
fi

regex_pattern=$1
aws_profile=$2

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "Error: aws CLI is not installed. Please install it and try again."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it and try again."
  exit 1
fi

# Fetch the instance profiles using the specified AWS profile and filter using the regex pattern.
aws iam list-instance-profiles --profile "$aws_profile" --output json | \
  jq -r --arg regex "$regex_pattern" '.InstanceProfiles[] | select(.InstanceProfileName | test($regex)) | .InstanceProfileName'

