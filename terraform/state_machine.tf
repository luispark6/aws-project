resource "aws_sfn_state_machine" "data_process" {
  name     = "data_process"
  role_arn = aws_iam_role.stepfn_execution_role.arn

  definition = <<EOF
{
  "Comment": "Three Lambda chain",
  "StartAt": "ProcessData",
  "States": {
    "ProcessData": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.process_data.arn}",
      "Next": "QualityCheck"
    },
    "QualityCheck": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.quality_check.arn}",
      "End": true
    }
  }
}
EOF
}