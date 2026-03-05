variable "project_id" { type = string }
variable "region"     { type = string  default = "us-central1" }

# Existing infra (use self-links)
variable "network_self_link" {
  type        = string
  description = "Existing VPC self link"
  default     = "projects/prj-aidataandanalytics-s-24362/global/networks/dmi-network"
}
variable "subnet_self_link" {
  type        = string
  description = "Existing Subnet self link"
  default     = "projects/prj-aidataandanalytics-s-24362/regions/us-central1/subnetworks/dmi-network"
}

variable "composer_env_name"      { type = string  default = "airflow-poc-dev" }
variable "composer_image_version" { type = string  default = "composer-3-airflow-2.10.5-build.27" }
variable "service_account_email"  { type = string  default = "composer-dag-deployer@prj-aidataandanalytics-s-24362.iam.gserviceaccount.com" }
variable "dags_bucket"            { type = string  default = "composer_dags_dev" }
variable "allowed_cidr"           { type = string  default = "0.0.0.0/0" }

variable "env_variables"            { type = map(string) default = {} }
variable "pypi_packages"            { type = map(string) default = {} }
variable "airflow_config_overrides" { type = map(string) default = {} }
variable "web_server_plugins_enabled" { type = bool default = true }

variable "composer_sa_project_roles" {
  type        = list(string)
  description = "Project-level roles for the Composer SA"
  default     = [
    "roles/composer.worker",
    "roles/storage.objectAdmin",
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
}
