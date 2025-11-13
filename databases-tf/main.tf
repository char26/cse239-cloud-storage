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
    docker run -e POSTGRES_PASSWORD=changeme -d --name postgres -p 5432:5432 postgres:18
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
  EOF

  tags = ["scylla-vm"]
}


resource "google_compute_firewall" "postgres_firewall" {
  name    = "postgres-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["5432"]
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
