terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket-for-terraform-project"
    key            = "website/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf_state_lock"
    encrypt        = true
  }
}