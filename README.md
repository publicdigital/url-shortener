# Public Digital URL shortener

Public Digital wants to provide a URL shortening service
without requiring our users to use services that soak up
lots of their data.

Since there doesn't appear to be a SaaS offering that
guarantees privacy, and we want to run as little software
as possible we have set up an amazon s3 based redirect
service.

If you know of a SaaS service that we could rely on,
please let us know!

## Infrastructure configuration

We use:

* AWS Route53 for DNS
* AWS CertificateManager to make it all work using https
* AWS CloudFront for caching and routing
* AWS S3 for hosting the redirects

This is all configured using terraform, other than the certificate
creation process that needs to be done via the AWS Console.

We keep our configuration in a file called conf.tfvars which looks
like:

```
site_domain = "pdlink.co"
certificate_arn = "arn:aws:acm:our-aws-certificate-details"
```

For more on managing terraform variables see: https://www.terraform.io/docs/configuration/variables.html

To set things up or make updates we call:

```
terraform apply -var-file=conf.tfvars
```

This assumes that you have a ~/.aws/config file with the right
credentials in it. Read this if you need more info on authenticating to AWS:

https://blog.gruntwork.io/authenticating-to-aws-with-the-credentials-file-d16c0fbcbf9e

## Setting up the redirections

The redirections are managed as a CSV file. To create a new redirect,
add it to the file `build-short-urls/pd-short-urls.csv` and run:

```
cd build-short-urls
python build-redirects.py
```

It assumes you are running python3 and have the dependencies listed
in the requirements.txt file.

## Any questions/suggestions

Contact james@public.digital
