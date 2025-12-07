# cse239-cloud-storage

Note: If you are another group looking to deploy our project head to the [Nautilus/local instructions below](#peer-deployment).

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
cd terraform
terraform init
terraform apply
```

Copy IP addresses from the VMs

```sh
gcloud compute instances describe postgres-vm --zone us-central1-a --format='get(networkInterfaces[0].networkIP)'

gcloud compute instances describe scylla-vm --zone us-central1-a --format='get(networkInterfaces[0].networkIP)'
```

SSH into the benchmarking VM

```sh
gcloud compute ssh benchmark-vm --zone us-central1-a
```

Run benchmarks

```sh
# Run the YCSB insertion to load the Postgres database
docker run -it char26/ycsb ./insert_postgres.sh [PG_IP_ADDRESS] -t 1

# Run different test configurations
docker run -it char26/ycsb ./run_load.sh postgres [PG_IP_ADDRESS] -t 1
docker run -it char26/ycsb ./run_stress.sh postgres [PG_IP_ADDRESS] -t 1
docker run -it char26/ycsb ./run_soak.sh postgres [PG_IP_ADDRESS] -t 1
```

Don't forget to destroy the infrastructure

```sh
terraform destroy
```

## Peer Deployment

Assuming you have shell access to the machine you are deploying to:

```sh
git clone git@github.com:char26/cse239-cloud-storage.git
cd cse239-cloud-storage
docker compose up -d
./compose_init_scylla.sh
```

Run YCSB workloada against local Scylla database

```sh
docker run -it --network host char26/ycsb run_ycsb.sh scylla workloada -i localhost -r 10000 -o 50000 -t 8
```

Run YCSB workloada against the local Postgres

```sh
docker run -it --network host char26/ycsb run_ycsb.sh postgres workloada -i localhost -r 10000 -o 50000 -t 1
```
