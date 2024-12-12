variable "bucket_name" {
  description = "Bucket name"
  type = string
  default = "fabrika-terraform-site"
}

variable "index" {
  description = "site"
  type = string
  default = "index.html"
}

variable "role_id" {
  description = "vault role"
  type = string
  default = "fac78a2a-ed15-7dd1-8a23-dcab95b63db8"
}

variable "secret_id" {
  description = "vault secret-id"
  type = string
  default = "79633536-2e2d-83fa-2972-d47c413ab3fb"
}