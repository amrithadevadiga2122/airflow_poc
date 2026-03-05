output "airflow_uri" {
  description = "Airflow webserver URL"
  value       = module.composer3.airflow_uri
}

output "dag_gcs_bucket" {
  description = "DAGs GCS prefix"
  value       = module.composer3.dag_gcs_prefix
}
