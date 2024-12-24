# OPENTOFU : S3 Bucket
# Purpose:
#   - Stores Binaries that Minecraft instances requires to operate (server plugins)
#   - Stores Dumps of backed up Minecraft instances for testing and recovery

provider "aws" {
    region = var.aws_region 
}

# Create S3 bucket
resource "aws_s3_bucket" "opentofu_bucket" {
    bucket = var.bucket_name

    tags = {
        Name = var.bucket_name
    }
}

# Set ACL for the S3 bucket
resource "aws_s3_bucket_acl" "opentofu_bucket_acl" {
    bucket = aws_s3_bucket.opentofu_bucket.id
    acl    = "private"
    depends_on = [aws_s3_bucket_ownership_controls.opentofu_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "opentofu_bucket_acl_ownership" {
  bucket = aws_s3_bucket.opentofu_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# Block public access for the S3 bucket
resource "aws_s3_bucket_public_access_block" "opentofu_bucket_block_public_access" {
    bucket                  = aws_s3_bucket.opentofu_bucket.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# Create folders in the S3 Bucket
resource "aws_s3_object" "binaries_stub" {
    bucket  = aws_s3_bucket.opentofu_bucket.id
    key     = var.s3_path_binaries # Starting folder structure
}

resource "aws_s3_object" "dumps_stub" {
    bucket  = aws_s3_bucket.opentofu_bucket.id
    key     = var.s3_path_dumps # Starting folder structure
}
