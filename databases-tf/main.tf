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
  machine_type = "n1-standard-1"
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

  metadata_startup_script = <<EOF
    #!/bin/bash
    docker run -e POSTGRES_PASSWORD=changeme -d --name postgres -p 5433:5432 postgres:9.6

    until docker exec postgres pg_isready -U postgres; do
      echo "Postgres not ready, retrying in 1s..."
      sleep 1
    done

    docker exec -u postgres postgres psql -U postgres -c "CREATE DATABASE test;"
    docker exec -u postgres postgres psql -U postgres -d test -c "CREATE TABLE usertable (YCSB_KEY VARCHAR(255) PRIMARY KEY not NULL, YCSB_VALUE JSONB not NULL);"
    docker exec -u postgres postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE test to postgres;"
  EOF

  tags = ["postgres-vm"]
}

resource "google_compute_instance" "scylla_vm" {
  name         = "scylla-vm"
  machine_type = "n1-standard-1"
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

  metadata_startup_script = <<EOF
    #!/bin/bash
    docker run --name scylla --hostname scylla -p 9042:9042 -d scylladb/scylla

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


resource "google_compute_firewall" "postgres_firewall" {
  name    = "postgres-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["5433"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["postgres-vm"]
}

resource "google_compute_firewall" "scylla_firewall" {
  name    = "scylla-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9042"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["scylla-vm"]
}
