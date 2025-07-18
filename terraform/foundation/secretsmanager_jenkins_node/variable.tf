variable "aws_region" {
    description = "The AWS region to create resources in."
    type        = string
}

variable "nickname" {
    description = "The deployment's identifier (nickname). Will be used to help name cloud assets."
    type        = string
}

variable "cache_path" {
    description = "The filepath of the cache directory"
    type        = string
}
