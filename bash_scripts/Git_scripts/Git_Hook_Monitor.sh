#!/bin/bash

# === Configuration ===
directory="/path/to/your/repo/directory"
WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
SAFE_LOG_LENGTH=1800
APP_NAME="NAME OF YOUR APP"

# Go to repo directory
cd "$directory" || exit 1

# === Capture merge log (git pull already done by you) ===
merge_output=$(git log -1 --pretty=format:"%h - %an: %s" 2>&1)
exit_code=$?

# === Truncate if needed ===
if [ ${#merge_output} -gt $SAFE_LOG_LENGTH ]; then
  merge_output="${merge_output:0:$SAFE_LOG_LENGTH}
  ... [truncated]"
fi

# === Determine Status ===
if [ $exit_code -eq 0 ]; then
    status="🔄 Repo Merged Successfully"
else
    status="❌ Failed To Merge Repo"
fi

# === Build JSON Payload ===
payload=$(jq -n \
  --arg content "$status - $APP_NAME- $(date '+%Y-%m-%d %H:%M:%S')" \
  --arg log "$merge_output" \
  '{content: "\($content)\n```\n\($log)\n```"}')

# === Send to Discord ===
curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$WEBHOOK_URL"

echo "Message sent to Discord."