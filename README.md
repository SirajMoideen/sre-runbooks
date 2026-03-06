# SRE Runbooks & Automation Toolkit

A collection of **Site Reliability Engineering (SRE) runbooks, automation scripts, and operational tools** used to manage cloud infrastructure, containers, monitoring systems, and production operations.

This repository demonstrates practical experience in:

* Cloud operations (GCP)
* Container management (Docker)
* Kubernetes operations
* Database administration (MongoDB, PostgreSQL)
* Infrastructure troubleshooting
* Monitoring and observability
* Security and auditing
* Production runbooks and automation

All documentation is **sanitized for public use** and intended for learning, reference, and operational guidance.

---

## Repository Structure

```
.
├── docker-cleanup-runbook.md
├── docker-network-range-conflict-fix.md
├── gitlab-runner-management.md
├── k8s-mongodb-version-upgrade.md
├── mongodb-k8s-backup-guide.md
├── nginx-reverse-proxy-runbook.md
├── postgresql-db-administration-cheatsheet.md
├── statefulset-disk-snapshot-backup-restore.md
├── ubuntu-install-gui-on-cli.md
│
├── gcp-operations
│   ├── gcp-disk-migration
│   ├── gcp-resource-inventory
│   ├── gcp-sa-key-rotation
│   └── gcp-service-account-audit
│
├── prometheus-grafana-dashboards
│
├── spreadsheet-formula
│
└── website-ssl-check
```

---

## Runbooks

Operational guides for common production tasks.

### Docker Cleanup

`docker-cleanup-runbook.md`

Remove unused Docker containers, images, volumes, and networks to free disk space.

---

### Docker Network Range Conflict Fix

`docker-network-range-conflict-fix.md`

Resolve private network conflicts caused by Docker bridge networks overlapping with infrastructure networks.

---

### GitLab Runner Management

`gitlab-runner-management.md`

Guide to install, manage, and troubleshoot GitLab runners used in CI/CD pipelines.

---

### Nginx Reverse Proxy

`nginx-reverse-proxy-runbook.md`

Configure Nginx to expose internal applications securely over HTTPS using reverse proxy.

---

### StatefulSet Disk Backup & Restore

`statefulset-disk-snapshot-backup-restore.md`

Procedure to create snapshots of persistent volumes and restore stateful workloads safely.

---

### Install GUI on Ubuntu Server

`ubuntu-install-gui-on-cli.md`

Install a desktop environment on an Ubuntu CLI server.

Useful for lab environments, debugging, and local tools.

---

## Database Operations

Runbooks and reference guides for database administration and lifecycle management.

### MongoDB & Kubernetes Operator Upgrade

`k8s-mongodb-version-upgrade.md`

Step-by-step runbook for upgrading MongoDB across multiple major versions (5.0 → 6.0 → 7.0 → 8.0) in Kubernetes environments.

Covers:

* Staged version upgrades with Feature Compatibility Version (FCV) management
* MongoDB Kubernetes Operator and CRD upgrades
* Readiness probe troubleshooting
* Monitoring commands during the upgrade process

---

### Automated MongoDB Backups to GCS

`mongodb-k8s-backup-guide.md`

Guide for automating MongoDB backups to Google Cloud Storage using a Kubernetes CronJob.

Covers:

* Custom Docker image with MongoDB tools and Google Cloud SDK
* Kubernetes CronJob and ConfigMap manifests
* Manual backup and restoration procedures
* Database validation with `mongosh`

---

### PostgreSQL DBA Cheat Sheet

`postgresql-db-administration-cheatsheet.md`

Essential PostgreSQL queries and CLI utilities for day-to-day database administration.

Covers:

* Database and connection management
* Table and permission management
* Backup and restore with `pg_dump` / `pg_restore`
* Google Cloud SQL storage shrink operations

---

## GCP Operations

Automation scripts for managing Google Cloud infrastructure.

### Disk Migration

```
gcp-operations/gcp-disk-migration
```

Script to recreate disks from images.

Use cases:

* Disk migration
* Disk cloning
* Instance recovery

Script:

```
disk_recreate_from_image.sh
```

---

### Resource Inventory

```
gcp-operations/gcp-resource-inventory
```

Collect a full inventory of GCP resources.

Useful for:

* Infrastructure audits
* Cost analysis
* Compliance checks

Script:

```
gcp-resources.sh
```

---

### Service Account Key Rotation

```
gcp-operations/gcp-sa-key-rotation
```

Automates the rotation of service account keys.

Improves security by removing old keys and generating new ones.

Script:

```
gcp_sa_key_rotation.sh
```

---

### Service Account Audit

```
gcp-operations/gcp-service-account-audit
```

Tools to analyze service account usage and permissions.

Includes:

* Last key usage
* Last account usage
* Role assignments
* Service account export

Scripts:

```
export_service_accounts.sh
sa_last_key_used.sh
sa_last_used.sh
sa_roles_get.py
```

---

## Monitoring Dashboards

```
prometheus-grafana-dashboards
```

Example Grafana dashboards used with Prometheus monitoring.

Includes:

* Kubernetes pod monitoring dashboards

File:

```
pod-monitoring-dashboard.json
```

---

## SSL Monitoring Tool

```
website-ssl-check
```

Script to check SSL certificate expiry for multiple websites.

Helps prevent unexpected certificate expiration.

Files:

```
website_ssl_checker.sh
check_ssl_websites.txt
```

Outputs log files with certificate expiry status.

---

## Spreadsheet Utilities

```
spreadsheet-formula
```

Examples of spreadsheet formulas and sample datasets used for operational reporting.

Files:

```
sample-data.csv
```

---

## Skills Demonstrated

This repository highlights practical SRE skills including:

* Cloud Infrastructure (GCP)
* Bash Automation
* Python scripting
* Docker operations
* Kubernetes operations
* MongoDB administration and upgrades
* PostgreSQL administration
* Monitoring and observability
* Infrastructure auditing
* Security best practices
* Production troubleshooting
* Operational runbooks

---

## Usage

Clone the repository:

```
git clone https://github.com/sirajmoideen>/sre-runbooks.git
```

Navigate into the project:

```
cd sre-runbooks
```

Run scripts or follow the runbooks depending on the operational task.

---

## Disclaimer

All examples in this repository are **sanitized and generalized** versions of real operational procedures.

No internal infrastructure details, credentials, or sensitive data are included.

---

## Author

**Siraj**

Site Reliability Engineer
Cloud | Kubernetes | Database | Infrastructure Automation
