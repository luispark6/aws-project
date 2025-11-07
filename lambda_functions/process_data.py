import csv
import boto3
import io
import json
from datetime import datetime
import numpy as np
import pandas as pd



s3 = boto3.client("s3")

def lambda_handler(event, context):
    bucket = event["bucket"]
    key = event["key"]
    obj = s3.get_object(Bucket=bucket, Key=key)
    body = obj["Body"].read().decode("utf-8")

    df = pd.read_csv(io.StringIO(body))

    print(f"Uncleaned DataFrame shape {df.shape}")

    df.columns = (
        df.columns.str.strip()
                  .str.lower()
                  .str.replace(' ', '_')
    )

    df = df.dropna(how='all')         
    df = df.dropna(axis=1, how='all') 

    df = df.drop_duplicates()

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


