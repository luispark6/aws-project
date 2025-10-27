resource "aws_s3_bucket" "raw_dataset" {
  bucket = var.raw_dataset
  tags = {
    Name        = var.raw_dataset
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "processed_dataset" {
  bucket = var.processed_dataset
  tags = {
    Name        = var.processed_dataset
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "trained_models" {
  bucket = var.trained_models
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


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}




# Package the Lambda function code
data "archive_file" "archived_stepfn" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/call_stepfn.py"
  output_path = "${path.module}/../lambda_functions/archived_stepfn.zip"
} 

# Lambda function
resource "aws_lambda_function" "call_stepfn" {
  filename         = data.archive_file.archived_stepfn.output_path
  function_name    = "call_stepfn"
  role             = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.archived_stepfn.output_base64sha256

  runtime = "python3.10"
  handler = "call_stepfn.lambda_handler"

}

#permission for s3 to call lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.call_stepfn.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_dataset.arn  

}

# call the lambda function whenever object is created
resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = aws_s3_bucket.raw_dataset.id  # replace with your actual bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.call_stepfn.arn
    events              = ["s3:ObjectCreated:*"]
    #filter_suffix       = ".csv" # optional — triggers only for CSV uploads
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}

