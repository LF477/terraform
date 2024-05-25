provider "aws" {
    access_key = "test"
    secret_key = "test"
    region     = "eu-central-1"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true

    endpoints {
        s3 = "http://s3.localhost.localstack.cloud:4566"
    }
}

resource "aws_s3_bucket" "s3-start" {
    bucket = "s3-start"
}

resource "aws_s3_bucket" "s3-finish" {
    bucket = "s3-finish"
}