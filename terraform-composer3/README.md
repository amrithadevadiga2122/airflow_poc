# Terraform Cloud Composer 3 (Modular)

This repository provisions a Cloud Composer 3 environment on Google Cloud using modular Terraform.

Modules:
- modules/network: create or reuse a VPC/subnet
- modules/storage: create or reuse a GCS bucket for DAGs
- modules/iam: grant project/bucket roles to the Composer service account
- modules/composer3: deploy the Composer 3 environment

Quickstart (dev):
- terraform init
- terraform plan -var-file=environments/dev.tfvars
- terraform apply -var-file=environments/dev.tfvars

Notes:
- Set module.network.create and module.storage.create to true if you want Terraform to create new infra.
- The Composer web UI access is open to 0.0.0.0/0 for dev; restrict in prod.
- Ensure your service account has necessary roles (least privilege recommended).
