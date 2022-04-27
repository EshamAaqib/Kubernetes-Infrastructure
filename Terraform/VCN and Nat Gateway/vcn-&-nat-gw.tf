resource "google_compute_network" "vpc-wso2-project" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "private_subnet" {
  count         = 4
  purpose       = "PRIVATE"
  name          = var.subnet_names[count.index]
  ip_cidr_range = var.cidr[count.index]
  network       = var.network_name
  region        = var.regions[count.index]
  depends_on    = [google_compute_network.vpc-wso2-project]
}


resource "google_compute_router" "router" {
  count   = 2
  name    = var.router_names[count.index]
  region  = var.router_region[count.index]
  network = var.network_name

  bgp {
    asn = var.asn[count.index]
  }
  depends_on = [google_compute_network.vpc-wso2-project]
}

resource "google_compute_router_nat" "nat" {
  count                              = 2
  name                               = var.nat_names[count.index]
  router                             = var.router_names[count.index]
  region                             = var.router_region[count.index]
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
  depends_on = [google_compute_router.router, google_compute_network.vpc-wso2-project]
}

resource "google_compute_firewall" "vm-to-lb-fw" {
  name          = "allow-loadbalancers"
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  network       = var.network_name
  allow {
    protocol = "all"
  }
  target_tags = [ "k8-cluster" ]
  depends_on    = [google_compute_network.vpc-wso2-project]
}
