# OPENTOFU : S3 Bucket
# Purpose:
#   - Stores Binaries that Minecraft instances requires to operate (server plugins)
#   - Stores Dumps of backed up Minecraft instances for testing and recovery

provider "aws" {
    region = var.aws_region 
}

# Create S3 bucket
resource "aws_s3_bucket" "datarepo" {
    bucket = var.s3_name

    tags = {
        Name = var.s3_name
    }
}

# Set ACL for the S3 bucket
resource "aws_s3_bucket_acl" "datarepo_acl" {
    bucket = aws_s3_bucket.datarepo.id
    acl    = "private"
    depends_on = [aws_s3_bucket_ownership_controls.datarepo_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "datarepo_acl_ownership" {
  bucket = aws_s3_bucket.datarepo.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

# Block public access for the S3 bucket
resource "aws_s3_bucket_public_access_block" "datarepo_block_public_access" {
    bucket                  = aws_s3_bucket.datarepo.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# Create folders in the S3 Bucket
resource "aws_s3_object" "datarepo_binaries_stub" {
    bucket  = aws_s3_bucket.datarepo.id
    key     = var.s3_path_binaries # Starting folder structure
}

resource "aws_s3_object" "datarepo_dumps_stub" {
    bucket  = aws_s3_bucket.datarepo.id
    key     = var.s3_path_dumps # Starting folder structure
}
