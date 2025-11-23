# cse239-cloud-storage

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
terraform fmt
terraform validate
terraform apply
```

Destroy the infrastructure

```sh
terraform destroy
```

## Next Steps:

We'll need to download the latest YCSB release, extracting it into a directory named ycsb (the benchmark will look for this directory).

After that, we should be able to deploy the VM instances created by Terraform, and run the benchmarks.

## Nautilus

```sh
docker compose up
```

Run YCSB workloadb against the local postgres database

```sh
cd ycsb
docker build . -t ycsb
docker run -it --network cse239-cloud-storage_default ycsb workloadb
```
