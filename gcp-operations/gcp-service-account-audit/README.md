# GCP Service Account Audit

Collection of scripts to audit Google Cloud service accounts across multiple projects.

The scripts help collect information such as:
- Service account details
- Last authentication activity
- Service account key usage
- IAM roles assigned to service accounts

All scripts read project IDs from `projects.txt`.

---

## Requirements

Install required tools:

- gcloud CLI
- jq
- Python 3

---

## Input

Create a file named `projects.txt` containing project IDs.

Example:

project-alpha
project-beta
project-production

---

## Scripts

export_service_accounts.sh

Exports all service accounts from the listed projects.

Run:
```bash
chmod +x export_service_accounts.sh
./export_service_accounts.sh
```
Output:

gcp_service_accounts.csv

---

sa_last_used.sh

Retrieves the last authentication time of service accounts.

Run:
```bash
chmod +x sa_last_used.sh
./sa_last_used.sh
```
---

sa_last_key_used.sh

Retrieves the last usage information for service account keys.

Run:
```bash
chmod +x sa_last_key_used.sh
./sa_last_key_used.sh
```
---

sa_roles_get.py

Exports IAM roles assigned to service accounts across projects.

Run:
```bash
python3 sa_roles_get.py
```
Output:

service_account_report.csv

---

## Use Case

These scripts help with:

- IAM auditing
- Security reviews
- Identifying unused service accounts
- Tracking service account key usage
- Reviewing IAM role assignments
EOF