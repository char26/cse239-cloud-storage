terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "cloud-storage-477719"
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_compute_instance" "postgres_vm" {
  name         = "postgres-vm"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  scratch_disk {
    interface = "NVME"
    size      = 375
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    google-logging-enabled = "true"
  }

  metadata_startup_script = <<EOF
    #!/bin/bash
    NVME_DEVICE=$(ls /dev/nvme0n* | grep -v nvme0n1p || ls /dev/nvme0n1)
    sudo mkfs -t ext4 -F $NVME_DEVICE
    sudo mount $NVME_DEVICE /var/lib/postgresql/data
    sudo chmod 777 /var/lib/postgresql/data

    docker run -e POSTGRES_PASSWORD=changeme -d --name postgres --volume /var/lib/postgresql/data:/var/lib/postgresql/data -p 5433:5432 postgres:9.6

    until docker exec -u postgres postgres psql -h localhost -U postgres -c "CREATE DATABASE test;"; do
      echo "Postgres not ready, retrying in 1s..."
      sleep 1
    done

    docker exec -u postgres postgres psql -h localhost -U postgres -d test -c "CREATE TABLE usertable (YCSB_KEY VARCHAR(255) PRIMARY KEY not NULL, YCSB_VALUE JSONB not NULL);"
    docker exec -u postgres postgres psql -h localhost -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE test to postgres;"
  EOF

  tags = ["postgres-vm"]
}

resource "google_compute_instance" "scylla_vm" {
  name         = "scylla-vm"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  scratch_disk {
    interface = "NVME"
    size      = 375
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    google-logging-enabled = "true"
  }

  metadata_startup_script = <<EOF
    #!/bin/bash
    sudo mkdir -p /var/lib/scylla/data /var/lib/scylla/commitlog /var/lib/scylla/hints /var/lib/scylla/view_hints
    NVME_DEVICE=$(ls /dev/nvme0n* | grep -v nvme0n1p || ls /dev/nvme0n1)
    sudo mkfs -t ext4 -F $NVME_DEVICE
    sudo mount $NVME_DEVICE /var/lib/scylla
    sudo chmod 777 /var/lib/scylla

    docker run --name scylla --volume /var/lib/scylla:/var/lib/scylla --hostname scylla -p 9042:9042 -d scylladb/scylla

    until docker exec scylla cqlsh -e "CREATE KEYSPACE IF NOT EXISTS ycsb WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 3};" |& grep -vq "Connection error"; do
      sleep 1
    done

    docker exec scylla cqlsh -e "CREATE TABLE ycsb.usertable (
      y_id varchar primary key,
      field0 varchar,
      field1 varchar,
      field2 varchar,
      field3 varchar,
      field4 varchar,
      field5 varchar,
      field6 varchar,
      field7 varchar,
      field8 varchar,
      field9 varchar);"
  EOF

  tags = ["scylla-vm"]
}

resource "google_compute_instance" "benchmark_vm" {
  name         = "benchmark-vm"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    google-logging-enabled = "true"
  }

  depends_on = [google_compute_instance.postgres_vm, google_compute_instance.scylla_vm]

  metadata_startup_script = <<EOF
  #!/bin/bash
  docker pull char26/ycsb:latest
  docker pull postgres:9.6
  EOF

  tags = ["benchmark-vm"]
}
