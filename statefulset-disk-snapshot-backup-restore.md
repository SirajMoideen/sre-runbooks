> **Note:** While restoring from a snapshot, make sure the disk Reclaim Policy (`persistentVolumeReclaimPolicy`) is set to `Retain` to prevent PV deletion while mounting the new volume.

# **Statefulset disk snapshot**

1. Volumesnapshotclass should be in a cluster. If it’s not, create one.  
   1. To check Volumesnapshotclass

```
k get volumesnapshotclass

##Describe command
k describe volumesnapshotclass gitlab-snapshot-manual
```

   2. **To create a VolumeSnapshotClass**, save the below as yaml (name: `volumesnapshotclass.yaml`)

```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: gcp-pd-snapshot-class
driver: pd.csi.storage.gke.io
deletionPolicy: Retain
```

   3. Apply the yaml

```
k apply -f volumesnapshotclass.yaml
```

2. **Take the snapshot of the StatefulSet disk**

   1. Create the below yaml and specify the disk(name: snapshot-gitlab.yaml)

```
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: gitlab-snapshot-manual ##VolumeSnapshot name
  namespace: default ##namespace
spec:
  volumeSnapshotClassName: gcp-pd-snapshot-class ##VolumeSnapshot class name
  source:
    persistentVolumeClaimName: gitlab-stg-pvc ##PVC Name
```

   2. Remove \#\# and values then Apply the yaml

```
k apply -f snapshot-gitlab.yaml
```

   3. Verify using below command

```
k get volumesnapshot

##Describe command
k describe volumesnapshot gitlab-snapshot-manual
```

   4. Wait until READYTOUSE = true

3. Done!

# Restoring disk from snapshot

1. Use the below yaml to restore the disk from snapshot (name: pvc-restore-gitlab.yaml)

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitlab-pvc ##PVC Name
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard-rwo
  resources:
    requests:
      storage: 5Gi
  dataSource:
    name: gitlab-snapshot-manual ##Snapshot name
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

2. Remove the "##" and values then apply

```
k apply -f pvc-restore-gitlab.yaml

##To check
k get pvc
```

# Restore a statefulset disk from compute engine snapshot

1. Create a normal snapshot of pvc
   (Placeholder: Screenshot showing the creation of a disk snapshot in the GCP Console)

2. Create disk from the snapshot
   (Placeholder: Screenshot showing disk creation from an existing snapshot in the GCP Console)

   **OR**

   **Clone the disk**

3. Create a pv using the below yaml

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab-restored-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  gcePersistentDisk:
    pdName: gitlab-restored-disk
    fsType: ext4
```

4. Create a PVC using the below yaml

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitlab-restored-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: manual
```

5. Attach the volume to the statefulset app yaml (check the redmarks

eg: gitlab devtron application

```yaml
data:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: gitlab-restored-pv
  spec:
    capacity:
      storage: 10Gi
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    storageClassName: manual
    gcePersistentDisk:
      pdName: gitlab-test-disk
      fsType: ext4

- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: gitlab-restored-pvc
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 10Gi
    storageClassName: manual

- apiVersion: apps/v1
  kind: StatefulSet
  metadata:
    name: gitlab
  spec:
    serviceName: gitlab
    replicas: 1
    selector:
      matchLabels:
        app: gitlab
    template:
      metadata:
        labels:
          app: gitlab
      spec:
        tolerations:
        - effect: NoSchedule
          key: node_group
          operator: Equal
          value: example-node-group
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: node_group
                      operator: In
                      values:
                        - example-node-group
        containers:
        - name: gitlab
          image: gitlab/gitlab-ce:17.10.0-ce.0
          ports:
          - containerPort: 80
            name: http
          - containerPort: 443
            name: https
          - containerPort: 22
            name: ssh
          env:
          - name: GITLAB_OMNIBUS_CONFIG
            value: |
              external_url 'https://gitlab.example.com'
              nginx['listen_port'] = 80
              nginx['listen_https'] = false
          - name: GITLAB_ROOT_PASSWORD
            value: <YOUR_STRONG_PASSWORD>
          volumeMounts:
          - name: gitlab-restored-pv
            mountPath: /var/opt/gitlab
          resources:
            requests:
              cpu: "1"
              memory: "2Gi"
            limits:
              cpu: "1"
              memory: "4Gi"
        volumes:
        - name: gitlab-restored-pv
          persistentVolumeClaim:
            claimName: gitlab-restored-pvc

- apiVersion: v1
  kind: Service
  metadata:
    name: gitlab-service
  spec:
    type: LoadBalancer
    selector:
      app: gitlab
    externalTrafficPolicy: Local
    ports:
    # - name: http
    #   port: 80
    #   targetPort: 80
    - name: https
      port: 80
      targetPort: 80
    # - name: ssh
    #   port: 22
    #   targetPort: 22
    loadBalancerSourceRanges:
    - <PUBLIC_IP_RANGE>
```

6. If there is any issues, check the logs/describe of pod and statefulset
   Note: I faced the issue like the previous volume was still shown in stateful. I followed below steps and fixed it
1. Edit the statefulset

```
k edit sts gitlab

##Remove the volume manually
  gitlab-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  gitlab-pvc
    ReadOnly:   false
```


2. Delete the pod
3. Now application will start normally

7. Done.
