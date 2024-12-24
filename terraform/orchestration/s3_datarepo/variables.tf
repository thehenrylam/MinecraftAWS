variable "aws_region" {
    description = "The AWS region to create resources in."
    type = string
}

variable "s3_name" {
    description = "The name of the S3 (S3 Bucket) that will store data needed for backups and deployment"
    type = string
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
