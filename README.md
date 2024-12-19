Enable kv secret

```bash
vault secrets enable -path=kv kv
```

add token to vault

```bash
vault kv put -mount=kv yc-sa-admin \
folder_id=$(yc config get folder-id), \
cloud_id=$(yc config get folder-id), \
iam_token=$(yc iam create-token)
```

update iam token

```bash
vault kv patch -mount=kv yc-sa-admin iam_token=$(yc iam create-token)
```