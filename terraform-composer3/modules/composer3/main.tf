resource "google_composer_environment" "env" {
  provider = google-beta
  name     = var.name
  region   = var.region

  # Top-level block
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

    # FIX: enable_private_endpoint must be INSIDE this block
    private_environment_config {
      enable_private_endpoint = true
    }

    node_config {
      service_account = var.service_account_email
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
      tags            = [] # None (Default)
    }

    # Web Server Access Control: Allow All (Default)
    web_server_network_access_control {
      allowed_ip_range {
        value       = "0.0.0.0/0"
        description = "Allow all IP addresses"
      }
    }

    workloads_config {
      scheduler {
        count      = 2
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
      }
      web_server {
        cpu        = 1
        memory_gb  = 2
        storage_gb = 1
      }
      worker {
        min_count  = 2
        max_count  = 3
        cpu        = 0.5
        memory_gb  = 2
        storage_gb = 1
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
    resilience_mode  = "HIGH_RESILIENCE"
  }
}
