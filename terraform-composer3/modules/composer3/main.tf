resource "google_composer_environment" "env" {
  provider = google-beta
  name     = var.name
  region   = var.region

  # Custom Bucket (Top-level)
  storage_config {
    bucket = var.dags_bucket
  }

  config {
    # CORRECT: Single argument for Private IP in Composer 3
    enable_private_environment = true 

    software_config {
      image_version = var.image_version 
    }

    node_config {
      network         = var.network_self_link
      subnetwork      = var.subnetwork_self_link
      service_account = var.service_account_email
      tags            = [] # Network tags: None
    }

    # Web Server: Allow All (Default)
    web_server_network_access_control {
      allowed_ip_range {
        value       = "0.0.0.0/0"
        description = "Allow all IP addresses"
      }
    }

    # Workloads...
    workloads_config {
      scheduler { cpu = 0.5; memory_gb = 2; storage_gb = 1; count = 2 }
      web_server { cpu = 1; memory_gb = 2; storage_gb = 1 }
      worker { cpu = 0.5; memory_gb = 2; storage_gb = 1; min_count = 2; max_count = 3 }
    }
  }
}
