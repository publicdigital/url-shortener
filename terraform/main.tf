variable "site_domain" {
  description = "The public facing domain name for your service (eg. pdlink.co)"
}
variable "certificate_arn" {
  description = "The ARN value for the certificate you've created using the AWS Certificate Manager"
}
variable "price_class" {
  default = "PriceClass_100"
}

output "name_servers" {
  value = aws_route53_zone.zone.name_servers
}

output "origin_bucket" {
  value = aws_s3_bucket.origin.bucket
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.distribution.id
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "origin" {
  bucket = "origin.${var.site_domain}"
  acl = "public-read"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadForGetBucketObjects",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::origin.${var.site_domain}/*"
  }]
}
EOF

  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_response_headers_policy" "security_headers_policy" {
  name = "pd-security-headers-policy"
  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains = true
      preload = true
      override = true
    }
    content_security_policy {
      content_security_policy = "frame-ancestors 'none'; default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override = true
    }
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.origin.website_endpoint
    origin_id = "origin"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id = "origin"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers_policy.id
  }

  viewer_certificate {
    minimum_protocol_version = "TLSv1"
    acm_certificate_arn = var.certificate_arn
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled = true
  aliases = ["${var.site_domain}"]
  price_class = var.price_class
  default_root_object = "index.html"
}

resource "aws_route53_zone" "zone" {
  name = var.site_domain
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.zone.zone_id
  name = var.site_domain
  type = "A"

  alias {
    name = aws_cloudfront_distribution.distribution.domain_name
    zone_id = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
