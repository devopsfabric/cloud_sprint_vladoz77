### Запускаем docker-compose

```bash
docker compose up -d --build
```

### Получаем unsel токены и рут токет

```bash
docker exec -it vault vault operator init
```


### Добавляем в переменную адрес vault

```bash
export VAULT_ADDR='http://0.0.0.0:8200'
```

### Настраиваем вход через логин и пароль
1. Включаем метод входа `userpass`
   ```bash
   vault auth enable userpass
   ```

2. Создаем политику `admin`
    ```bash
    vim admin.hcl
    ```
    ```bash
    path "*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
    ```
    Применяем политику

    ```bash
    vault policy write admin admin.hcl
    ```

3. Создаем пользователя `admin` с паролем `password`
    ```bash
    vault write auth/userpass/users/admin \    
    password=password \
    policies=admins
    ```

### Включаем kv хранилище

Переходим по адресу `http://0.0.0.0:8200` логинемся под рутовым токеном и заходим в **secret engine** - **Enable new engine** - **kv**

### Создаем секреты

Заходим в **secret engine** - **kv** - **Create Secret**

### Настраиваем аутентификацию

**Access** - **Enable new method** - **approle**


### Создаем политику для terraform

- Создаем файл политики terraform.hcl

    ```hcl
    path "*" {
    capabilities = ["list", "read"]
    }

    path "secrets/data/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
    }

    path "kv/data/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
    }


    path "secret/data/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
    }

    path "auth/token/create" {
    capabilities = ["create", "read", "update", "list"]
    }
    ```

- Применяем политику:

    ```bash
    vault policy write terraform terraform.hcl
    ```

### Создаем роль terraform

```bash
vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform
```

### Узнаем id-role

```bash
vault read auth/approle/role/terraform/role-id
```

### Узнаем secret

```bash
vault write -f auth/approle/role/terraform/secret-id
```

### Настраиваем провайдер в terraform

```tf
provider "vault" {
  address = "http://127.0.0.1:8200"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "fac78a2a-ed15-7dd1-8a23-dcab95b63db8"
      secret_id = "ef95f477-3351-8f47-0c14-e4e5bd47c9e6"
    }
  }
}

// Настройка vault
data "vault_kv_secret_v2" "yc_creds" {
  mount = "kv" // change it according to your mount
  name  = "yc" // change it according to your secret
}

provider "yandex" {
  token = data.vault_kv_secret_v2.yc_creds.data["iam_token"]
  cloud_id  = data.vault_kv_secret_v2.yc_creds.data["cloud_id"]
  folder_id = data.vault_kv_secret_v2.yc_creds.data["folder_id"]
  zone      = "ru-central1-a"
}
```