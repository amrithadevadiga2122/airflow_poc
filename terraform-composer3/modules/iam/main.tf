resource "google_project_iam_member" "sa_roles" {
  for_each = toset(var.project_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${var.service_account_email}"
}

# Bucket-level IAM (optional; objectAdmin often granted at project level)
resource "google_storage_bucket_iam_member" "sa_on_bucket" {
  bucket = var.bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}

output "service_account_email" { value = var.service_account_email }
