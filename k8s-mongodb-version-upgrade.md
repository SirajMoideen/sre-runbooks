# MongoDB and Kubernetes Operator Upgrade Runbook

**Objective:** Upgrade MongoDB in Development and Staging environments from version `5.0.6` to `8.0.10`. This process includes intermediate MongoDB upgrades to versions `6.0.19` and `7.0.21`, as well as corresponding upgrades to the MongoDB Kubernetes Operator.

**Prerequisites & Environment Details:**
- Current MongoDB version: `5.0.6`
- Current Operator version: `0.7.6`
- *Note: MongoDB 7.0+ is incompatible with Operator 0.7.6, requiring a staged Operator upgrade.*

## 1. Version Check & Helm Repositories

First, ensure local Helm repositories are up to date and check for available versions.

```bash
helm repo add mongodb https://mongodb.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo mongodb --versions
```

## 2. Phase 1: MongoDB Upgrade to 6.0.19

### 2.1. Backup Existing Database

Take a backup of the staging MongoDB instance before initiating the upgrade.

```bash
mongodump --uri="mongodb://<admin-user>:<admin-password>@app-mongo.staging.example.com:27017" --out=stage-backup-YYYY-MM-DD
```

### 2.2. Update Deployment Version

1. Edit the MongoDB deployment manifest to update the image version from `5.0.6` to `6.0.19`.
2. Apply the changes. Wait for the pods to roll out and stabilize.

### 2.3. Update Feature Compatibility Version (FCV)

Keep the `featureCompatibilityVersion` at `5.0` until sanity checks are completed successfully. This ensures a safe rollback path if needed. Once verified, update the FCV:

```yaml
featureCompatibilityVersion: "6.0"
```
*Note: FCV must be updated to 6.0 before proceeding to MongoDB 7.0.*

### 2.4. Verification

Access the primary pod and verify the version upgrade.

```bash
# Connect to the MongoDB instance
mongosh "mongodb://<admin-user>:<admin-password>@app-mongo.staging.example.com:27017"

# Check FCV
db.adminCommand({ getParameter: 1, featureCompatibilityVersion: 1 })
```

---

## 3. Phase 2: CRD and operator Upgrades

To support higher MongoDB versions, the Kubernetes Operator and Custom Resource Definitions (CRDs) must be upgraded.

### Step 3.1. Backup Existing Resources

Backup the current CRDs and `mongodbcommunity` resources.

```bash
# CRD backup
kubectl get crd mongodbcommunity.mongodbcommunity.mongodb.com -o yaml > mongodb-kubernetes-operator-crd.yml

# Take backups of all existing MongoDB Custom Resources
kubectl get mongodbcommunity app-mongo -n app-mongodb -o yaml > app-mongo-backup.yaml
kubectl get mongodbcommunity payment-mongo -n payment-mongo -o yaml > payment-mongo-backup.yaml
```

### Step 3.2. Operator and CRD Upgrade (Target 0.13.0)

**Option 1: Direct Upgrade using Helm / CI Tool**

1. Within your deployment configuration values, update the Operator version:
   ```yaml
   # Change from:
   version: 0.9.0
   # To:
   version: 0.13.0
   ```
2. Update the Helm Chart version to `0.13.0`.
3. Apply the changes. The CRDs should be automatically updated with the Operator deployment.
4. Verify the CRD version:
   ```bash
   kubectl get crd mongodbcommunity.mongodbcommunity.mongodb.com -o yaml | more
   ```

*Note: Wait until all MongoDB pods have successfully restarted. If pods fail readiness checks in specific namespaces, adjust the `watchNamespace` parameter in the Operator configuration from `*` to specific namespaces.*

**Option 2: Manual CRD Application (Target 0.9.0 as intermediate)**

If a direct upgrade to 0.13.0 is not feasible, step through 0.9.0 first.

1. Download and apply the `0.9.0` CRD manually:
   ```bash
   curl -Lo mongodb-kubernetes-crd-0.9.0.yaml https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/v0.9.0/config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml
   
   kubectl apply -f mongodb-kubernetes-crd-0.9.0.yaml
   ```
2. Verify synchronization in your GitOps tool (e.g., ArgoCD). Address any synchronization mismatches by explicitly editing the CRD if necessary (`kubectl edit crd ...`).
3. Update Operator values to `0.9.0` and configure the `watchNamespace` accordingly.

### Step 3.3. Mitigation for Readiness Probe Errors

If readiness probe errors occur during the upgrade across specific versions, update the deployment patch for both `mongod` and `mongodb-agent` containers to include the correct `AGENT_STATUS_FILEPATH`:

```yaml
containers:
  - name: mongod
    env:
      - name: AGENT_STATUS_FILEPATH
        value: /var/log/mongodb-mms-automation/healthstatus/agent-health-status.json
    volumeMounts: 
      - name: healthstatus
        mountPath: /var/log/mongodb-mms-automation/healthstatus
  - name: mongodb-agent
    readinessProbe:
      exec:
        command:
          - /opt/scripts/readinessprobe
      failureThreshold: 40
      initialDelaySeconds: 120
      periodSeconds: 20
      successThreshold: 1
      timeoutSeconds: 10
    env:
      - name: AGENT_STATUS_FILEPATH
        value: /var/log/mongodb-mms-automation/healthstatus/agent-health-status.json
    volumeMounts:
      - name: healthstatus
        mountPath: /var/log/mongodb-mms-automation/healthstatus
```

---

## 4. Phase 3: MongoDB Upgrade to 8.0.x

*(Assuming intermediate upgrades to 7.0.x are completed following the same steps as Phase 1)*

### 4.1. Backup

```bash
mongodump --uri="mongodb://<admin-user>:<admin-password>@app-mongo.development.example.com:27017" --out=dev-backup-YYYY-MM-DD
```

### 4.2. Update Version and FCV

1. Update the image version in your manifest from `7.0.21` to `8.0.11` and deploy.
2. Wait for successful pod rollout.
3. Update the `featureCompatibilityVersion` to `8.0`:

```yaml
featureCompatibilityVersion: "8.0"
```

### 4.3. Final Verification

1. Log into the primary pod:
   ```bash
   mongosh "mongodb://<admin-user>:<admin-password>@app-mongo.development.example.com:27017"
   ```
2. Verify the compatibility version and replica set status:
   ```javascript
   db.adminCommand({ getParameter: 1, featureCompatibilityVersion: 1 });
   rs.status();
   ```

## 5. Helpful Monitoring Commands

Use the following commands to monitor the cluster state during the upgrade process:

```bash
# Monitor MongoDB Custom Resources
watch "kubectl get mongodbcommunity -A"

# Monitor StatefulSets
watch "kubectl get sts"

# Monitor specific pod logs
stern app-mongo --since 1m
stern mongodb-kubernetes-operator --since 1m

# General pod status monitoring
watch "kubectl get pods"
```
