provider "aws" {
    region = "us-east-1"
}
resource "aws_s3_bucket" "website_bucket" {
    bucket = "zizis-bucket"

    }
    
resource "aws_s3_bucket_versioning" "website_bucket_versioning" {
    bucket = "zizis-bucket"
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = "zizis-bucket"

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "error.html"
    }
}


resource "aws_s3_object" "index_html" {
    bucket   = "zizis-bucket"
    key      = "index.html"
    source   = "${path.module}/index.html"
    content_type = "text/html"
    depends_on = [aws_s3_bucket.website_bucket]
}
resource "aws_s3_object" "error_html" {
    bucket   = "zizis-bucket"
    key      = "error.html"
    source   = "${path.module}/error.html"
    content_type = "text/html"
    depends_on = [aws_s3_bucket.website_bucket]
}

locals {
    image_files = [
        "Those_Bones_Are_Not_My_Child.JPG",
        "road_to_October_7.JPG"
    ]
}

resource "aws_s3_object" "images" {
    for_each = toset(local.image_files)
    bucket   = "zizis-bucket"
    key      = "images/${each.key}"
    source   = "${path.module}/images/${each.key}"
    content_type = "image/jpeg"
    depends_on = [aws_s3_bucket.website_bucket]
}

resource "aws_s3_bucket_policy" "public_access" {
    bucket = "zizis-bucket"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = "arn:aws:s3:::zizis-bucket/*"
            }
        ]
    })
  
}

resource "aws_s3_bucket_public_access_block" "disable_block" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.website_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "public_access_main" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json

  depends_on = [aws_s3_bucket_public_access_block.disable_block]
}
