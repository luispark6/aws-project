output "raw_dataset" {
  value = aws_s3_bucket.raw_dataset.bucket
}
output "bucket_arn1" {
  value = aws_s3_bucket.raw_dataset.arn
}

output "processed_dataset" {
  value = aws_s3_bucket.processed_dataset.bucket
}
output "bucket_arn2" {
  value = aws_s3_bucket.processed_dataset.arn
}

output "trained_models" {
  value = aws_s3_bucket.trained_models.bucket
}
output "bucket_arn3" {
  value = aws_s3_bucket.trained_models.arn
}
