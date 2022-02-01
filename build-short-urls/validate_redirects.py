"""
Validate a CSV file of short URLs to make sure they contain unique shortnames and URLs
"""
import csv
import sys
from os import path

import validators

redirects = {}

csv_path = path.abspath(path.join(path.dirname(__file__), "pd-short-urls.csv"))

with open(csv_path, encoding='utf-8') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=",")
    for row in csv_reader:
        destination = row[1].strip()
        if row[0] in redirects:
            print("Duplicate short URL: ", row[0])
            sys.exit(1)
        if not validators.url(destination):
            print("Invalid URL: ", row[1])
            sys.exit(1)
        redirects[row[0]] = destination
