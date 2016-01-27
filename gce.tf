provider "google" {
  credentials = "${file(var.credential_file)}"
  project = "${var.project}"
  region = "${var.region}"
}

resource "google_compute_network" "network" {
  name = "${var.name}"
  ipv4_range = "${var.network_ipv4}"
}

resource "google_compute_firewall" "firewall-external" {
  name = "${var.name}-firewall-external"
  network = "${google_compute_network.network.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }
}

resource "google_compute_firewall" "firewall-internal" {
  name = "${var.name}-firewall-internal"
  network = "${google_compute_network.network.name}"
  source_ranges = ["${google_compute_network.network.ipv4_range}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }
}
