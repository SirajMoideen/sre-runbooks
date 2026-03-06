#!/bin/bash

#To Run: echo "n" | ./gcs-resources.sh

# Define the projects you want to query
projects=(
  "project-alpha"
  "project-beta"
  "project-gamma"
  "project-staging"
  "project-production"
)

# Output file
output_file="gcp_resources_inventory.csv"

# Write header
echo "Project,Resource Name,Resource Type,Private IP,Public IP (Primary),Public IP (Outgoing)" > "$output_file"

# Loop through each project
for project in "${projects[@]}"; do
    echo "Processing project: $project"
    gcloud config set project "$project" > /dev/null

    # ========================================
    # Compute Engine Instances
    # ========================================
    instances=$(gcloud compute instances list --format="csv[no-heading](name,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)")
    while IFS=',' read -r name private_ip public_ip; do
        echo "$project,$name,Compute Instance,$private_ip,$public_ip," >> "$output_file"
    done <<< "$instances"

    # ========================================
    # Cloud SQL Instances (fully safe parsing)
    # ========================================
    gcloud sql instances list --format=json | jq -r --arg project "$project" '
      .[] |
      {
        name: .name,
        ipAddresses: (.ipAddresses // [])
      } |
      . as $inst |
      reduce $inst.ipAddresses[]? as $ip (
        {
          private: "",
          primary: "",
          outgoing: ""
        };
        if $ip.type == "PRIVATE" then .private = $ip.ipAddress
        elif $ip.type == "PRIMARY" then .primary = $ip.ipAddress
        elif $ip.type == "OUTGOING" then .outgoing = $ip.ipAddress
        else . end
      ) + {
        project: $project,
        name: $inst.name
      } |
      "\(.project),\(.name),SQL Instance,\(.private),\(.primary),\(.outgoing)"
    ' >> "$output_file"

    # ========================================
    # GKE Clusters
    # ========================================
    gke_clusters=$(gcloud container clusters list --format="csv[no-heading](name,endpoint)")
    while IFS=',' read -r name endpoint; do
        echo "$project,$name,GKE Cluster,,$endpoint," >> "$output_file"
    done <<< "$gke_clusters"

    # ========================================
    # Load Balancers (Forwarding Rules)
    # ========================================
    forwarding_rules=$(gcloud compute forwarding-rules list --format="csv[no-heading](name,IPAddress)")
    while IFS=',' read -r name ip; do
        echo "$project,$name,Load Balancer,,$ip," >> "$output_file"
    done <<< "$forwarding_rules"

done

echo "Resource listing complete. Output saved to: $output_file"

