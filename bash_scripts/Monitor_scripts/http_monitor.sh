#!/bin/bash

# === Configuration ===
URL="Website url"
WEBHOOK_URL="Webhook URL"
PROJECT_NAME="Project Name"

# === Mode selection ===
# always: Always send a message to Discord (even if the status code is 200)
# error_only: Only send a message to Discord if the status code is not 200
MODE="always"   #  Options: always / error_only

# === Get current date and time ===
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# === Get HTTP status code using wget ===
status_code=$(wget --server-response --spider --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36" "$URL" 2>&1 | awk '/HTTP\// {print $2}' | tail -n1)

# === Validate status code ===
if [ -z "$status_code" ]; then
  status_code="N/A"
fi

# === Build message depending on mode and status ===
if [ "$status_code" != "200" ]; then
  message="🚨 $PROJECT_NAME ALERT!
🔗 URL: $URL
⚙️ HTTP Status: $status_code ❌
🕒 Time: $timestamp"
elif [ "$MODE" = "always" ]; then
  message="✅ Status of $PROJECT_NAME is up and running!
🔗 URL: $URL
⚙️ HTTP Status: $status_code
🕒 Time: $timestamp"
else
  message=""  # Do not send a message
fi

# === Send to Discord only if message not empty ===
if [ -n "$message" ]; then
  payload=$(jq -n --arg content "$message" '{content: $content}')
  curl -s -H "Content-Type: application/json" -X POST -d "$payload" "$WEBHOOK_URL"
  echo "📡 Message sent for status ($status_code) at $timestamp."
else
  echo "✅ $URL is OK ($status_code) — no alert sent."
fi
