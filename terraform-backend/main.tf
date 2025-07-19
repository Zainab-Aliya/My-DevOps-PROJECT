provider "aws" {
    region = "us-east-1"
}
resource "aws_s3_bucket" "tf_state" {
    bucket = "my-tf-state-bucket-for-terraform-project"
}
resource "aws_s3_bucket_versioning" "my-tf-state-bucket-for-terraform-project" {
  bucket = "my-tf-state-bucket-for-terraform-project"

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_dynamodb_table" "tf_state_lock" {
    name         = "tf_state_lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }

    tags = {
      Name = "Terraform State Lock Table"
    }
  
}