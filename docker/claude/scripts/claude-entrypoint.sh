#!/bin/bash
# Claude automation entrypoint script
set -e

echo "=== Claude Automation Container Started ==="

# Load environment variables if .env exists
if [ -f /app/.env ]; then
    source /app/.env
fi

# Configure Git
git config --global user.name "${GIT_USER_NAME:-Claude Automation}"
git config --global user.email "${GIT_USER_EMAIL:-claude@automation.local}"
git config --global --add safe.directory /app/workspace/*

# Configure GitHub CLI if token is provided
if [ -n "$GITHUB_TOKEN" ]; then
    export GH_TOKEN="$GITHUB_TOKEN"
    echo "GitHub CLI configured via environment"
fi

# Set Claude environment variables
export CLAUDE_CONFIG_DIR="/app/claude-config"
export HOME="$CLAUDE_CONFIG_DIR"
export NODE_NO_WARNINGS=1
export CI=true
export ANTHROPIC_HEADLESS=true
export NO_BROWSER=true

# Check for existing authentication
if [ -f "$CLAUDE_CONFIG_DIR/.claude/.credentials.json" ]; then
    echo "✅ Claude authentication found"
else
    echo "❌ No Claude authentication found"
    echo ""
    echo "Please run the authentication setup first:"
    echo "  docker compose run --rm claude-automation /app/scripts/setup-auth.sh"
    echo ""
    exit 1
fi

# Ensure workspace directory exists
mkdir -p /app/workspace

# Claude CLI command (Alpine BusyBox compatibility)
CLAUDE_CMD="node /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js"

echo "✅ Environment configured"
echo "Starting automation loop..."

# Main automation loop
iteration=0

# Set default values
GIT_REPO_URL="${GIT_REPO_URL}"
GIT_BRANCH="${GIT_BRANCH:-main}"
CLAUDE_PROMPT="${CLAUDE_PROMPT:-echo 'No prompt configured. Set CLAUDE_PROMPT environment variable.'}"
REPO_DIR="/app/workspace/repo"

while true; do
    iteration=$((iteration + 1))
    echo ""
    echo "=== Iteration $iteration started at $(date) ==="
    
    # Clone or update repository if GIT_REPO_URL is set
    if [ -n "$GIT_REPO_URL" ]; then
        if [ -d "$REPO_DIR" ]; then
            echo "Updating repository..."
            cd "$REPO_DIR"
            git fetch origin
            git reset --hard origin/$GIT_BRANCH
            git clean -fd
        else
            echo "Cloning repository from $GIT_REPO_URL..."
            cd /app/workspace
            # Use token in URL if it's a GitHub repo and token is available
            if [[ "$GIT_REPO_URL" == *"github.com"* ]] && [ -n "$GITHUB_TOKEN" ]; then
                AUTHENTICATED_URL=$(echo "$GIT_REPO_URL" | sed "s|https://|https://${GITHUB_TOKEN}@|")
                git clone -b "$GIT_BRANCH" "$AUTHENTICATED_URL" repo
            else
                git clone -b "$GIT_BRANCH" "$GIT_REPO_URL" repo
            fi
            cd "$REPO_DIR"
        fi
        echo "Repository ready at: $(pwd)"
    else
        echo "No GIT_REPO_URL configured, working in /app/workspace"
        cd /app/workspace
    fi
    
    # Execute Claude automation with the configured prompt
    echo "Executing Claude with prompt: $CLAUDE_PROMPT"
    
    # Create log file for this iteration
    LOG_FILE="/app/logs/claude-$(date +%Y%m%d-%H%M%S)-iteration-$iteration.log"
    mkdir -p /app/logs
    
    # Run Claude with the configured prompt
    HOME="$CLAUDE_CONFIG_DIR" $CLAUDE_CMD -p --dangerously-skip-permissions "$CLAUDE_PROMPT" 2>&1 | tee "$LOG_FILE"
    
    CLAUDE_EXIT_CODE=${PIPESTATUS[0]}
    echo "Claude command completed with exit code: $CLAUDE_EXIT_CODE"
    
    # Clean up old logs (keep last 50)
    find /app/logs -name "claude-*.log" -type f | sort -r | tail -n +51 | xargs -r rm -f
    
    if [ $CLAUDE_EXIT_CODE -eq 0 ]; then
        echo "✅ Iteration $iteration completed successfully"
    else
        echo "❌ Iteration $iteration failed with exit code $CLAUDE_EXIT_CODE"
    fi
    
    # Wait between iterations
    echo "Waiting ${AUTOMATION_INTERVAL:-60} seconds before next iteration..."
    sleep ${AUTOMATION_INTERVAL:-60}
done