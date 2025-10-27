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
  bucket = aws_s3_bucket.raw_dataset.id  

  lambda_function {
    lambda_function_arn = aws_lambda_function.call_stepfn.arn
    events              = ["s3:ObjectCreated:*"]
    #filter_suffix       = ".csv" # optional — triggers only for CSV uploads
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}



