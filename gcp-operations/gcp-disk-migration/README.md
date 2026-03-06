# GCP Disk Migration Script

Bash script to recreate a Compute Engine disk in another project using a temporary image.

The script:

- Creates an image from a source disk
- Creates a new disk in a destination project
- Allows selecting the destination disk type
- Cleans up the temporary image

## Requirements

- gcloud CLI
- Authenticated Google Cloud session

Login:

```bash
gcloud auth login
```

## Usage

Make executable:

```bash
chmod +x disk_recreate_from_image.sh
```

Run:

```bash
./disk_recreate_from_image.sh
```

The script will prompt for:

- source disk name
- destination disk name
- disk type

## Use Case

Useful when migrating disks between projects or environments.