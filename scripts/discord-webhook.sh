#!/bin/bash
# Simple Discord webhook notification script

# Usage: ./discord-webhook.sh "Your message here"
# Or with username: ./discord-webhook.sh "Your message" "Bot Name"

WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"
MESSAGE="$1"
USERNAME="${2:-Automation Bot}"

if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: DISCORD_WEBHOOK_URL environment variable not set"
    exit 1
fi

if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 \"Your message\" [username]"
    exit 1
fi

# Send webhook
response=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$USERNAME\", \"content\": \"$MESSAGE\"}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "204" ]; then
    echo "✅ Discord notification sent successfully"
else
    echo "❌ Failed to send Discord notification (HTTP $http_code)"
    echo "Response: $body"
    exit 1
fi