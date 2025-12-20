#!/bin/bash

<<<<<<< HEAD
WEBHOOK_URL="https://discord.com/api/webhooks/1312700344979034173/c8W8To8hpn-dCB9DfYM9ASLQIb0ol9XNE7uj5cNbVtEcNdtLrBM6jnjPEINW1OIRQgm1"
=======
WEBHOOK_URL="webhook_url"
>>>>>>> 2c7e4a9 (Adding assignment history)
HOSTNAME=$(hostname)
DATE=$(date)
ALERT_DAYS=10  # Number of days before expiration to send an alert

# Run certbot renew and capture output
OUTPUT=$(sudo certbot renew 2>&1)
STATUS=$?

# Escape output for JSON safely
ESCAPED_OUTPUT=$(echo "$OUTPUT" | tail -n 25 | sed 's/\\/\\\\/g; s/"/\\"/g; s/\r//g' | awk '{printf "%s\\n", $0}')

# Default values
TITLE=""
COLOR=0

# Determine message type
if [ $STATUS -eq 0 ]; then
    TITLE="✅ SSL Status is Valid"
    COLOR=3066993  # Green
else
    TITLE="❌ SSL Status is not Valid"
    COLOR=15158332  # Red
fi

# Check for expiring certificates
EXPIRING_CERTS=""
CERT_LIST=$(sudo certbot certificates 2>/dev/null | grep "Certificate Name:" | awk '{print $3}')

for domain in $CERT_LIST; do
    cert_path="/etc/letsencrypt/live/$domain/cert.pem"
    if [ -f "$cert_path" ]; then
        expiry_date=$(sudo openssl x509 -enddate -noout -in "$cert_path" 2>/dev/null | cut -d= -f2)
        if [ -n "$expiry_date" ]; then
            expiry_epoch=$(date -d "$expiry_date" +%s)
            now_epoch=$(date +%s)
            diff_days=$(( (expiry_epoch - now_epoch) / 86400 ))
            if [ $diff_days -le $ALERT_DAYS ]; then
                EXPIRING_CERTS+="$domain (expires in $diff_days days)\\n"
            fi
        fi
    fi
done

# Override title if certificates are expiring soon
if [ -n "$EXPIRING_CERTS" ]; then
    TITLE="⚠️ Certificate(s) Expiring Soon"
    COLOR=16776960  # Yellow
    ESCAPED_OUTPUT="$EXPIRING_CERTS"
fi

# Send result to Discord
curl -s -H "Content-Type: application/json" \
     -X POST \
     -d "{
  \"embeds\": [{
    \"title\": \"$TITLE\",
    \"color\": $COLOR,
    \"fields\": [
      {\"name\": \"Server\", \"value\": \"$HOSTNAME\", \"inline\": true},
      {\"name\": \"Date\", \"value\": \"$DATE\", \"inline\": true},
      {\"name\": \"Output\", \"value\": \"\`\`\`$ESCAPED_OUTPUT\`\`\`\"}
    ]
  }]
<<<<<<< HEAD
}" "$WEBHOOK_URL"
=======
}" "$WEBHOOK_URL"
>>>>>>> 2c7e4a9 (Adding assignment history)
