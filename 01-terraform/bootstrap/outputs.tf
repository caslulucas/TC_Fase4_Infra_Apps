output "bucket_name" {
  description = "Bucket S3 utilizado pelo Terraform Remote State"
  value       = aws_s3_bucket.tfstate.bucket
}