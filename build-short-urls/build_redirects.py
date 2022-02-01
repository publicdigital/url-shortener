"""
Turn a CSV file of short URLs into redirects served by Amazon S3
"""
import csv
from os import path
import boto3

# Assumes the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are set
session = boto3.Session()
s3 = session.client('s3')
BUCKET_NAME = 'origin.pdlink.co'

csv_path = path.abspath(path.join(path.dirname(__file__), "pd-short-urls.csv"))
null_file = path.abspath(path.join(path.dirname(__file__), "null_file"))

with open(csv_path, encoding='utf-8') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=",")
    for row in csv_reader:
        origin = row[0].strip()
        destination = row[1].strip()
        s3.upload_file(
            null_file, BUCKET_NAME, origin,
            ExtraArgs={'ACL': 'public-read', 'WebsiteRedirectLocation': destination}
        )
        print("Updated: ", origin)
