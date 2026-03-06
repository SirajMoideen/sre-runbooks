#!/bin/bash
set -euo pipefail

#Run in linux enviroment

# === Service Account Key Rotation ===
SERVICE_ACCOUNT="backup-sa@project-id.iam.gserviceaccount.com"
SECRET_NAME="SERVICE_ACCOUNT_KEY"
PROJECT_ID="project-id"
DAYS_THRESHOLD=10   # rotate if expiring in <= 10 days
KEY_FILE="/app/key.json"

# Get existing key info (latest one)
EXISTING_KEY_INFO=$(gcloud iam service-accounts keys list \
  --iam-account="$SERVICE_ACCOUNT" \
  --project="$PROJECT_ID" \
  --format="value(name, validBeforeTime)" \
  --sort-by="~validBeforeTime" \
  --limit=1)

if [[ -n "$EXISTING_KEY_INFO" ]]; then
    KEY_NAME=$(echo "$EXISTING_KEY_INFO" | awk '{print $1}')
    EXPIRE_DATE=$(echo "$EXISTING_KEY_INFO" | awk '{print $2}')

    EXPIRE_EPOCH=$(date -d "$EXPIRE_DATE" +%s)
    NOW_EPOCH=$(date +%s)
    DAYS_LEFT=$(( (EXPIRE_EPOCH - NOW_EPOCH) / 86400 ))

    echo "Current key expires in $DAYS_LEFT days"

    if (( DAYS_LEFT <= DAYS_THRESHOLD )); then
        echo "Expiring soon → creating new key..."
        gcloud iam service-accounts keys create "$KEY_FILE" \
          --iam-account="$SERVICE_ACCOUNT" \
          --project="$PROJECT_ID"

        gcloud secrets versions add "$SECRET_NAME" \
          --project="$PROJECT_ID" \
          --data-file="$KEY_FILE"

        echo "New key uploaded to Secret Manager."
    fi
else
    echo "No key found, creating one..."
    gcloud iam service-accounts keys create "$KEY_FILE" \
      --iam-account="$SERVICE_ACCOUNT" \
      --project="$PROJECT_ID"

    gcloud secrets versions add "$SECRET_NAME" \
      --project="$PROJECT_ID" \
      --data-file="$KEY_FILE"
fi

echo "script completed."