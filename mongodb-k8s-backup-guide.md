# Automated MongoDB Backups to GCS using Kubernetes CronJobs

## Overview
This repository contains a comprehensive configuration for automating MongoDB backups and uploading them to Google Cloud Storage (GCS). It leverages a Kubernetes CronJob that executes a custom-built Docker container containing MongoDB tools and the Google Cloud SDK.

## Prerequisites
- A Google Cloud Storage (GCS) bucket.
- A Google Cloud Service Account with `Storage Object Admin` permissions.
- A Kubernetes Cluster with `kubectl` configured.
- Connection details for the MongoDB instance.

---

## 1. Setup Service Account & GCS Bucket
1. Create a GCS bucket to store your database backups. Set a lifecycle policy (e.g., retain files for 7 days) to manage storage costs.
2. Provide `Storage Object Admin` or equivalent write access to a dedicated GCP Service Account.
3. Generate and download the JSON key for this Service Account.

---

## 2. Docker Image Preparation
We build a custom Docker image equipped with both the necessary MongoDB backup tools and the Google Cloud SDK for uploading to GCS.

### `Dockerfile`
```dockerfile
# Use an official Ubuntu image as a base
FROM ubuntu:20.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and tools
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates && \
    # Add the MongoDB GPG key and repository
    curl -fsSL https://pgp.mongodb.com/server-4.4.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] http://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    # Install MongoDB tools
    apt-get update && apt-get install -y mongodb-org-tools && \
    # Add the Google Cloud SDK repository
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    # Install Google Cloud SDK
    apt-get update && apt-get install -y google-cloud-sdk && \
    # Clean up APT when done
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Build and Push Image
```bash
# Build the image for your platform
docker build --platform linux/amd64 -t <your-registry>/mongo-backup:latest .

# Push the image to your container registry
docker push <your-registry>/mongo-backup:latest
```

---

## 3. Kubernetes Deployment

### Create the Service Account Secret
Create a Kubernetes secret containing your downloaded GCP service account JSON key:
```bash
kubectl create secret generic mongodb-backup-sa --from-file=key.json=path/to/mongo-backup-sa.json
```

### Apply Kubernetes Manifests
The following YAML defines the `CronJob` to run the backup daily, a `ConfigMap` containing the backup bash script, and mounts the secret created in the previous step.

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongo-backup-cron
spec:
  schedule: "30 20 * * *" # Runs daily at 20:30
  suspend: false
  jobTemplate:
    spec: 
      template:
        spec:
          containers:
          - name: mongodb-bkp
            image: <your-registry>/mongo-backup:latest
            securityContext:
              runAsUser: 0
            args:
              - gcloud auth activate-service-account --key-file /root/key.json && /scripts/bkp-script.sh
            command: ["/bin/bash", "-c"]
            env:
            - name: MONGO_DATABASE
              value: "<target_database_name>"
            - name: BACKUP_DIR
              value: "/tmp/mongo-backups"
            - name: GCS_BUCKET
              value: "<your_gcs_bucket_name>"
            - name: MONGO_URI
              value: "mongodb://<username>:<password>@<mongo_host>:27017/<target_database_name>"
            volumeMounts:
            - mountPath: /root/key.json
              name: gcloud-service-account-key
              subPath: key.json
            - mountPath: /scripts
              name: mongo-bkp-script
          restartPolicy: OnFailure
          volumes:
          - configMap:
              name: mongo-bkp-script-cm
              defaultMode: 0777
            name: mongo-bkp-script
          - name: gcloud-service-account-key
            secret:
              defaultMode: 0777
              secretName: mongodb-backup-sa

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mongo-bkp-script-cm
data:
  bkp-script.sh: |
    #!/bin/bash
    mkdir -p $BACKUP_DIR
    
    # Process the MongoDB dump
    mongodump --uri=$MONGO_URI --out=$BACKUP_DIR
    
    # Authenticate and copy the backup to Google Cloud Storage with timestamp
    gsutil cp -r ${BACKUP_DIR}/${MONGO_DATABASE} gs://${GCS_BUCKET}/${MONGO_DATABASE}-"$(date -d "+5 hours 30 minutes" +"%Y-%m-%d")"
    
    # Local cleanup
    rm -rf ${BACKUP_DIR}
```

---

## 4. Manual Operations & Restoration Reference

### Generate Manual Backup
To manually target and pull a database backup to your local machine:
```bash
mongodump --uri="mongodb://<username>:<password>@<mongo_host>:27017" --out=./backup-dir
```

### Restore Database
To restore a full dump directory or targeted collection:
```bash
# General Restoration from standard dump directory
mongorestore --host <mongo_host> --port 27017 -u <username> -p <password> <PathToDump>/

# Restoring a specific Collection from JSON
mongoimport --uri="mongodb://<username>:<password>@<mongo_host>:27017/<database_name>" --collection=<collection_name> --file=data.json

# Upsert without affecting unmodified live data
mongoimport --uri="mongodb://<username>:<password>@<mongo_host>:27017/<database_name>" --collection=<collection_name> --file=data.json --mode=upsert
```

### Advanced Restorations
To restore existing data into a *new* database namespace:
```bash
mongorestore --nsInclude "<new_db_name>.*" --nsFrom "<original_db_name>.*" /path/to/backup/directory
```

### Validation & Management
CLI commands to verify database state using `mongosh`:
```bash
# Connect
mongosh "mongodb://<username>:<password>@<mongo_host>:27017"

# Inspect data
> show databases
> use <database_name>
> show collections
> db.<collection_name>.find().limit(5)

# Drop a database safely
> use <database_to_delete>
> db.dropDatabase()
```
