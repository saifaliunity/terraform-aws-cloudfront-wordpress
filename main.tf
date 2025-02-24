locals {
  custom_origin_id = "myoriginid"
}

resource "aws_cloudfront_distribution" "cdn" {
  aliases      = var.cnames
  enabled      = var.enabled
  tags         = var.tags
  http_version = "http2and3"

  origin {
    origin_shield {
      enabled              = true
      origin_shield_region = "ap-south-1"
    }

    domain_name = var.domain_name
    origin_id   = var.origin_id
    custom_origin_config {
      origin_read_timeout      = 179
      origin_keepalive_timeout = 60
      http_port                = var.http_port
      https_port               = var.https_port
      origin_protocol_policy   = var.origin_protocol_policy
      origin_ssl_protocols     = ["TLSv1.2"]

    }

  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.minimum_protocol_version
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.origin_id
    min_ttl          = 0
    default_ttl      = 300
    max_ttl          = 31536000
    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Referer"]

      cookies {
        forward = "all"
        # whitelisted_names = "${var.cookies_whitelisted_names}"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    # min_ttl                = "${var.min_ttl}"
    # default_ttl            = "${var.default_ttl}"
    # max_ttl                = "${var.max_ttl}"
  }

  ordered_cache_behavior {
    path_pattern     = "/wp-content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.origin_id
    min_ttl          = 86400
    default_ttl      = 86400
    max_ttl          = 31536000
    forwarded_values {
      query_string = false
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Contorl-Request-Method", "Host"]

      cookies {
        forward = "none"
        # whitelisted_names = "${var.cookies_whitelisted_names}"
      }

    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/wp-admin/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
        # whitelisted_names = "${var.cookies_whitelisted_names}"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/wp-login.php"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.origin_id

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
        #whitelisted_names = "${var.cookies_whitelisted_names}"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
}
