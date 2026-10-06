output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "readonly_role_arn" {
  value = aws_iam_role.readonly.arn
}

output "readwrite_role_arn" {
  value = aws_iam_role.readwrite.arn
}
