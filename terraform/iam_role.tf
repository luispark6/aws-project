
#lambda can assume this role
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

#states can assume this role
data "aws_iam_policy_document" "assume_role_step" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#create role that step function can use
resource "aws_iam_role" "stepfn_execution_role" {
  name               = "stepfn_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_step.json
}

#create role that lambda can use
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#allow lambda functions to execute
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


#allow lambda to use s3
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


#allow step function to have access to lambda
resource "aws_iam_role_policy_attachment" "stepfn_execution" {
  role       = aws_iam_role.stepfn_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}


#allow lambda_role to use the step function. the lambda_stepfn_policy will allow this
resource "aws_iam_role_policy_attachment" "lambda_stepfn_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_stepfn_policy.arn
}


#the policy that allows lambda to start the execution of a state function
resource "aws_iam_policy" "lambda_stepfn_policy" {
  name = "LambdaStepFnPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "states:StartExecution",
        Resource = aws_sfn_state_machine.data_process.arn
      }
    ]
  })
}







#aws_iam_role_policy_attachment are attaching policies to a role
#aws_iam_policy is the policy itself