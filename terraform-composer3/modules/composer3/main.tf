resource "google_composer_environment" "env" {
  provider = google-beta

  name   = var.name
  region = var.region

  config {
    software_config {
      image_version            = var.image_version
      env_variables            = var.env_variables
      pypi_packages            = var.pypi_packages
      airflow_config_overrides = var.airflow_config_overrides
      # web_server_plugins_config removed (unsupported in provider 5.45.x)
    }

    # Keep only supported workloads (remove dag_processor/triggerer, storage_gb)
    workloads_config {
      scheduler {
        count     = 2
        cpu       = 0.5
        memory_gb = 2
      }
      web_server {
        cpu       = 1
        memory_gb = 2
      }
      worker {
        min_count = 2
        max_count = 3
        cpu       = 0.5
        memory_gb = 2
      }
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"
    resilience_mode  = "HIGH_RESILIENCE"

    node_config {
      service_account = var.service_account_email
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
    }

    # private_environment_config removed (unsupported in provider 5.45.x)
    # storage_config removed (unsupported in provider 5.45.x)
    storage_config {
      bucket = var.dags_bucket   # bucket name only, no gs://
    }
    web_server_network_access_control {
      allowed_ip_range {
        value       = var.allowed_cidr
        description = "WebUI access control"
      }
    }
  }
}