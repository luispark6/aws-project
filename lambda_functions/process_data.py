import csv
import boto3
import io
import json
from datetime import datetime


s3 = boto3.client("s3")

def lambda_handler(event, context):
    bucket = event["bucket"]
    key = event["key"]
    obj = s3.get_object(Bucket=bucket, Key=key)
    body = obj["Body"].read().decode("utf-8")

    df = pd.read_csv(io.StringIO(body))

    print(f"Uncleaned DataFrame shape {df.shape}")

    df = (
        df
        .clean_names()      
        .remove_empty()     
        .drop_duplicates()  
    )

    print(f"Cleaned DataFrame shape: {df.shape}")

    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)
    time = str(datetime.now()) + ".csv"


    s3.put_object(
        Bucket="dataset-lpark-processed",
        Key=time,
        Body=csv_buffer.getvalue()
    )

    print(f"Sucessfully added csv file to dataset-lpark-processed")


    return {
        "bucket": "dataset-lpark-processed",
        "key": time,
    }


