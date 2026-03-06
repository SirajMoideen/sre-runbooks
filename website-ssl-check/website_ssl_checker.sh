#!/bin/bash

# === Configuration ===
URL_LIST_FILE="check_ssl_websites.txt"
TIMESTAMP=$(date +"%d.%m.%Y_%H.%M.%S")
OUTPUT_FILE="website_ssl_check_${TIMESTAMP}.log"
MAX_PARALLEL=20

echo "Script is running... Please wait..."

# === Limit parallel jobs ===
limit_jobs() {
    while true; do
        running=$(jobs -rp | wc -l)
        if (( running < MAX_PARALLEL )); then
            break
        fi
        sleep 0.2
    done
}

# === Function to check website and write to terminal and temp file ===
check_website() {
    LINE_NUM="$1"
    INPUT="$2"
    TMP_FILE="/tmp/sslout_line_${LINE_NUM}.tmp"

    # Clean domain (remove protocol if present)
    CLEANED_URL=$(echo "$INPUT" | sed -E 's~^[[:alpha:]]+://~~')
    DOMAIN=$(echo "$CLEANED_URL" | cut -d/ -f1)
    FULL_URL="http://$DOMAIN"

    # 1. Accessibility check
    HTTP_STATUS=$(curl -L -k -s -o /dev/null -w "%{http_code}" "$FULL_URL")
    if [[ "$HTTP_STATUS" -ge 200 && "$HTTP_STATUS" -lt 300 ]]; then
        ACCESS_RESULT="$DOMAIN | Accessible | HTTP Status: $HTTP_STATUS"
    else
        ACCESS_RESULT="$DOMAIN | Not accessible | HTTP Status: $HTTP_STATUS"
    fi

    # 2. SSL check
    CERT=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" -showcerts 2>/dev/null | \
        awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/')

    if [[ -n "$CERT" ]]; then
        EXPIRY_DATE=$(echo "$CERT" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
        ISSUER_CN=$(echo "$CERT" | openssl x509 -noout -issuer 2>/dev/null | sed -n 's/.*CN=\(.*\)/\1/p')

        if [[ -z "$EXPIRY_DATE" ]]; then
            SSL_RESULT="Error parsing SSL certificate"
        else
            SSL_RESULT="$EXPIRY_DATE | $ISSUER_CN"
        fi
    else
        SSL_RESULT="SSL certificate could not be retrieved"
    fi

    FINAL_OUTPUT="$ACCESS_RESULT | $SSL_RESULT"

    # Print to terminal immediately
    echo "$FINAL_OUTPUT"

    # Save to temp file for ordered output
    echo "$FINAL_OUTPUT" > "$TMP_FILE"
}

# === Read valid lines into array ===
declare -a LINE_INPUTS=()
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    [[ -z "$LINE" || "${LINE:0:1}" == "#" ]] && continue
    LINE_INPUTS+=("$LINE")
done < "$URL_LIST_FILE"

TOTAL_LINES=${#LINE_INPUTS[@]}

# === Process lines in background ===
for (( i=0; i<TOTAL_LINES; i++ )); do
    limit_jobs
    check_website "$i" "${LINE_INPUTS[$i]}" &
done

wait

# === Write ordered output to file ===
> "$OUTPUT_FILE"
for (( i=0; i<TOTAL_LINES; i++ )); do
    TMP_FILE="/tmp/sslout_line_${i}.tmp"
    if [[ -f "$TMP_FILE" ]]; then
        cat "$TMP_FILE" >> "$OUTPUT_FILE"
        rm -f "$TMP_FILE"
    else
        echo "Line $i failed or timed out" >> "$OUTPUT_FILE"
    fi
done