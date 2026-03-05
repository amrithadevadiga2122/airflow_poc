resource "google_composer_environment" "env" {
  name   = var.name
  region = var.region

  config {
    software_config {
      image_version            = var.image_version
      env_variables            = var.env_variables
      pypi_packages            = var.pypi_packages
      airflow_config_overrides = var.airflow_config_overrides

      dynamic "web_server_plugins_config" {
        for_each = var.web_server_plugins_enabled ? [1] : []
        content {}
      }
    }

    workloads_config {
      scheduler {
        count       = 2
        cpu         = 0.5
        memory_gb   = 2
        storage_gb  = 1
      }
      dag_processor {
        count       = 2
        cpu         = 1
        memory_gb   = 4
        storage_gb  = 1
      }
      triggerer {
        count       = 2
        cpu         = 0.5
        memory_gb   = 1
        storage_gb  = 1
      }
      web_server {
        cpu         = 1
        memory_gb   = 2
        storage_gb  = 1
      }
      worker {
        min_count   = 2
        max_count   = 3
        cpu         = 0.5
        memory_gb   = 2
        storage_gb  = 10
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
    resilience_mode  = "HIGH_RESILIENCE"

    node_config {
      service_account = var.service_account_email
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
    }

    private_environment_config {
      enable_private_environment = true
    }

    storage_config {
      bucket = var.dags_bucket
    }

    web_server_network_access_control {
      allowed_ip_range {
        value       = var.allowed_cidr
        description = "WebUI access control"
      }
    }
  }
}

output "airflow_uri"    { value = google_composer_environment.env.config[0].airflow_uri }
output "dag_gcs_prefix" { value = google_composer_environment.env.config[0].dag_gcs_prefix }
