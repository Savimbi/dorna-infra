variable "aws_region" {
  default = "us-west-1"  # Change to your desired region
}

resource "aws_s3_bucket" "frontend" {
  bucket = "bigbiipwebfront"  # Ensure this bucket name is unique
  website {
    index_document = "index.html"
    error_document = "404.html"  # Optional: Redirect errors to index.html
  }

  tags = {
    Description = "Created with terraform"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "my_bucket_block" {
  bucket                 = aws_s3_bucket.frontend.id
  block_public_acls      = false
  ignore_public_acls     = false
  block_public_policy    = false
  restrict_public_buckets = false
}

output "website_url" {
  value = "http://${aws_s3_bucket.frontend.bucket}-s3-website.${var.aws_region}.amazonaws.com"
}