# OPENTODU: AWS Secrets Manager 
# Purpose: 
#   - Stores critical files that needs to be kept secret for the purposes of deployment and other priviledged operations
terraform {
    required_providers {
        assert = {
        source = "opentofu/assert"
        version = "0.14.0"
        }
    }
}

provider "aws" {
    region = var.aws_region 
}

locals {
    # 
    rgx_datetime = "(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})Z"
    _tmp_role_creation_date_tkns = regex(local.rgx_datetime, aws_iam_role.un_pem_iam_role.create_date)
    iam_role_creation_date_suffix = join("", local._tmp_role_creation_date_tkns)
    jenkins_instance_profile_name = "instance_profile_test123-${local.iam_role_creation_date_suffix}"
}

### INITIALIZE IAM SECRET (un.pem key)
resource "aws_secretsmanager_secret" "un_pem" {
    # Initialize the secret container
    name = "un_pem_secret"
    description = "Stores the un.pem file for use in Jenkins (in MinecraftAWS)"
    recovery_window_in_days = 0 # Set this to be 0 to have it immediately be deleted upon destroy
}
resource "aws_secretsmanager_secret_version" "un_pem_value" {
    # Associate the secret to the secret container
    secret_id     = aws_secretsmanager_secret.un_pem.id
    # Upload the file as the secret_string
    secret_string = file("${var.cache_path}/un.pem")
}


### INITIALIZE IAM POLICY (un.pem key)
data "aws_iam_policy_document" "un_pem_iam_document_secret" {
    # Define policy document (secret) as datablock
    statement {
        actions = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
        ]
        resources = [
            aws_secretsmanager_secret.un_pem.arn
        ]
    }
}
resource "aws_iam_policy" "un_pem_iam_policy" {
    name = "un_pem_iam_policy"
    # Sets policy using (json converted) data block
    policy = data.aws_iam_policy_document.un_pem_iam_document_secret.json
}


### INITIALIZE IAM ROLE (un.pem key)
data "aws_iam_policy_document" "un_pem_iam_document_role" {
    # Define policy document (role) as data block
    statement {
        actions = [
            "sts:AssumeRole"
        ]
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}
resource "aws_iam_role" "un_pem_iam_role" {
    name = "un_pem_iam_role"
    # Sets policy using (json converted) data block
    assume_role_policy = data.aws_iam_policy_document.un_pem_iam_document_role.json
}


### ATTACH IAM POLICY TO ROLE (un.pem key)
resource "aws_iam_role_policy_attachment" "un_pem_policy_attachment" {
    role       = aws_iam_role.un_pem_iam_role.name
    policy_arn = aws_iam_policy.un_pem_iam_policy.arn
}

### USE IAM ROLE TO CREATE INSTANCE PROFILE
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.jenkins_instance_profile_name}"
  role = aws_iam_role.un_pem_iam_role.name
}

# Extra IAM statements needed
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "secretsmanager:GetSecretValue",
#       "Resource": [
#         "arn:aws:secretsmanager:your-region:your-account-id:secret:un_pem_secret",
#       ]
#     }
#   ]