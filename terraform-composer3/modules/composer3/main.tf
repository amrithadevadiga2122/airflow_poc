resource "google_composer_environment" "env" {
  # Use google-beta for storage_config and latest Composer 3 features
  provider = google-beta
  
  name   = var.name
  region = var.region

  # FIX 1: storage_config MUST be placed here (outside config block)
  storage_config {
    bucket = var.dags_bucket
  }

  config {
    software_config {
      image_version            = var.image_version
      env_variables            = var.env_variables
      pypi_packages            = var.pypi_packages
      airflow_config_overrides = var.airflow_config_overrides
    }

    workloads_config {
      scheduler {
        count      = 2
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1 # Added required storage argument for Composer 2/3
      }
      web_server {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1 # Added required storage argument
      }
      worker {
        min_count  = 2
        max_count  = 3
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1 # Added required storage argument
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
    resilience_mode  = "HIGH_RESILIENCE"

    node_config {
      service_account = var.service_account_email
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
    }

    # FIX 2: storage_config was removed from here

    web_server_network_access_control {
      allowed_ip_range {
        value       = var.allowed_cidr
        description = "WebUI access control"
      }
    }
  }
}