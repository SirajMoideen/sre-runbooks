#!/bin/bash

DRY_RUN=false

# Configuration
SOURCE_PROJECT="source-project-id"
DEST_PROJECT="destination-project-id"
ZONE="asia-south1-a"

# 1. & 2. Validation Loop for Source Disk Name and Type
while true; do
    read -p "Enter the Source Disk Name to migrate: " DISK_NAME

    if [ -z "$DISK_NAME" ]; then
        echo "Error: Source disk name cannot be empty."
        continue
    fi

    # Attempt to fetch the disk type
    SOURCE_DISK_TYPE=$(gcloud compute disks describe "$DISK_NAME" \
        --project="$SOURCE_PROJECT" \
        --zone="$ZONE" \
        --format="value(type.basename())" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$SOURCE_DISK_TYPE" ]; then
        break
    else
        echo "Error: Disk '$DISK_NAME' not found in project $SOURCE_PROJECT ($ZONE)."
    fi
done

# 3. Prompt for Destination Disk Name
read -p "Enter the Destination Disk Name (default:'$DISK_NAME'): " DEST_DISK_NAME
DEST_DISK_NAME=${DEST_DISK_NAME:-$DISK_NAME}

# 4. Improved Interactive Prompt for Disk Type
echo "Select the destination disk type:"
echo "1) pd-balanced"
echo "2) pd-ssd"
echo "3) pd-standard"
echo "Press [ENTER] to keep source type: ($SOURCE_DISK_TYPE)"

DISK_TYPE=""
while [ -z "$DISK_TYPE" ]; do
    read -p "Selection : " REPLY
    case $REPLY in
        1) DISK_TYPE="pd-balanced" ;;
        2) DISK_TYPE="pd-ssd" ;;
        3) DISK_TYPE="pd-standard" ;;
        "")
            DISK_TYPE=$SOURCE_DISK_TYPE
            echo "Using source default: $DISK_TYPE"
            ;;
        *) echo "Invalid option. Please choose 1, 2, 3 or press Enter." ;;
    esac
done

# Temporary Image Name
IMAGE_NAME="${DEST_DISK_NAME}"

echo ""
echo "Summary: $DISK_NAME ($SOURCE_DISK_TYPE) -> $DEST_DISK_NAME ($DISK_TYPE)"
echo "---------------------------------------------------"

# 5. Create Image
echo "[1/2] Creating temporary image '$IMAGE_NAME'..."
gcloud compute images create "$IMAGE_NAME" \
    --project="$SOURCE_PROJECT" \
    --source-disk="$DISK_NAME" \
    --source-disk-zone="$ZONE" \
    --force

# 6. Create Disk in Destination
echo "[2/2] Creating disk '$DEST_DISK_NAME' in $DEST_PROJECT..."
gcloud compute disks create "$DEST_DISK_NAME" \
    --project="$DEST_PROJECT" \
    --zone="$ZONE" \
    --image="projects/$SOURCE_PROJECT/global/images/$IMAGE_NAME" \
    --type="$DISK_TYPE"

# 7. Cleanup
echo "Cleaning up temporary image..."
gcloud compute images delete "$IMAGE_NAME" --project="$SOURCE_PROJECT" --quiet

echo "Done! Disk '$DEST_DISK_NAME' is ready in $DEST_PROJECT."