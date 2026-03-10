resource "google_composer_environment" "env" {
  provider = google-beta
  name     = var.name
  region   = var.region

  # TOP-LEVEL: This is where custom bucket config lives
  storage_config {
    bucket = var.dags_bucket
  }

  config {
    # REMOVED: private_environment_config (Not for Composer 3)
    # REMOVED: enable_private_environment (Causes "Unsupported" error)

    software_config {
      image_version            = var.image_version
      env_variables            = var.env_variables
      pypi_packages            = var.pypi_packages
      airflow_config_overrides = var.airflow_config_overrides
    }

    node_config {
      service_account = var.service_account_email
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
      tags            = [] # None (Default)
    }

    web_server_network_access_control {
      allowed_ip_range {
        value       = "0.0.0.0/0"
        description = "Allow all IP addresses"
      }
    }

    workloads_config {
      scheduler {
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
        count      = 2
      }
      web_server {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
      }
      worker {
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
        min_count  = 2
        max_count  = 3
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
    resilience_mode  = "HIGH_RESILIENCE"
  }
}
