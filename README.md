# Deploy OCI Infrastructure (Terraform_IaC_v2)

This project provisions a infrastructure on Oracle Cloud Infrastructure (OCI) using Terraform. 

It is specifically designed to maximize the OCI Ampere A1 Free Tier resources.

&nbsp;

## Provisioned Resources
This code automates the deployment of the following components:

* **Networking**: VCN, Subnets (Public & Private), Internet Gateway, NAT Gateway.
* **Routing & Security**: Route Tables, Security Lists, Network Security Groups (NSG) with fine-grained Security Rules.
* **Load Balancing**: Network Load Balancer (NLB), Backend Sets, Backends, and Listeners.
* **Compute**: Two Virtual Machines using ARM-based Ampere A1 shapes.

&nbsp;

## Prerequisites

### 1. Key Management
Before running Terraform, you must place the required cryptographic keys in the `keys` directory:
* **VM Access Keys**: Public and private keys for SSH access to the instances.
* **Terraform API Key**: The private key (`.pem`) used for OCI provider authentication.

```text
./keys/instance/
├── public.key
└── private.key

./keys/terraform/
└── private.pem
```

&nbsp;

### 2. Configuration (terraform.tfvars)
You need to provide your specific OCI environment details in the terraform.tfvars file. This includes:
* tenancy_ocid, user_ocid, fingerprint, and region.
* Project-specific variables like project_name and server_config.

&nbsp;

## Resource Control
* Global Configuration: Most parameters (VM specs, Network CIDRs, NSG rules) are fully manageable via terraform.tfvars.
* OS Selection : You can use OS Ubuntu or Rocky Linux
* Exceptions: The Network Load Balancer (NLB) detailed information is defined within local variables for architectural consistency and is not exposed in the .tfvars file.

&nbsp;

`This is an example code. You can customize it to suit your needs.`
