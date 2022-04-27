resource "google_compute_instance" "master-nodes" {
  count        = 3
  name         = var.master_vm_names[count.index]
  machine_type = var.machine_type
  zone         = var.zones[count.index]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork
    network_ip = var.k8-ip-master[count.index]
  }

  metadata = {
    ssh-keys = "${"eshamaaqib"}:${file("/home/eshamaaqib/.ssh/id_rsa.pub")}"
  }

  tags = ["k8-cluster"]
}

resource "google_compute_subnetwork" "default" {
  name          = var.lb_subnet_name
  ip_cidr_range = var.lb_subnet_cidr
  region        = var.region
  network       = var.network_name
}

resource "google_compute_address" "loadbalancer-ip" {
  name         = var.lb_ip_name
  subnetwork   = google_compute_subnetwork.default.id
  address_type = "INTERNAL"
  address      = var.lb_ip
  region       = var.region
}

resource "google_compute_forwarding_rule" "k8-master-loadbalancer" {
  name                  = var.lb_name
  backend_service       = google_compute_region_backend_service.default.id
  region                = var.region
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  allow_global_access   = true
  network               = var.network_name
  subnetwork            = google_compute_subnetwork.default.id
  network_tier          = "PREMIUM"
  ip_address            = google_compute_address.loadbalancer-ip.address
  service_label         = var.lb_service_label
}

output "k8-master-load-balancer-ip-address" {
  value = google_compute_forwarding_rule.k8-master-loadbalancer.ip_address
}

# backend service
resource "google_compute_region_backend_service" "default" {
  name                  = var.backend_name
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group          = google_compute_instance_group.k8masters[0].id
    balancing_mode = "CONNECTION"
  }
  # Uncomment and Rerun After Joining the k8 cluster together
/**
  backend {
    group          = google_compute_instance_group.k8masters[1].id
    balancing_mode = "CONNECTION"
  }
  backend {
    group          = google_compute_instance_group.k8masters[2].id
    balancing_mode = "CONNECTION"
  }
**/

}

# health check
resource "google_compute_region_health_check" "default" {
  name   = var.health_check_name
  region = var.region
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5
  tcp_health_check {
    port = "6443"
  }
}

resource "google_compute_instance_group" "k8masters" {
  count = 3
  name  = var.resource_group[count.index]
  zone  = var.zones[count.index]
  instances = [
    google_compute_instance.master-nodes[count.index].self_link,
  ]
  named_port {
    name = "tcp"
    port = "6443"
  }
  named_port {
    name = "web"
    port = "80"
  }
  named_port {
    name = "ssh"
    port = "22"
  }
}





