# GCP Service Account Key Rotation

Bash script to automatically rotate a Google Cloud service account key when it is close to expiration.

The script:
- Checks the latest key for a service account
- Calculates remaining days until expiration
- Creates a new key if the expiration threshold is reached
- Uploads the new key to Google Secret Manager

## Requirements

- gcloud CLI
- jq (optional but recommended)
- Authenticated gcloud session

## Configuration

Edit the variables in the script:

```bash
SERVICE_ACCOUNT="service-account@project-id.iam.gserviceaccount.com"
SECRET_NAME="SECRET_NAME"
PROJECT_ID="project-id"
DAYS_THRESHOLD=10
```

## Run

```bash
chmod +x gcp_sa_key_rotation.sh
./gcp_sa_key_rotation.sh
```

## Use Case

Useful for automating service account key rotation and storing updated credentials in Secret Manager.