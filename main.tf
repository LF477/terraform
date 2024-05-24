provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "eu-central-1"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudwatch = "http://localhost:4566"
    # lambda     = "http://localhost:4566"
    s3         = "http://s3.localhost.localstack.cloud:4566"
    # iam        = "http://localhost:4566"
  }
}


resource "aws_s3_bucket" "s3-start" {
  bucket = "s3-start"
}


resource "aws_s3_bucket_lifecycle_configuration" "cleanup" {
  bucket = aws_s3_bucket.s3-start.id

  rule {
    expiration {
      days = 1
    }
    id     = "cleanup-rule"
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "s3-finish" {
  bucket = "s3-finish"
}


data "archive_file" "zip_python_code" {
  source_dir = "${path.module}/lambda"
  output_path = "handler.zip"
  type        = "zip"
}

# resource "aws_iam_role" "lambda_execution_role" {
#   name = "lets-build-lambda-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "lambda_basic_execution" {
#   name       = "lets-build-lambda-attachment"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   roles      = [aws_iam_role.lambda_execution_role.name]
# }

# resource "aws_lambda_function" "image_analysis_lambda" {
#   filename         = "${path.module}/handler.zip"
#   function_name    = "lets-build-function"
#   handler          = "index.lambda_handler"
#   runtime          = "python3.12"
#   role             = aws_iam_role.lambda_execution_role.arn

#   source_code_hash = data.archive_file.zip_python_code.output_base64sha256
#   environment {
#     variables = {
#       REGION = "eu-central-1"
#     }
#   }
# }

# resource "aws_lambda_permission" "allow_bucket" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.image_analysis_lambda.function_name
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.s3-start.arn
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.s3-start.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.image_analysis_lambda.arn
#     events              = ["s3:ObjectCreated:*"]
#   }

#   depends_on = [aws_lambda_permission.allow_bucket]
# }