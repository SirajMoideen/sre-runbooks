# CentOS 7 to Rocky Linux 8 Migration Guide

## Overview
This guide outlines the process for migrating a CentOS 7 system to Rocky Linux 8 using the Leapp migration tool. This project demonstrates expertise in Linux system administration, package management, and troubleshooting migration challenges. The migration ensures compatibility, security updates, and long-term support by transitioning to a community-supported enterprise Linux distribution.

## Prerequisites
- Ensure you have administrative access to the system.
- Back up all critical data and configurations before proceeding.
- Verify system compatibility with Rocky Linux 8 requirements.

## Migration Steps

### 1. Update CentOS to the Latest Version
Check the current CentOS release and update to the latest version:

```bash
cat /etc/centos-release
sudo yum update centos-release -y
sudo reboot
cat /etc/centos-release
```

### 2. Install the Elevate Repository
Install the repository required for the migration:

```bash
sudo yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el$(rpm --eval %rhel).noarch.rpm
```

### 3. Install Leapp and Rocky Linux Packages
Install the necessary packages for the upgrade:

```bash
sudo yum install -y leapp-upgrade leapp-data-rocky
```

### 4. Install Additional Dependencies
Ensure required libraries are installed:

```bash
sudo yum install glib2 -y
```

### 5. Run Pre-Upgrade Assessment
Perform a pre-upgrade check to identify potential issues:

```bash
sudo leapp preupgrade
```

### 6. Troubleshoot Common Errors
If you encounter "ImportError: cannot import name UnrewindableBodyError", resolve it by reinstalling affected packages:

```bash
# Uninstall problematic packages
sudo pip uninstall requests -y
sudo pip uninstall urllib3 -y
sudo yum remove python-urllib3 -y
sudo yum remove python-requests -y

# Verify removal
rpm -qa | grep requests
pip freeze | grep requests

# Reinstall using yum
sudo yum install python-urllib3 -y
sudo yum install python-requests -y
```

Address upgrade inhibitors as needed:

```bash
# For missing answers in answer file
sudo leapp answer --section remove_pam_pkcs11_module_check.confirm=True

# For duplicate repository definitions
cd /etc/yum.repos.d/
# Remove conflicting repo files (e.g., duplicate or unnecessary repos)
sudo leapp preupgrade
```

### 7. Perform the Upgrade
Once all issues are resolved, execute the upgrade:

```bash
sudo leapp upgrade
sudo reboot
cat /etc/rocky-release
```

## Post-Migration Verification
- Confirm the system is running Rocky Linux 8.
- Update and install any additional packages as needed.
- Test critical applications and services.