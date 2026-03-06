import subprocess
import collections
import csv

PROJECT_FILE = "projects.txt"
OUTPUT_CSV = "sa_roles_get.csv"

# Storage: { service_account: { project_id: [roles] } }
sa_mapping = collections.defaultdict(lambda: collections.defaultdict(list))

def get_iam_policy(project_id):
    print(f"Reading: {project_id}...")
    try:
        cmd = [
            "gcloud", "projects", "get-iam-policy", project_id,
            "--flatten=bindings[].members",
            "--filter=bindings.members ~ serviceAccount",
            "--format=value(bindings.members, bindings.role)"
        ]
        result = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL)
        
        for line in result.strip().split('\n'):
            if line:
                parts = line.split('\t')
                if len(parts) == 2:
                    full_sa, role = parts
                    
                    # Remove 'serviceAccount:' prefix
                    clean_sa = full_sa.replace("serviceAccount:", "")
                    
                    # Clean the role name (removes 'roles/' or 'projects/.../roles/')
                    short_role = role.split('/')[-1]
                    
                    sa_mapping[clean_sa][project_id].append(short_role)
    except Exception as e:
        print(f"  Skipping {project_id}: {e}")

# 1. Load project IDs
try:
    with open(PROJECT_FILE, 'r') as f:
        projects = [line.strip() for line in f if line.strip()]
except FileNotFoundError:
    print(f"Error: {PROJECT_FILE} not found.")
    exit()

# 2. Collect Data
for proj in projects:
    get_iam_policy(proj)

# 3. Write to CSV with Vertical Formatting
with open(OUTPUT_CSV, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(["Service Account", "Roles"])

    for sa in sorted(sa_mapping.keys()):
        role_entries = []
        for proj_id, roles in sa_mapping[sa].items():
            # Header for project
            entry = f"{proj_id}:"
            # Each role on a new line
            for r in sorted(roles):
                entry += f"\n{r}"
            role_entries.append(entry)
        
        # Separate different projects with a newline
        roles_text = "\n\n".join(role_entries)
        writer.writerow([sa, roles_text])

print(f"\nDone! Saved to: {OUTPUT_CSV}")