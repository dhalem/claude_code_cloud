# Docker Setup for Claude Automation & Discord Bot

This repository contains Docker configurations for running Claude CLI automation and a Discord bot in containers.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- GitHub token (for Claude automation)
- Discord bot token (for Discord bot)

### Setup Steps

1. **Clone and configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your tokens
   ```

2. **Authenticate Claude (one-time setup)**:
   ```bash
   # This will open a browser for authentication
   docker compose run --rm claude-automation /app/scripts/setup-auth.sh
   ```

3. **Start services**:
   ```bash
   docker compose up -d
   ```

## 📦 Components

### Claude Automation Container
- **Purpose**: Runs Claude CLI commands in a continuous loop
- **Base Image**: `node:20-alpine`
- **Key Features**:
  - Persistent web authentication (no API keys needed)
  - GitHub CLI integration
  - Configurable automation intervals
  - Log persistence

### Discord Bot Container
- **Purpose**: Discord bot for notifications and commands
- **Base Image**: `node:20-alpine`
- **Features**:
  - Slash commands support
  - Webhook integration
  - Channel monitoring (optional)
  - Graceful error handling

## 🔧 Configuration

### Environment Variables

**Claude Automation**:
- `GITHUB_TOKEN`: Your GitHub personal access token
- `GIT_REPO_URL`: Git repository URL to work with
- `GIT_BRANCH`: Git branch to use (default: main)
- `GIT_USER_NAME`: Git commit author name
- `GIT_USER_EMAIL`: Git commit author email
- `CLAUDE_PROMPT`: The prompt/command for Claude to execute each iteration
- `AUTOMATION_INTERVAL`: Seconds between automation runs (default: 60)

**Discord Bot**:
- `DISCORD_BOT_TOKEN`: Your Discord bot token (required)
- `DISCORD_CHANNEL_ID`: Channel to monitor (optional)
- `DISCORD_WEBHOOK_URL`: Webhook for sending messages (optional)

### Volumes

- `claude-auth-data`: Persistent Claude authentication
- `claude-logs`: Automation logs
- `redis-data`: Redis cache (optional)

## 📝 Important Notes

### Claude Container Specifics
1. **Alpine Linux Compatibility**: The container uses Alpine Linux with BusyBox. Always use the full node path for Claude CLI:
   ```bash
   node /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js
   ```

2. **Authentication**: 
   - Web authentication is required (no API key support)
   - Authentication persists in Docker volume
   - Must authenticate interactively first time

3. **HOME Environment**: Claude requires `HOME=/app/claude-config` for authentication to work

### Discord Bot Commands
- `/ping` - Check bot responsiveness
- `/status` - Show bot status and uptime
- `/send <message>` - Send webhook message
- `/help` - Show available commands

## 🛠️ Customization

### Modifying Claude Automation

The simplest way is to set the `CLAUDE_PROMPT` environment variable in your `.env` file:

```bash
# Examples:
CLAUDE_PROMPT="git pull && review new pull requests"
CLAUDE_PROMPT="check for failing tests and create issues"
CLAUDE_PROMPT="update documentation based on recent commits"
```

For more complex logic, you can edit `/docker/claude/scripts/claude-entrypoint.sh` directly.

### Extending Discord Bot
Add new commands in `/docker/discord-bot/discord-bot.js`:

```javascript
// Add new slash command
new SlashCommandBuilder()
    .setName('custom')
    .setDescription('Your custom command'),

// Add handler
case 'custom':
    await handleCustom(interaction);
    break;
```

## 🚨 Troubleshooting

### Claude Authentication Issues
```bash
# Check if authentication exists
docker compose exec claude-automation ls -la /app/claude-config/.claude/

# Re-authenticate
docker volume rm claude-auth-data
docker compose run --rm claude-automation /app/scripts/setup-auth.sh
```

### Discord Bot Not Connecting
```bash
# Check logs
docker compose logs discord-bot

# Verify token
echo $DISCORD_BOT_TOKEN
```

### View Logs
```bash
# Claude automation logs
docker compose logs -f claude-automation

# Discord bot logs
docker compose logs -f discord-bot
```

## 📚 Additional Resources

- [Claude CLI Documentation](https://docs.anthropic.com/claude/docs/claude-cli)
- [Discord.js Documentation](https://discord.js.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🔒 Security Notes

- Never commit `.env` file with real tokens
- Use Docker secrets for production deployments
- Regularly rotate your tokens
- Keep containers updated