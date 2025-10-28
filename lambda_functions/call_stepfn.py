import json
import boto3
import os


stepfn_client = boto3.client("stepfunctions")

STATE_MACHINE_ARN = os.environ.get("STEP_FUNCTION_ARN")



def lambda_handler(event, context):
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    step_input = json.dumps({
        "bucket": bucket,
        "key": key
    })

    response = stepfn_client.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=step_input
    )
    print("Started execution:", response["executionArn"])

    return {"statusCode": 200, "body": "Step Function started"}