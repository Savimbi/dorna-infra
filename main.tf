variable "aws_region" {
  default = "us-west-1"  # Change to your desired region
}

# Check if the S3 bucket exists
data "aws_s3_bucket" "existing" {
  bucket = "bigbiipwebfront"
}

# Only create the S3 bucket if it doesn't already exist
resource "aws_s3_bucket" "frontend" {
  count = data.aws_s3_bucket.existing.id != "" ? 0 : 1  # Skip creation if the bucket exists

  bucket = "bigbiipwebfront"  # Ensure this bucket name is unique
  website {
    index_document = "index.html"
    error_document = "404.html"  # Optional: Redirect errors to index.html
  }

  tags = {
    Description = "Created with Terraform"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = data.aws_s3_bucket.existing.id != "" ? 1 : 0  # Only apply policy if the bucket exists

  bucket = data.aws_s3_bucket.existing.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${data.aws_s3_bucket.existing.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "my_bucket_block" {
  count = data.aws_s3_bucket.existing.id != "" ? 1 : 0  # Only create block if the bucket exists

  bucket                 = data.aws_s3_bucket.existing.id
  block_public_acls      = false
  ignore_public_acls     = false
  block_public_policy    = false
  restrict_public_buckets = false
}

output "website_url" {
  value = "http://${aws_s3_bucket.frontend[0].bucket}-s3-website.${var.aws_region}.amazonaws.com"
  description = "The URL of the S3 website" # Show only if bucket is created or exists
}