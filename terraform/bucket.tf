resource "aws_s3_bucket" "bucket" {
  bucket        = "jose-manuel-bucket-ra6"
  force_destroy = true

  tags = {
    Name = "bucket-s3"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  depends_on = [ aws_s3_bucket_public_access_block.bucket_public_access_block ]

  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:PutBucketPolicy",
          "s3:ListBucket"
        ]
        Resource  = [ 
          aws_s3_bucket.bucket.arn
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "bucket_policy_objects" {
  depends_on = [ aws_s3_bucket_public_access_block.bucket_public_access_block ]

  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource  = [ 
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "bucket_website" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

data "local_file" "web_files" {
  for_each = fileset("../web/src", "**")            
  filename = "${abspath("../web/src")}/${each.key}"
}

resource "aws_s3_object" "object-upload" {
  for_each = data.local_file.web_files
  bucket   = aws_s3_bucket.bucket.id
  key      = each.key
  source   = each.value.filename
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
  }, regex("^.*\\.([a-z]+)$", each.key)[0], "application/octet-stream")
}