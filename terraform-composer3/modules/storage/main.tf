resource "google_storage_bucket" "bucket" {
  count         = var.create ? 1 : 0

  name          = var.bucket_name
  location      = var.location
  force_destroy = var.force_destroy

  iam_configuration {
    uniform_bucket_level_access = var.ubla_enabled
    public_access_prevention    = var.public_access_prevention_enforced ? "enforced" : "unspecified"
  }

  # Optional: add labels or lifecycle rules here if you need them
}

