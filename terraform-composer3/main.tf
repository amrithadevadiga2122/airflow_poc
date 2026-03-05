# Enable required Google APIs
resource "google_project_service" "composer_api" {
  project = var.project_id
  service = "composer.googleapis.com"
}
resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
}
resource "google_project_service" "container_api" {
  project = var.project_id
  service = "container.googleapis.com"
}
resource "google_project_service" "artifactregistry_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

# Storage module (reuse existing by default; set create=true to make new)
module "storage" {
  source = "./modules/storage"

  project_id   = var.project_id
  location     = var.region
  create       = false
  bucket_name  = var.dags_bucket
  force_destroy = false
}

# Composer 3 module
module "composer3" {
  source = "./modules/composer3"

  project_id            = var.project_id
  region                = var.region
  name                  = var.composer_env_name
  image_version         = var.composer_image_version
  service_account_email = var.service_account_email



  dags_bucket           = module.storage.bucket_name

  allowed_cidr              = var.allowed_cidr
  env_variables             = var.env_variables
  pypi_packages             = var.pypi_packages
  airflow_config_overrides  = var.airflow_config_overrides
  web_server_plugins_enabled = var.web_server_plugins_enabled

  depends_on = [
    google_project_service.composer_api,
    google_project_service.compute_api,
    google_project_service.container_api,
    google_project_service.artifactregistry_api,

  ]
}
