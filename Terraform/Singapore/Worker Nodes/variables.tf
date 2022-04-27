variable "worker_vm_names" { type = list(string) }
variable "zones_usa" { type = list(string) }
variable "subnetwork" { type = string }
variable "network_name" { type = string }
variable "resource_group" { type = list(string) }
variable "k8-ip-worker-usa" { type = list(string) }
variable "machine_type" { type = string }
variable "backend_name" { type = string }
variable "health_check_name" { type = string }
variable "target_http_proxy_name" { type = string }
variable "url_map_name" { type = string }
variable "external_lb_name" { type = string }








