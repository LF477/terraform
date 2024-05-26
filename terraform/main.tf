provider "aws" {
    access_key = "test"
    secret_key = "test"
    region     = "eu-central-1"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true

    endpoints {
        lambda     = "http://localhost:4566"
        iam        = "http://localhost:4566"
        s3         = "http://s3.localhost.localstack.cloud:4566"
    }
}

resource "aws_s3_bucket" "s3-start" {
    bucket = "s3-start"
}


resource "aws_s3_bucket_lifecycle_configuration" "wipe" {
  bucket = aws_s3_bucket.s3-start.id

  rule {
    id = "weekly-wipe"

    expiration {
        days = 7
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket" "s3-finish" {
    bucket = "s3-finish"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "${path.module}/lambda/"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/lambda.zip"
  function_name = "lambda_func"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-start.arn
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.s3-start.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [ aws_lambda_permission.test ]
}