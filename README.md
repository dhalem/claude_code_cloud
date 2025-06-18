# CCC One - Claude Container & Communication

A containerized automation framework that combines Claude AI CLI capabilities with Discord integration for automated workflows and notifications.

## 🎯 Overview

This project provides a ready-to-use Docker setup for running Claude AI automation tasks in containers with Discord integration for notifications and bot commands. It's designed to be a foundation for building automated workflows that leverage Claude's capabilities while maintaining communication through Discord.

### Key Features

- **🤖 Claude AI Automation**: Run Claude CLI commands in a containerized environment with persistent authentication
- **💬 Discord Integration**: Full-featured Discord bot + simple webhook notifications
- **🔒 Secure Authentication**: Web-based Claude authentication (no API keys in code)
- **📦 Fully Containerized**: Everything runs in Docker with proper isolation
- **🔄 Continuous Operation**: Automated loop processing with configurable intervals
- **📝 Extensive Logging**: Persistent logs for debugging and monitoring

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- GitHub personal access token (for Git operations)
- Discord bot token and/or webhook URL
- Claude account for web authentication

### 1. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/yourusername/ccc_one.git
cd ccc_one

# Set up environment variables
cp .env.example .env
# Edit .env with your tokens and configuration
```

### 2. Authenticate Claude (One-Time Setup)

```bash
# This opens a browser for Claude web authentication
docker compose run --rm claude-automation /app/scripts/setup-auth.sh
```

### 3. Start Services

```bash
# Start all services in background
docker compose up -d

# Or start specific services
docker compose up -d claude-automation
docker compose up -d discord-bot
```

### 4. Monitor Services

```bash
# View logs
docker compose logs -f claude-automation
docker compose logs -f discord-bot

# Check service status
docker compose ps
```

## 📋 Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Claude Automation
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GIT_REPO_URL=https://github.com/yourusername/your-repo.git
GIT_BRANCH=main  # Optional, defaults to main
GIT_USER_NAME="Claude Automation"
GIT_USER_EMAIL="claude@automation.local"
AUTOMATION_INTERVAL=60  # Seconds between runs

# Claude prompt - what Claude should do each iteration
CLAUDE_PROMPT="git pull && examine README.md and suggest improvements"

# Discord Bot
DISCORD_BOT_TOKEN=your_bot_token_here
DISCORD_CHANNEL_ID=channel_id_to_monitor  # Optional
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...  # Optional
```

### Customizing Claude Automation

The easiest way to customize Claude's behavior is through the `CLAUDE_PROMPT` environment variable:

```bash
# Example prompts:

# Task queue processing
CLAUDE_PROMPT="git pull && read tasks.md and process the next unclaimed task"

# Code review automation
CLAUDE_PROMPT="check for new pull requests and provide code review feedback"

# Documentation updates
CLAUDE_PROMPT="analyze recent commits and update the CHANGELOG.md file"

# Test monitoring
CLAUDE_PROMPT="run npm test and if any tests fail, create an issue with details"

# Security scanning
CLAUDE_PROMPT="run security audit and report any vulnerabilities found"
```

For more complex automation logic, you can also edit `/docker/claude/scripts/claude-entrypoint.sh` directly.

## 🤖 Discord Bot Commands

The included Discord bot supports these slash commands:

- `/ping` - Check if bot is responsive
- `/status` - Show bot status and uptime
- `/send <message>` - Send a message via webhook
- `/help` - Display available commands

### Adding Custom Commands

Edit `/docker/discord-bot/discord-bot.js` to add new functionality:

```javascript
// Add to commands array
new SlashCommandBuilder()
    .setName('deploy')
    .setDescription('Trigger deployment'),

// Add handler
case 'deploy':
    // Trigger your deployment logic
    await interaction.reply('🚀 Deployment triggered!');
    break;
```

## 🔧 Advanced Usage

### Using the Webhook Script

For simple notifications without running the full bot:

```bash
# Send a notification
./scripts/discord-webhook.sh "Build completed successfully!"

# With custom username
./scripts/discord-webhook.sh "Deployment failed" "Deploy Bot"
```

### Mounting Project Directories

To give Claude access to your project files:

```yaml
# In docker-compose.yml
claude-automation:
  volumes:
    - ./my-project:/app/workspace/my-project
```

### Running One-Off Commands

```bash
# Execute a single Claude command
docker compose run --rm claude-automation bash -c \
  'HOME=/app/claude-config node /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js -p "your command here"'
```

## 📁 Project Structure

```
ccc_one/
├── docker-compose.yml       # Main orchestration file
├── .env.example            # Environment template
├── README.md               # This file
├── README-DOCKER.md        # Detailed Docker documentation
├── docker/
│   ├── claude/            # Claude container files
│   │   ├── Dockerfile
│   │   └── scripts/
│   │       ├── claude-entrypoint.sh
│   │       └── setup-auth.sh
│   └── discord-bot/       # Discord bot files
│       ├── Dockerfile
│       ├── discord-bot.js
│       └── package.json
└── scripts/
    └── discord-webhook.sh  # Standalone webhook script
```

## 🚨 Troubleshooting

### Claude Authentication Issues

```bash
# Check if authenticated
docker compose exec claude-automation ls -la /app/claude-config/.claude/

# Re-authenticate
docker volume rm claude-auth-data
docker compose run --rm claude-automation /app/scripts/setup-auth.sh
```

### Discord Bot Not Connecting

```bash
# Check bot logs
docker compose logs discord-bot

# Verify token is set
docker compose exec discord-bot env | grep DISCORD
```

### Alpine Linux Compatibility

The Claude container uses Alpine Linux. Always use the full node path:
```bash
node /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js
```

## 🔐 Security Best Practices

1. **Never commit `.env` files** with real tokens
2. **Use Docker secrets** for production deployments
3. **Rotate tokens regularly**
4. **Limit permissions** to minimum required
5. **Monitor logs** for suspicious activity

## 📚 Use Cases

This framework is ideal for:

- **Automated Code Reviews**: Have Claude review PRs and post feedback to Discord
- **Documentation Updates**: Automatically update docs based on code changes
- **Task Queue Processing**: Process tasks from a queue with Discord notifications
- **Monitoring & Alerts**: Run checks and send alerts to Discord
- **Development Workflows**: Automate repetitive development tasks

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🔗 Resources

- [Claude CLI Documentation](https://docs.anthropic.com/claude/docs/claude-cli)
- [Discord.js Guide](https://discordjs.guide/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [GitHub Actions](https://docs.github.com/en/actions) (for CI/CD integration)

## 💡 Tips

- Start with simple automation tasks and gradually increase complexity
- Use the Discord webhook for quick notifications during development
- Monitor Claude usage to avoid rate limits
- Keep your automation logic modular and testable
- Document your custom automation workflows

---

Built with ❤️ for automation enthusiasts