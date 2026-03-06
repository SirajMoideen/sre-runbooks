#!/bin/bash

# Configuration
projects_file="projects.txt"
output_file="sa_last_used.csv"

# 1. Create the header
echo "project,lastAuthenticatedTime,serviceAccountEmail,observationEndTime,observationStartTime" > "$output_file"

while IFS= read -r project || [ -n "$project" ]; do
    [[ -z "$project" ]] && continue
    
    echo "Processing project: $project"

    # 2. Run gcloud and use awk to clean up the URI and Timestamps
    gcloud policy-intelligence query-activity \
    --activity-type=serviceAccountLastAuthentication \
    --project="$project" \
    --format="csv[no-heading](activity.lastAuthenticatedTime, fullResourceName, observationPeriod.endTime, observationPeriod.startTime)" | \
    awk -v p="$project" -F',' 'NF >= 4 {
        # 1. Trim timestamps to YYYY-MM-DD
        auth_date  = substr($1, 1, 10)
        end_date   = substr($3, 1, 10)
        start_date = substr($4, 1, 10)
        
        # 2. Extract the SA email from the full resource name
        # Splits "//iam.../serviceAccounts/name@email.com" by "/"
        # n is the number of parts; we take the last part (parts[n])
        n = split($2, parts, "/")
        sa_email = parts[n]
        
        # 3. Print the clean CSV line
        print p "," auth_date "," sa_email "," end_date "," start_date
    }' >> "$output_file"
    sleep 2

    echo "Data for $project appended."
done < "$projects_file"

echo "Done! Saved to: $output_file"