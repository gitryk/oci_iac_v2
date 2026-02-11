# Terraform OCI Provider (v2)

This repository contains Terraform configurations for managing Oracle Cloud Infrastructure (OCI) resources. It focuses on automated infrastructure deployment with a strong emphasis on security using `sops` and `age`.

&nbsp;

## 🚀 Quick Start
To set up the environment and deploy the infrastructure, please follow the detailed instructions in **[USAGE.md](./USAGE.md)**.

&nbsp;

### Brief Workflow:
1. **Configure Environment:** Install dependencies (age, direnv, sops) as described in `USAGE.md`.
2. **Key Generation:** Generate your `age` key and update `.sops.yaml`.
3. **Secret Management:** - Create your secrets in `keys/secret.json`.
   - Encrypt the file using: `sops -e keys/secret.json > keys/secret.enc.json`.
4. **Deploy:** Run Terraform commands within the `oci` directory.

&nbsp;

## ✨ Key Features
* **Secure Secret Management:** Utilizes `sops` and `age` for robust encryption of sensitive data (e.g., API keys, credentials), ensuring no plain-text secrets are stored in version control.
* **Environment Automation:** Integration with `direnv` automatically loads necessary environment variables and hooks upon entering the project directory.
* **Infrastructure as Code (IaC):** Fully declarative OCI resource management using Terraform, supporting repeatable and scalable deployments.
* **Modular Scripting:** Includes specialized scripts (e.g., WireGuard configuration) that are automatically injected and decrypted during the instance initialization process.
* **Optimized for OCI:** Custom-tailored configurations for OCI Compute, Network, and Storage services.

&nbsp;

---
*Note: This document was authored by a non-native English speaker with the assistance of AI.*
