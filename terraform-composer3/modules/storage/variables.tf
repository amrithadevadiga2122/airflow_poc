variable "project_id"   { type = string }
variable "location"     { type = string }
variable "create"       { type = bool   default = false }
variable "bucket_name"  { type = string }
variable "force_destroy" { type = bool  default = false }
