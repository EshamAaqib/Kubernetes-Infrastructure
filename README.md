# Scripts for the Kubernetes Infrastructure 

### Terraform Run Sequence (IMPORTANT)

> First run the script in the "Terraform/VCN and Nat Gateway" before running any scripts in any other folders 

## Description

- Two internal lbs for master nodes (1 in each region for HA)
- Two external lb for worker nodes (1 in each region) which is accessible via the internet (Tested with Nginx)
- Two Cloud Routers and NAT (1 for each region) is used to access the internet
- 2 Clusters are deployed across AZs each in two regions.
- A new VPC was deployed with only the needed regions instead of using the default one

> ![image](https://user-images.githubusercontent.com/75664650/142779942-219f35dd-0632-4b61-bc0f-c0bd9c5bf425.png)
> ![image](https://user-images.githubusercontent.com/75664650/143424601-a9a72dc3-3a5a-445d-b863-d0214e920dc2.png)

## IP Addressing Table (Cluster)

###### Region - US-Central1

| IP Address | Availability Zone | Name | Public IP (Yes/No) |
| :---------:| :----------------:| :-------:| :----------------: |
| 10.1.0.2 | a | master-node-us-a | No |
| 10.1.0.3 | b | master-node-us-b | No |
| 10.1.0.4 | c | master-node-us-c | No |
| 10.1.0.5 | a | worker-node-us-a | No |
| 10.1.0.6 | b | worker-node-us-b | No |
| 10.1.0.7 | c | worker-node-us-c | No |

###### Region - Asia-Southeast1

| IP Address | Availability Zone | Name | Public IP (Yes/No) |
| :---------:| :----------------:|:-------:| :----------------: |
| 10.2.0.2 | a | master-node-asia-a | No |
| 10.2.0.3 | b | master-node-asia-b | No |
| 10.2.0.4 | c | master-node-asia-c | No |
| 10.2.0.5 | a | worker-node-asia-a | No |
| 10.2.0.6 | b | worker-node-asia-b | No |
| 10.2.0.7 | c | worker-node-asia-c | No |

###### Internal IP Addressess to all the nodes are assigned manually 

## IP Addressing  (Load Balancer)

> Internal LB (Master US) - 10.5.0.2 ( CIDR 10.5.0.0/16)

> External LB (Worker US) - Reserved Public IP


> Internal LB (Master SG) - 10.6.0.2 ( CIDR 10.6.0.0/16)


> External LB (Worker SG) - Reserved Public IP

## VPC Details

| Region | Subnet | Subnet Name
| :---------:| :----------------:|:----------------:|
| USA (us-central1) | 10.1.0.0/16 | us-subnet |
| Singapore (asia-southeast1) | 10.2.0.0/16 | singapore-subnet |
| India (asia-south1)| 10.3.0.0/16 | india-subnet |
| Finland (europe-north1) | 10.4.0.0/16 | eu-subnet |
| USA-LB-internal (us-central1) | 10.5.0.0/16 |  us-master-lb-subnet |
| Singapore-LB-internal (asia-southeaast1) | 10.6.0.0/16 |  sg-master-lb-subnet |




