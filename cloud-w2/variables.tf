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
  default = "79633536-2e2d-83fa-2972-d47c413ab3fb"
}

variable "s3-key" {
  description = "name for s3 key"
  type = string
  default = "s3key"
}

variable "sa-name" {
  description = "service accaunt name"
  type = string
  default = "s3-editor"
}

variable "sa-storage-editor-role" {
  description = "service accaunt role"
  type = string
  default = "storage.editor"
}

variable "sa-kms-encrypter-decripter-role" {
  description = "service accaunt role"
  type = string
  default = "kms.keys.encrypterDecrypter"
}