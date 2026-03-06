# GitLab Runner Management Runbook

## Overview
This runbook explains how to install, register, manage, verify, and remove GitLab runners on a Linux VM.  
It is intended for engineers managing CI/CD runners used by GitLab pipelines.

Sensitive information such as internal URLs and tokens should never be exposed publicly.  
Use placeholders when documenting or sharing this runbook.

Example placeholders:
- <GITLAB_URL>
- <RUNNER_TOKEN>
- <RUNNER_NAME>
- <SSH_USER>
- <RUNNER_VM>

---

## Registering a GitLab Runner

## 1. Connect to the Runner VM
```bash
ssh <SSH_USER>@<RUNNER_VM>
```
## 2. Register the Runner
```bash
sudo gitlab-runner register
```
Provide the following inputs when prompted.

Prompt | Value
------ | ------
GitLab instance URL | <GITLAB_URL>
Registration token | <RUNNER_TOKEN>
Description | Runner description (example: build-runner)
Tags | Optional tags used by CI jobs
Maintenance note | Leave empty
Executor | shell, docker, or another supported executor

Example:

Enter the GitLab instance URL: https://<GITLAB_URL>  
Enter the registration token: <RUNNER_TOKEN>  
Enter a description for the runner: build-runner  
Enter tags for the runner: build  
Enter optional maintenance note:  
Enter an executor: shell  

Successful output:

Runner registered successfully.

---

## Unregister a GitLab Runner

Remove a specific runner from the VM.
```bash
sudo gitlab-runner unregister --name <RUNNER_NAME>
```
---

## Remove a Runner from GitLab UI

1. Open the GitLab repository
2. Navigate to

Settings → CI/CD → Runners

3. Locate the runner under **Available specific runners**
4. Click **Remove runner**

After removing it in GitLab, clean up stale runners on the VM:
```bash
sudo gitlab-runner verify --delete
```
---

## Verify Runner Status

Verify runners without deleting:
```bash
sudo gitlab-runner verify
```
List registered runners on the VM:
```bash
sudo gitlab-runner list
```
---

## Check Runner Configuration
```bash
cat /etc/gitlab-runner/config.toml
```
---

## Check Runner Logs
```bash
sudo journalctl -u gitlab-runner.service --since today
```
---

## Check Runner Service Status
```bash
systemctl status gitlab-runner.service
```
Runner status using CLI:
```bash
sudo gitlab-runner status
```
---

## Manage Runner Service
```bash
Start runner service:

sudo gitlab-runner start

Stop runner service:

sudo gitlab-runner stop
```
---

## Install GitLab Runner
```bash
sudo apt-get update
sudo apt-get install -y curl

curl -L --output /usr/local/bin/gitlab-runner \
https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

sudo chmod +x /usr/local/bin/gitlab-runner

sudo useradd \
  --comment 'GitLab Runner' \
  --create-home gitlab-runner \
  --shell /bin/bash

sudo gitlab-runner install \
  --user=gitlab-runner \
  --working-directory=/home/gitlab-runner

sudo gitlab-runner start
```
---

## Check GitLab Runner Version
```bash
gitlab-runner --version
```
---

## Remove GitLab Runner

Stop the service:
```bash
sudo gitlab-runner stop

Remove all runners:

sudo gitlab-runner unregister --all-runners

OR remove a specific runner:

sudo gitlab-runner unregister --name <RUNNER_NAME>

Remove the package:

sudo apt-get remove gitlab-runner
```
---

## Optional Cleanup (Use With Caution)

These commands permanently delete runner configuration and data.
```bash
sudo rm -rf /etc/gitlab-runner
sudo rm -rf /home/gitlab-runner
sudo rm -rf /usr/local/bin/gitlab-runner
```
---

## Summary

This runbook covers:

- Installing GitLab Runner
- Registering runners
- Managing runner services
- Verifying runners
- Troubleshooting runners
- Removing runners safely