variable "bucket_name" {
  description = "Bucket name"
  type = string
  default = "sec-bucket"
}

variable "role_id" {
  description = "vault role"
  type = string
  default = "fac78a2a-ed15-7dd1-8a23-dcab95b63db8"
}

variable "secret_id" {
  description = "vault secret-id"
  type = string
  default = "6b1cb99e-fbd2-3ea0-505b-2d3cdc58fac3"
}

variable "s3-key" {
  description = "name for s3 key"
  type = string
  default = "s3key"
}