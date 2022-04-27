variable "network_name" { type = string }
variable "subnet_names" { type = list(string) }
variable "router_names" { type = list(string) }
variable "nat_names" { type = list(string) }
variable "regions" { type = list(string) }
variable "cidr" { type = list(string) }
variable "router_region" { type = list(string) }
variable "asn" { type = list(string) }
