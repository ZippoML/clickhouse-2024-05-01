## 1. Install yc CLI
```shell
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | \
bash -s -- -a
```
Check:
```shell
yc --version
```

## 2. Install Terraform

```shell
export TERRAFORM_VERSION=1.4.6
```

Install:

```shell
curl -sL https://hashicorp-releases.yandexcloud.net/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
&& unzip terraform.zip \
&& install -o root -g root -m 0755 terraform /usr/local/bin/terraform \
&& rm -rf terraform terraform.zip
```
Check:
```shell
terraform -v
```

## 3. Deploy Infrastructure to Yandex.Cloud with Terraform

[Yandex Managed Service for ClickHouse](https://cloud.yandex.com/en/services/managed-clickhouse)

[EN] Reference: [Getting started with Terraform by Yandex Cloud](https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/terraform-quickstart)
[RU] Reference: [Начало работы с Terraform by Yandex Cloud](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart)

1. Configure `yc` CLI: [Getting started with the command-line interface by Yandex Cloud](https://cloud.yandex.com/en/docs/cli/quickstart#install)

    ```bash
    yc init
    ```

1. Populate `.env` file

   `.env` is used to store secrets as environment variables.

   Copy template file [.env.template](./.env.template) to `.env` file:
    ```bash
    cp .env.template .env
    ```

   Open file in editor and set your own values.

   > ❗️ Never commit secrets to git


1. Set environment variables:

    ```bash
    export YC_TOKEN=$(yc iam create-token)
    export YC_CLOUD_ID=$(yc config get cloud-id)
    export YC_FOLDER_ID=$(yc config get folder-id)
    export $(xargs <.env)
    ```

1. Deploy using Terraform

   Configure YC Terraform provider:

    ```bash
    cp terraformrc ~/.terraformrc
    ```

1. Get familiar with Cloud Infrastructure: [main.tf](./main.tf) and [variables.tf](./variables.tf)

    ```bash
    terraform init
    terraform validate
    terraform fmt
    terraform plan
    terraform apply
    ```

1. Store terraform output values as Environment Variables:

    ```bash
    export CLICKHOUSE_HOST=$(terraform output -raw clickhouse_host_fqdn)
    export DBT_HOST=${CLICKHOUSE_HOST}
    export DBT_USER=${CLICKHOUSE_USER}
    export DBT_PASSWORD=${TF_VAR_clickhouse_password}
    ```
## 4. Check database connection

[Configure JDBC (DBeaver) connection](https://cloud.yandex.ru/docs/managed-clickhouse/operations/connect#connection-ide):

```shell
port=8443
socket_timeout=300000
ssl=true
sslrootcrt=<path_to_cert>
```

Make sure dbt can connect to your target database:

```bash
dbt debug
```

If any errors check ENV values are present:

```bash
env | grep DBT_
```

