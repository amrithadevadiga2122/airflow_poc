terraform {
  backend "gcs" {
    bucket = "composer_dags_dev"
    prefix = "terraform/composer/dev"
  }
}
