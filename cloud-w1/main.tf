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
      role_id = var.role_id
      secret_id = var.secret_id
    }
  }
}

// Настройка секретов
data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv" 
  name  = "yc-sa-admin" 
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
  grant {
    type        = "Group"
    permissions = ["READ", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }

  website {
    index_document = var.index
    error_document = var.index
  }
}
