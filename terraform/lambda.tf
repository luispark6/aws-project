

data "archive_file" "archived_process_data" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/process_data.py"
  output_path = "${path.module}/../lambda_functions/archived_process_data.zip"
} 
resource "aws_lambda_function" "process_data" {
  filename         = data.archive_file.archived_process_data.output_path
  function_name    = "process_data"
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.archived_process_data.output_base64sha256
  runtime = "python3.10"
  handler = "process_data.lambda_handler"
  layers           = [arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p310-pandas:25, arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p310-numpy:16]
}

data "archive_file" "archived_quality_check" {
  type        = "zip"
  source_file = "${path.module}/../lambda_functions/quality_check.py"
  output_path = "${path.module}/../lambda_functions/archived_quality_check.zip"
} 
resource "aws_lambda_function" "quality_check" {
  filename         = data.archive_file.archived_quality_check.output_path
  function_name    = "quality_check"
  role             = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.archived_quality_check.output_base64sha256

  runtime = "python3.10"
  handler = "quality_check.lambda_handler"

}

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
  environment {
    variables = {
      STEP_FUNCTION_ARN = aws_sfn_state_machine.data_process.arn
    }
  }

}