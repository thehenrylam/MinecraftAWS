variable "aws_region" {
    description = "The AWS region to create resources in."
    type = string
}

variable "nickname" {
    description = "The deployment's identifier (nickname). Will be used to help name cloud assets."
    type        = string
}

variable "s3_path_binaries" {
    description = "The paths to the binaries folder"
    type = string
    default = "binaries/minecraft/"
}

variable "s3_path_dumps" {
    description = "The paths to the binaries folder"
    type = string
    default = "dumps/MCAWS/"
}
