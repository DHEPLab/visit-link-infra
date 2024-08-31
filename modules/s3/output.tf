output "bucket_id" {
  value = aws_s3_bucket.backend_media_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.backend_media_bucket.arn
}

output "bucket_encryption_key_arn" {
  value = aws_kms_key.s3_encryption_key.arn
}
