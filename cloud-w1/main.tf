terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

// Настройка провайдера
provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "environment"
}

// Настройка vault
data "vault_generic_secret" "yc_creds" {
    path = "secret/yc"
}


provider "yandex" {
  token = data.vault_generic_secret.yc_creds.data["iam_token"]
  cloud_id  = data.vault_generic_secret.yc_creds.data["cloud_id"]
  folder_id = data.vault_generic_secret.yc_creds.data["folder_id"]
  zone      = "ru-central1-a"
}

// Настройка бакета 
resource "yandex_storage_bucket" "devops-site" {
  bucket                = var.bucket_name
  default_storage_class = "standard"
  anonymous_access_flags {
    read        = true
    list        = true
    config_read = true
  }
  website {
    index_document = var.index
  }
}

// Копируем index.html
resource "yandex_storage_object" "upload-object" {
  bucket     = yandex_storage_bucket.devops-site.id
  key    = var.index
  source = var.index
}