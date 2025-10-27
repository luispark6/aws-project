import json
import boto3
import os

stepfn_client = boto3.client("stepfunctions")

STATE_MACHINE_ARN = os.environ.get("STEP_FUNCTION_ARN")



def lambda_handler(event, context):
    
    response = stepfn_client.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input={"foo1": "bar1!"}
    )
    print("Started execution:", response["executionArn"])

    return {"statusCode": 200, "body": "Step Function started"}