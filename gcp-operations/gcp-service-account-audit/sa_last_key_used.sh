#!/bin/bash

# Configuration
projects_file="projects.txt"
output_file="sa_last_key_used.csv"

# 1. Create the header with specific columns for Email and Key ID
echo "project,lastAuthenticatedTime,serviceAccountEmail,keyId,observationEndTime,observationStartTime" > "$output_file"

while IFS= read -r project || [ -n "$project" ]; do
    [[ -z "$project" ]] && continue
    
    echo "Processing project: $project"

    # 2. Run the command and process with awk
    gcloud policy-intelligence query-activity \
    --activity-type=serviceAccountKeyLastAuthentication \
    --project="$project" \
    --format="csv[no-heading](activity.lastAuthenticatedTime, activity.serviceAccountKey.fullResourceName, observationPeriod.endTime, observationPeriod.startTime)" | \
    awk -v p="$project" -F',' 'NF >= 4 {
        # 1. Trim all timestamps to YYYY-MM-DD
        auth_date  = substr($1, 1, 10)
        end_date   = substr($3, 1, 10)
        start_date = substr($4, 1, 10)
        
        # 2. Parse the Full Resource Name
        # Format: //iam.../serviceAccounts/EMAIL/keys/KEY_ID
        n = split($2, parts, "/")
        
        sa_email = parts[n-2]  # The email is 2 spots before the end
        key_id   = parts[n]    # The key ID is the very last part
        
        # 3. Print the consolidated clean line
        print p "," auth_date "," sa_email "," key_id "," end_date "," start_date
    }' >> "$output_file"
    sleep 2

done < "$projects_file"

echo "Finished! All data consolidated in $output_file"