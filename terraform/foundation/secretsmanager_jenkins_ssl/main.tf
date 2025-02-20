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
    # Determine the date and time that the role is created, and then format to YYYYMMDDHHMMSS
    rgx_datetime = "(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})Z"
    _tmp_role_creation_date_tkns = regex(local.rgx_datetime, aws_iam_role.iam_role_jenkins.create_date)
    iam_role_creation_date_suffix = join("", local._tmp_role_creation_date_tkns)
    # Determine the prefixes and names for the cloud assets
    prefix_scrt = "scrt-${var.nickname}-jenkins"
    name_iam_policy = "iam-policy-${var.nickname}-jenkins"
    name_iam_role = "iam-role-${var.nickname}-jenkins"
    name_instance_profile = "iam-instance_profile-${var.nickname}-jenkins-${local.iam_role_creation_date_suffix}"
    
}



### INITIALIZE IAM SECRETS
resource "aws_secretsmanager_secret" "scrt_fullchain_pem" {
    # Initialize the secret container
    name = "${local.prefix_scrt}-fullchain_pem"
    description = "Stores the fullchain.pem fiel for use in Jenkins (MinecraftAWS)"
    recovery_window_in_days = 0

    tags = {
        Nickname = var.nickname
    }
}
resource "aws_secretsmanager_secret_version" "scrt_fullchain_pem_version" {
    # Associate the secret to the secret container
    secret_id = aws_secretsmanager_secret.scrt_fullchain_pem.id
    # Upload the file as the secret_string
    secret_string = file("${var.cache_path}/fullchain.pem")
}

resource "aws_secretsmanager_secret" "scrt_privkey_pem" {
    # Initialize the secret container
    name = "${local.prefix_scrt}-privkey_pem"
    description = "Stores the privkey.pem fiel for use in Jenkins (MinecraftAWS)"
    recovery_window_in_days = 0

    tags = {
        Nickname = var.nickname
    }
}
resource "aws_secretsmanager_secret_version" "scrt_privkey_pem_version" {
    # Associate the secret to the secret container
    secret_id = aws_secretsmanager_secret.scrt_privkey_pem.id
    # Upload the file as the secret_string
    secret_string = file("${var.cache_path}/privkey.pem")
}

resource "aws_secretsmanager_secret" "scrt_dhparams_pem" {
    # Initialize the secret container
    name = "${local.prefix_scrt}-dhparams_pem"
    description = "Stores the dhparams.pem fiel for use in Jenkins (MinecraftAWS)"
    recovery_window_in_days = 0

    tags = {
        Nickname = var.nickname
    }
}
resource "aws_secretsmanager_secret_version" "scrt_dhparams_pem_version" {
    # Associate the secret to the secret container
    secret_id = aws_secretsmanager_secret.scrt_dhparams_pem.id
    # Upload the file as the secret_string
    secret_string = file("${var.cache_path}/dhparams.pem")
}



### INITIALIZE IAM POLICY
data "aws_iam_policy_document" "iam_policy_document_jenkins" {
    # Define policy document (policy) as datablock
    statement {
        actions = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
        ]
        resources = [
            aws_secretsmanager_secret.scrt_fullchain_pem.arn,
            aws_secretsmanager_secret.scrt_privkey_pem.arn,
            aws_secretsmanager_secret.scrt_dhparams_pem.arn
        ]
    }
}
resource "aws_iam_policy" "iam_policy_jenkins" {
    name = "${local.name_iam_policy}"
    # Sets policy using above (json converted) datablock
    policy = data.aws_iam_policy_document.iam_policy_document_jenkins.json

    tags = {
        Nickname = var.nickname
    }
}



### INITIALIZE IAM ROLE 
data "aws_iam_policy_document" "iam_role_document_jenkins" {
    # Define policy document (role) as datablock
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
resource "aws_iam_role" "iam_role_jenkins" {
    name = "${local.name_iam_role}"
    # Sets policy using above (json converted) datablock
    assume_role_policy = data.aws_iam_policy_document.iam_role_document_jenkins.json

    tags = {
        Nickname = var.nickname
    }
}



### ATTACH IAM POLICY TO ROLE 
resource "aws_iam_role_policy_attachment" "iam_rpa_jenkins" {
    role        = aws_iam_role.iam_role_jenkins.name
    policy_arn  = aws_iam_policy.iam_policy_jenkins.arn
}



### CREATE INSTANCE PROFILE USING IAM ROLE
resource "aws_iam_instance_profile" "instance_profile" {
    name = "${local.name_instance_profile}"
    role = aws_iam_role.iam_role_jenkins.name

    tags = {
        Nickname = var.nickname
    }
}
