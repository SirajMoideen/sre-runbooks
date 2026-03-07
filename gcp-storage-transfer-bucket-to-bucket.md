# Event-Driven Data Synchronization with GCP Storage Transfer Service

This guide outlines the process for setting up a low-latency, event-driven transfer job using Google Cloud Storage (GCS) Transfer Service. This configuration ensures that objects added to a source bucket are automatically synchronized to a destination bucket via Pub/Sub notifications.

## Architecture Overview
1. **Source Bucket:** Triggers a notification on object creation/modification.
2. **Pub/Sub Topic:** Receives the notification event.
3. **Pub/Sub Subscription:** Pulls messages for the Storage Transfer Service.
4. **Storage Transfer Job:** Processes events from the subscription and executes the transfer to the destination.

---

## Step 1: Enable Pub/Sub Notifications on the Source Bucket

Configure the source bucket to emit events to a Pub/Sub topic. 

**Command Template:**
```bash
gcloud storage buckets notifications create gs://[SOURCE_BUCKET_NAME] \
    --topic=[TOPIC_NAME] \
    --project=[PROJECT_ID]
```

**Example:**
```bash
gcloud storage buckets notifications create gs://my-source-data-bucket \
    --topic=gcs-transfer-notifications \
    --project=my-production-project
```

## Step 2: Create a Pub/Sub Subscription

The Storage Transfer Service requires a subscription to listen for incoming events from the topic.

**Command Template:**
```bash
gcloud pubsub subscriptions create [SUBSCRIPTION_NAME] \
    --topic=[TOPIC_NAME] \
    --project=[PROJECT_ID]
```

**Example:**
```bash
gcloud pubsub subscriptions create gcs-transfer-sub \
    --topic=gcs-transfer-notifications \
    --project=my-production-project
```

## Step 3: Configure the Event-Driven Transfer Job

Follow these steps in the Google Cloud Console to finalize the transfer logic:

1.  **Navigate:** Go to the [Storage Transfer Service](https://console.cloud.google.com/transfer) page.
2.  **Initialize:** Click **Create Transfer Job**.
3.  **Source Type:** Select **Google Cloud Storage**.
4.  **Scheduling:** Select **Event-driven** (this enables real-time synchronization).
5.  **Event Stream:** Enter the full resource path of your Pub/Sub subscription.
    *   Format: `projects/[PROJECT_ID]/subscriptions/[SUBSCRIPTION_NAME]`
6.  **Destination:** Select your **Destination Bucket**.
7.  **Review & Create:** Configure any additional filter or deletion settings and click **Create**.

---

## Security Best Practices
- **Least Privilege:** Ensure the Storage Transfer Service Service Account has `roles/storage.objectViewer` on the source bucket and `roles/storage.objectAdmin` on the destination bucket.
- **Monitoring:** Enable Cloud Monitoring alerts for transfer job failures to ensure data consistency.
- **Validation:** Periodically run a one-time "overwrite" job to ensure complete synchronization if Pub/Sub messages are missed due to retention limits.