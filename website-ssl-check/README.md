# Website SSL Check

Simple Bash script to check **website availability** and **SSL certificate details** for multiple domains.

## Features

- Checks HTTP/HTTPS accessibility
- Retrieves SSL certificate expiry date
- Extracts SSL issuer
- Parallel execution for faster checks
- Generates timestamped log output

## Requirements

- bash
- curl
- openssl
- awk
- sed
- cut

## Usage

1. Add domains to:

check_ssl_websites.txt

Example:
```
google.com
github.com
example.com
```
2. Run the script
```bash
chmod +x website_ssl_checker.sh
./website_ssl_checker.sh
```
## Output

Example result:

github.com | Accessible | HTTP Status: 200 | Apr  5 23:59:59 2026 GMT | Sectigo Public Server Authentication CA DV E36

Results are saved to:

website_ssl_check_(timestamp).log