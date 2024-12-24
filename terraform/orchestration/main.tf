module "s3_datarepo" {
  source      = "./s3_datarepo"
  aws_region  = "us-east-1"
  bucket_name = "mcaws-s3-bucket"
}
