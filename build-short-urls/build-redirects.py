import boto3
import csv

session = boto3.Session(profile_name='pd_url_shortener')
s3 = session.client('s3')
bucket_name = 'origin.pdlink.co'

with open('pd-short-urls.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=",")
    for row in csv_reader:
        s3.upload_file(
            'null_file', bucket_name, row[0],
            ExtraArgs={'ACL': 'public-read', 'WebsiteRedirectLocation': row[1]}
        )
        print("Updated: ", row[0])


