output "bucket_id" {
  value = aws_s3_bucket.backend_media_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.backend_media_bucket.arn
}
