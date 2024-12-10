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
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "fac78a2a-ed15-7dd1-8a23-dcab95b63db8"
      secret_id = "9a4270ab-64ae-1640-b715-1a40662c7eed"
    }
  }
}

// Настройка vault
data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv" 
  name  = "yc" 
}

provider "yandex" {
  token = data.vault_kv_secret_v2.yc_creds.data["iam_token"]
  cloud_id  = data.vault_kv_secret_v2.yc_creds.data["cloud_id"]
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
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