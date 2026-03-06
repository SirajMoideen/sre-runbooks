#!/bin/bash

# Configuration
PROJECTS_FILE="projects.txt"
OUTPUT_FILE="gcp_service_accounts.csv"

# 1. Create the Header
echo "Email,Status,Name,Description,Project" > "$OUTPUT_FILE"

# 2. Loop through projects.txt
while IFS= read -r PROJECT_ID || [ -n "$PROJECT_ID" ]; do
    # Skip empty lines
    [[ -z "$PROJECT_ID" ]] && continue
    
    echo "Fetching service accounts for project: $PROJECT_ID"

    # Get service accounts in JSON
    SERVICE_ACCOUNTS=$(gcloud iam service-accounts list \
        --project="$PROJECT_ID" \
        --format=json 2>/dev/null)

    # Error handling
    if [ $? -ne 0 ]; then
        echo "Failed to fetch service accounts for project: $PROJECT_ID" >&2
        continue
    fi

    # Parse and write to CSV
    # We use $PROJECT_ID as the display name column since the array is gone
    echo "$SERVICE_ACCOUNTS" | jq -r --arg PROJECT "$PROJECT_ID" '
        .[] | [
            .email,
            (if .disabled then "DISABLED" else "Enabled" end),
            .displayName // "N/A",
            .description // "N/A",
            $PROJECT
        ] | @csv
    ' >> "$OUTPUT_FILE"

    # Add a blank line after each project block (optional, as per your original script)
    echo "" >> "$OUTPUT_FILE"

    # Recommended: stay under rate limits
    sleep 1

done < "$PROJECTS_FILE"

echo "Export complete. File saved as: $OUTPUT_FILE"