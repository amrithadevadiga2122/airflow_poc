variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

# Existing networking (Private IP)
variable "network_self_link" {
  type        = string
  description = "Self link of existing VPC network"
  default     = "projects/prj-aidataandanalytics-s-24362/global/networks/dmi-network"
}

variable "subnet_self_link" {
  type        = string
  description = "Self link of existing subnetwork"
  default     = "projects/prj-aidataandanalytics-s-24362/regions/us-central1/subnetworks/dmi-network"
}

# Composer env basics
variable "composer_env_name" {
  type    = string
  default = "airflow-poc-dev"
}

variable "composer_image_version" {
  type    = string
  default = "composer-3-airflow-2.10.5-build.27"
}

# Workload Service Account (used by Composer Pods)
variable "service_account_email" {
  type    = string
  default = "composer-dag-deployer@prj-aidataandanalytics-s-24362.iam.gserviceaccount.com"
}

# Storage (existing bucket for DAGs)
variable "dags_bucket" {
  type        = string
  description = "Existing GCS bucket name (no gs://)"
  default     = "composer_dags_dev"
}

# Access & config
variable "allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "env_variables" {
  type    = map(string)
  default = {}
}

variable "pypi_packages" {
  type    = map(string)
  default = {}
}

variable "airflow_config_overrides" {
  type    = map(string)
  default = {}
}

variable "web_server_plugins_enabled" {
  type    = bool
  default = true
}

# IAM roles to grant to the Composer SA
variable "composer_sa_project_roles" {
  type = list(string)
  default = [
    "roles/composer.worker",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader"
  ]
}