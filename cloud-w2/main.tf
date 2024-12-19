terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.134.0"
    }
  }
  required_version = ">=1.9.8"
}

// Настройка  vault провайдера
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

// Создаем ресурс ключа для шифрования
resource "yandex_kms_symmetric_key" "key" {
  name              = var.s3-key
  description       = "key for my bucket"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" 
}

// Создадим сервисный аккаунт
resource "yandex_iam_service_account" "sa_s3_editor" {
  name = var.sa-name
}

// Создадим роль storage.editor для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "sa_editor" {
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
  role      = var.sa-storage-editor-role
  member    = "serviceAccount:${yandex_iam_service_account.sa_s3_editor.id}"
}

// Создадим роль storage.editor для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "kms" {
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
  role      = var.sa-kms-encrypter-decripter-role
  member    = "serviceAccount:${yandex_iam_service_account.sa_s3_editor.id}"
}

// Создаем бакет
resource "yandex_storage_bucket" "s3-bucket-sec" {
  bucket                = var.bucket_name
  default_storage_class = "standard"
  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

    versioning {
    enabled = true
  }
}
