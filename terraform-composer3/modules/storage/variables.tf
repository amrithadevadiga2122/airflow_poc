variable "project_id" {
  type = string
}

variable "location" {
  type = string
}

variable "create" {
  type    = bool
  default = false
}

variable "bucket_name" {
  type = string
}

variable "force_destroy" {
  type    = bool
  default = false
}


# New: security posture controls
variable "ubla_enabled" {
  type    = bool
  default = true  # Uniform bucket‑level access must be enabled per org policy
}

variable "public_access_prevention_enforced" {
  type    = bool
  default = true  # Many orgs also enforce PAP; keep true unless your org allows otherwise
}