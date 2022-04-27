resource "google_compute_address" "static" {
  name = "bastion-ipv4-address"
}

resource "google_compute_instance" "bastion" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork
    network_ip = var.IP

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    ssh-keys = "${"eshamaaqib"}:${file("/home/eshamaaqib/.ssh/id_rsa.pub")}"
  }

  tags = ["bastion"]
}

resource "google_compute_firewall" "bastion-ssh" {
  name    = "bastion-ssh"
  network = var.network_name
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion"]
}

output "ip" {
  value = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}
