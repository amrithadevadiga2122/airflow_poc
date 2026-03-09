project_id = "prj-aidataandanalytics-s-24362"
region = "us-central1"

composer_env_name = "airflow-dev-poc"
composer_image_version = "composer-3-airflow-2.10.5-build.27"
service_account_email = "composer-dag-deployer@prj-aidataandanalytics-s-24362.iam.gserviceaccount.com"

network_self_link = "projects/prj-aidataandanalytics-s-24362/global/networks/dmi-network"
subnet_self_link = "projects/prj-aidataandanalytics-s-24362/regions/us-central1/subnetworks/dmi-network"

dags_bucket = "composer_dags_poc_dev"
allowed_cidr = "0.0.0.0/0"

env_variables = {
ENV = "dev"
# Do NOT add AIRFLOW__CORE__LOAD_EXAMPLES here — Composer 3 forbids AIRFLOW__* config env vars
}

#pypi_packages = { "requests" = "==2.31.0" }