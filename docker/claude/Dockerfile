# Docker container for Claude automation with persistent authentication
FROM node:20-alpine

# Set environment variables
ENV NODE_ENV=production
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    bash \
    ca-certificates \
    gnupg \
    wget \
    sudo \
    strace \
    && rm -rf /var/cache/apk/*

# Install GitHub CLI
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache github-cli \
    && rm -rf /var/cache/apk/*

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code || \
    npm install -g claude-code || \
    npm install -g @anthropic-ai/claude || \
    (echo "Trying alternative Claude CLI installation..." && \
     npm install -g claude-ai && npm cache clean --force)

# Create app directory structure
RUN mkdir -p /app/workspace /app/claude-config /app/logs /app/scripts && \
    chown -R node:node /app && \
    chmod 755 /app/workspace

# Switch to node user
USER node

# Set working directory
WORKDIR /app

# Copy scripts (will be added later)
COPY --chown=node:node scripts/ /app/scripts/
RUN chmod +x /app/scripts/*.sh

# Set working directory for operations
WORKDIR /app/workspace

# Default command
CMD ["/app/scripts/claude-entrypoint.sh"]