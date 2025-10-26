resource "aws_s3_bucket" "raw_dataset" {
  bucket = var.raw_dataset
  count=0
  tags = {
    Name        = var.raw_dataset
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "processed_dataset" {
  bucket = var.processed_dataset
  count=0
  tags = {
    Name        = var.processed_dataset
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "trained_models" {
  bucket = var.trained_models
  count=0
  tags = {
    Name        = var.trained_models
    Environment = "Dev"
  }
}







# IAM role for Lambda execution
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

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Lambda function code
data "archive_file" "archived_process_data" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/process_data.py"
  output_path = "${path.module}/../lambda_functions/process_data.zip"
}

# Lambda function
resource "aws_lambda_function" "process_data" {
  filename         = data.archive_file.archived_process_data.output_path
  function_name    = "process_data"
  role             = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.archived_process_data.output_base64sha256

  runtime = "python3.10"
  handler = "lambda_handler"

 
}