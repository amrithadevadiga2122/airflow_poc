resource "google_storage_bucket" "bucket" {
  count         = var.create ? 1 : 0
  name          = var.bucket_name
  location      = var.location
  force_destroy = var.force_destroy
}

