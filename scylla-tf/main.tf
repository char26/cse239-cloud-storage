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

resource "google_compute_instance" "scylla-node1" {
  name         = "scylla-node1"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "scylla-images/scylladb-5-2-1"
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

  tags = ["scylla-node"]
}

resource "google_compute_instance" "scylla-node2" {
  name         = "scylla-node2"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "scylla-images/scylladb-5-2-1"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["scylla-node"]
}

resource "google_compute_instance" "scylla-node3" {
  name         = "scylla-node3"
  machine_type = "n2d-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "scylla-images/scylladb-5-2-1"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["scylla-node"]
}

resource "google_compute_instance" "benchmark_vm" {
  name         = "benchmark-vm"
  machine_type = "n4-standard-2"
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

  tags = ["benchmark-vm"]
}
