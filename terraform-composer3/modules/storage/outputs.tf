output "bucket_name" {
  value = var.create ? google_storage_bucket.bucket[0].name : var.bucket_name
}
