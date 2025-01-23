# MinecraftAWS
Launch and Host a Minecraft Server using AWS

## Installation and Setup 

## Step 1: Set up Credentials Profile (i.e. AWS_PROFILE)

- Follow the instructions online to set up an AWS Profile
    - Windows: [VirtualizationHowTo.com](https://www.virtualizationhowto.com/2021/04/configuring-aws-credentials-and-profiles-in-windows/) 
    - MacOS/Linux: [aws.plainenglish.io](https://aws.plainenglish.io/how-to-manage-aws-profiles-using-the-aws-cli-def95986c0ab)

## Step 2: Set up the configuration files:

Most of the configs are for enthusiasts or power users who wish to have a more tailored setup process.
However, most users (who don't have a lot or anything installed on AWS) can use it with minimal configuration.

For most users, focus on making sure that the following files is properly configured to your liking:
- ./config/terraform/minecraftAWS.tfvars

## Step 3: Set up all AMIs using Packer

``` BASH
# Go to Packer directory
cd ./packer/

# Initialize packer on this directory (Do this for a first time setup)
packer init .

# Set up Jenkins AMI:
# Validate
PACKER_LOG=1 AWS_PROFILE=example_aws_profile packer validate -var-file=../config/packer/jenkins.pkrvars.hcl jenkins.pkr.hcl
# Build
PACKER_LOG=1 AWS_PROFILE=example_aws_profile packer build -var-file=../config/packer/jenkins.pkrvars.hcl jenkins.pkr.hcl

# ...
```

## Step 4: Build the Cloud Infra using Terraform

``` BASH
# Set up orchestration cloud infra
cd ./terraform/orchestration/

# Initialize opentofu
TF_LOG=info AWS_PROFILE=example_aws_profile tofu init

# Plan out the AWS profile (i.e. perform a dry run)
TF_LOG=info AWS_PROFILE=example_aws_profile tofu plan -var-file="../../config/terraform/minecraftAWS.tfvars" -compact-warnings

# Apply the AWS profile 
TF_LOG=info AWS_PROFILE=example_aws_profile tofu apply -var-file="../../config/terraform/minecraftAWS.tfvars" -compact-warnings
```

### Step 5: Enjoy!

Enjoy your newly created minecraftAWS environment! 😎

