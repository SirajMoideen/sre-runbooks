̌̆## 📈 Prometheus & Grafana Monitoring (PromQL)
*A collection of PromQL queries used for system monitoring, infrastructure alerting, and Grafana dashboard generation.*

### 🐳 Kubernetes (K8s) Workloads
| Use Case | PromQL Query |
| :--- | :--- |
| **Pod Memory Alert (>85%)** | `(avg(container_memory_usage_bytes{container!~"elasticsearch", namespace!~"logmon"}) by (container,namespace) / avg(kube_pod_container_resource_limits{resource="memory", namespace!~"logmon"}) by (container,namespace)) * 100 > 85` |
| **Pod CPU Alert (>70%)** | `avg by(container)(rate(container_cpu_usage_seconds_total[2m])) / avg by(container)(kube_pod_container_resource_limits{resource="cpu"}) * 100 > 70` |
| **Pod Unavailable / Down** | `kube_statefulset_status_replicas_available{statefulset!~"logstash-.*"} < 1 or (kube_deployment_status_replicas_unavailable{deployment!~"logstash.*"}) > 0` |
| **Container Restart Loop** | `increase(kube_pod_container_status_restarts_total{namespace!~"logmon|logmon-firewall"}[1m]) > 0` |
| **Pod Volume Capacity Alert** | `(kubelet_volume_stats_used_bytes)/(kubelet_volume_stats_capacity_bytes) * 100 > 85` |
| **Grafana: Pod Memory Graph** | `avg by(pod)(container_memory_usage_bytes{pod=~"$pod.*|$gp"}) / avg by(pod)(kube_pod_container_resource_limits{resource="memory", pod=~"$pod.*|$gp"}) * 100` |
| **Grafana: Pod CPU Graph** | `avg by(pod)(rate(container_cpu_usage_seconds_total{pod=~"$pod.*|$gp"}[2m])) / avg by(pod)(kube_pod_container_resource_limits{resource="cpu", pod=~"$pod.*|$gp"}) * 100` |

### ☁️ Google Cloud Platform (GCP) Virtual Machines
| Use Case | PromQL Query |
| :--- | :--- |
| **VM Memory Alert (>80%)** | `stackdriver_gce_instance_agent_googleapis_com_memory_percent_used{state="used"} > 80` |
| **VM CPU Utilization** | `sum by (instance_id) (stackdriver_gce_instance_agent_googleapis_com_cpu_utilization{cpu_state=~"user|system"})` |
| **VM Disk Volume Alert (>90%)** | `stackdriver_gce_instance_agent_googleapis_com_disk_percent_used{state="used", device=~"sd.*|/dev/sd.*"} > 90` |

### 🗄️ Cloud SQL & Databases
| Use Case | PromQL Query |
| :--- | :--- |
| **SQL Instance Down** | `stackdriver_cloudsql_database_cloudsql_googleapis_com_database_instance_state{state="RUNNABLE"} == 1` |
| **SQL Memory Alert (>80%)** | `avg_over_time(stackdriver_cloudsql_database_cloudsql_googleapis_com_database_memory_utilization[5m]) * 100 > 80` |
| **SQL CPU Alert (>90%)** | `avg_over_time(stackdriver_cloudsql_database_cloudsql_googleapis_com_database_cpu_utilization[10m]) * 100 > 90` |
| **SQL Disk Alert (>85%)** | `stackdriver_cloudsql_database_cloudsql_googleapis_com_database_disk_utilization * 100 > 85` |
| **SQL Disk usage increased by 3GB in the last 24 hours** | `cloudsql_googleapis_com:database_disk_bytes_used - min_over_time(cloudsql_googleapis_com:database_disk_bytes_used[24h]) > 3000000000` |

### ⚡ Redis Caching
| Use Case | PromQL Query |
| :--- | :--- |
| **Redis Uptime Warning** | `stackdriver_redis_instance_redis_googleapis_com_server_uptime <= 60` |
| **Redis Memory Utilization (>80%)** | `stackdriver_redis_instance_redis_googleapis_com_stats_memory_usage / stackdriver_redis_instance_redis_googleapis_com_stats_memory_maxmemory * 100 > 80` |
| **Redis CPU Alert (>80%)** | `stackdriver_redis_instance_redis_googleapis_com_stats_cpu_utilization{space="sys", relationship="parent"} > 80` |
| **Redis Evicted Keys Warning** | `stackdriver_redis_instance_redis_googleapis_com_stats_evicted_keys > 0` |

---
**Note:** Many of these alerts are optimized to exclude specific non-critical namespaces (e.g., `logmon`, `elasticsearch`) to prevent false-positive alert fatigue.