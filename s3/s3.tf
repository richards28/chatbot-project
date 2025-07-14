resource "aws_s3_bucket" "chatbot_frontend" {
  bucket = "${var.project_prefix}-frontend"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "chatbot_frontend" {
  bucket = aws_s3_bucket.chatbot_frontend.bucket

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.chatbot_frontend.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.chatbot_frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "${aws_s3_bucket.chatbot_frontend.arn}/*"
    }]
  })
}

