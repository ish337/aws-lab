data "aws_caller_identity" "current" {}

// Bucket names are global in S3, so the prefix gets a random suffix
resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.name}-files-"
  // terraform destroy removes the bucket together with all object versions
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// Every upload keeps the old version, a deleted or overwritten file can be restored
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

// Both roles can be assumed by the users of this account, e.g. aws --profile lab-readonly
locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })
}

// Read-only: list and download, no upload or delete
resource "aws_iam_role" "readonly" {
  name               = "${var.name}-s3-readonly"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_role_policy" "readonly" {
  name = "s3-readonly"
  role = aws_iam_role.readonly.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.this.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion"]
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

// Read-write: also upload and delete
resource "aws_iam_role" "readwrite" {
  name               = "${var.name}-s3-readwrite"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_role_policy" "readwrite" {
  name = "s3-readwrite"
  role = aws_iam_role.readwrite.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:ListBucketVersions"]
        Resource = aws_s3_bucket.this.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}
