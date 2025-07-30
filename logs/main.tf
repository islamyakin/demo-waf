resource "aws_s3_bucket" "waf_logs" {
  bucket        = "aws-waf-logs-ap-southeast-1"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket                  = aws_s3_bucket.waf_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-ap-southeast-1-blocked"
  retention_in_days = 1
}

resource "aws_wafv2_web_acl_logging_configuration" "application" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.waf.arn


  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition { action = "BLOCK" }
      }
    }
  }
}
