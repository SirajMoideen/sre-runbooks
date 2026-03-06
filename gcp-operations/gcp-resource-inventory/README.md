# GCP Resource Inventory

Bash script to collect infrastructure resources across multiple GCP projects.

The script gathers:

- Compute Engine instances
- Cloud SQL instances
- GKE clusters
- Load balancer forwarding rules

Results are exported to a CSV file.

## Requirements

- gcloud CLI
- jq

Authenticate with GCP:

gcloud auth login

## Usage

Make executable:
```bash
chmod +x gcp_resources_inventory.sh
```
Run the command below. The command automatically responds "no" if prompted to enable any GCP services.
```bash
echo "n" | ./gcp_resources_inventory.sh
```
## Output

Example CSV output:

Project,Resource Name,Resource Type,Private IP,Public IP (Primary),Public IP (Outgoing)
project-alpha,vm-1,Compute Instance,<PRIVATE_IP>,<PUBLIC_IP>,
project-beta,sql-db-1,SQL Instance,<PRIVATE_IP>,<PUBLIC_IP>,<PUBLIC_IP>
project-gamma,gke-prod,GKE Cluster,,<PUBLIC_IP>,