# cse239-cloud-storage

Note: If you are another group looking to deploy our project head to the [Nautilus instructions below](#nautilus).

## Installation Prerequisites

### Install Terraform

#### macOS

```sh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Ubuntu/Debian

```sh
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
```

### Install gcloud CLI

Follow the prompts from the interactive installer (Linux and macOS)

```sh
curl https://sdk.cloud.google.com | bash

exec -l $SHELL

gcloud init
```

## Deployment

These instructions assume you already have a GCP Project created with the Google Compute Engine API enabled. If you do not have this, follow [the instructions from Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#set-up-gcp).

Authenticate

```sh
gcloud auth application-default login
```

Create the infrastructure

```sh
terraform init
terraform fmt && terraform validate
terraform apply
```

SSH into the benchmarking VM

```sh
gcloud compute ssh benchmark-vm
```

Run benchmarks

```sh
docker run -it ycsb ./run_load.sh postgres [pg_ip]
docker run -it ycsb ./run_stress.sh postgres [pg_ip]
docker run -it ycsb ./run_soak.sh postgres [pg_ip]
```

Destroy the infrastructure

```sh
terraform destroy
```

## Nautilus

```sh
docker compose up
```

Run YCSB workloadb against the local postgres and scylla databases

```sh
cd ycsb
docker build . -t ycsb
docker run -it --network cse239-cloud-storage_default ycsb ./run_stress postgres localhost
docker run -it --network cse239-cloud-storage_default ycsb ./run_stress scylla localhost
```
