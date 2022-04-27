resource "google_compute_instance" "worker-nodes" {
  count        = 3
  name         = var.worker_vm_names[count.index]
  machine_type = var.machine_type
  zone         = var.zones_usa[count.index]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork
    network_ip = var.k8-ip-worker-usa[count.index]
  }


  metadata = {
    ssh-keys = "${"eshamaaqib"}:${file("/home/eshamaaqib/.ssh/id_rsa.pub")}"
  }

  tags = ["k8-cluster"]
}

resource "google_compute_instance_group" "external-groups" {
  count = 3
  name  = var.resource_group[count.index]
  zone  = var.zones_usa[count.index]
  instances = [
    google_compute_instance.worker-nodes[count.index].self_link
  ]
  named_port {
    name = "http"
    port = "30080"
  }
  named_port {
    name = "https"
    port = "30443"
  }
}

resource "google_compute_health_check" "healthcheck" {
  name               = var.health_check_name
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 4
  unhealthy_threshold = 5
  http_health_check {
    port         = 30080
    request_path = "/"
  }
}

resource "google_compute_backend_service" "backend_service" {
  name          = var.backend_name
  port_name     = "http"
  protocol      = "HTTP"
  health_checks = ["${google_compute_health_check.healthcheck.self_link}"]
  backend {
    group                 = google_compute_instance_group.external-groups[0].self_link
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }
  backend {
    group                 = google_compute_instance_group.external-groups[1].self_link
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }
  backend {
    group                 = google_compute_instance_group.external-groups[2].self_link
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }
}

resource "google_compute_url_map" "url_map" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.backend_service.self_link
}
# used by one or more global forwarding rule to route incoming HTTP requests to a URL map
resource "google_compute_target_http_proxy" "target_http_proxy" {
  name    = var.target_http_proxy_name
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name       = var.external_lb_name
  target     = google_compute_target_http_proxy.target_http_proxy.self_link
  port_range = "80"
}

output "load-balancer-ip-address" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}
