#!/bin/bash
# Interactive Claude authentication setup script
set -e

echo "=== Claude Authentication Setup ==="
echo ""

# Check if authentication already exists
if [ -f "/app/claude-config/.claude/.credentials.json" ]; then
    echo "✅ Authentication already exists!"
    echo "To re-authenticate, first remove the existing auth:"
    echo "  docker volume rm claude-auth-data"
    exit 0
fi

echo "This script will help you authenticate Claude CLI."
echo "A browser window will open for authentication."
echo ""
echo "Press Enter to continue..."
read -r

# Create directories
mkdir -p /app/claude-config

# Set environment
export HOME=/app/claude-config
export NODE_NO_WARNINGS=1

# Run Claude to trigger authentication
echo "Starting Claude authentication..."
echo "Please complete the authentication in your browser."
echo ""

# Use node directly (Alpine compatibility)
node /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js -c '/exit' || {
    echo "Claude exited - checking for authentication..."
}

# Wait for files to be written
sleep 3

# Verify authentication
if [ -f "/app/claude-config/.claude/.credentials.json" ]; then
    echo ""
    echo "✅ Authentication successful!"
    echo "✅ Credentials saved to persistent volume"
    echo ""
    echo "You can now start the automation container:"
    echo "  docker compose up -d claude-automation"
else
    echo ""
    echo "❌ Authentication failed"
    echo "Please try again"
    exit 1
fi