resource "google_composer_environment" "env" {
  provider = google-beta
  name     = var.name
  region   = var.region

  # Custom Bucket Configuration
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

    # Networking: Private IP & Public PyPI
    enable_private_endpoint = true # Part of Private IP setup

    node_config {
      service_account = var.service_account_email
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
      
      # Network Tags: Set to null or empty list as per your "None" requirement
      tags = [] 
    }

    # Private IP Configuration
    private_environment_config {
      enable_private_endpoint = true
      # This allows access to public PyPI via Cloud NAT or similar
      enable_privately_used_public_ips = false 
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
