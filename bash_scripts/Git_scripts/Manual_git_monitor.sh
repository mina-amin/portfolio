#!/bin/bash

# === Configuration ===
directory="/path/to/your/repo/directory"
WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
app_name="Caritas Test Environment"
MAX_MESSAGE_LENGTH=2000  # Discord's absolute limit
SAFE_LOG_LENGTH=1800     # Leave room for formatting

# === Check if jq is installed ===
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Install it with 'sudo apt install jq'"
    exit 1
fi

# === Validate Directory ===
if [ ! -d "$directory" ]; then
  echo "Error: Directory '$directory' does not exist."
  exit 1
fi

cd "$directory" || exit 1

# === Ensure git is available ===
if ! command -v git &> /dev/null; then
  echo "Error: git is not installed."
  exit 1
fi

# === Perform git pull and capture output ===
pull_output=$(git pull 2>&1)
exit_code=$?

# === Capture merge log (git pull already done by you) ===
merge_output=$(git log -1 --pretty=format:"%h - %an: %s" 2>&1)
exit_code=$?

# === If Already Up To Date, Exit Without Sending ===
if [[ "$pull_output" == *"Already up to date."* ]]; then
  echo "✔️ Already up to date. No message sent."
  exit 0
fi

# === Truncate Log if Too Long ===
if [ ${#pull_output} -gt $SAFE_LOG_LENGTH ]; then
  pull_output="${pull_output:0:$SAFE_LOG_LENGTH}\n... [truncated]"
fi

# === Capture merge log (git pull already done by you) ===
merge_output=$(git log -1 --pretty=format:"%h - %an: %s" 2>&1)
exit_code=$?

# === Determine Status Message ===
if [ $exit_code -eq 0 ]; then
  status="✅ Repo Updated Successful"
else
  status="❌ Repo Failed"
fi

# === Build JSON Payload Safely with jq ===
payload=$(jq -n \
  --arg content "$status - $app_name - $(date '+%Y-%m-%d %H:%M:%S')" \
  --arg log "$merge_output" \
  '{content: "\($content)\n```\n\($log)\n```"}')

# === Send to Discord ===
curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$WEBHOOK_URL"

echo "Message sent to Discord."