# Docker container for Discord bot
FROM node:20-alpine

# Set environment variables
ENV NODE_ENV=production

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    && rm -rf /var/cache/apk/*

# Create app directory
RUN mkdir -p /app && chown -R node:node /app

# Switch to node user
USER node

# Set working directory
WORKDIR /app

# Copy package files
COPY --chown=node:node package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY --chown=node:node . .

# Expose health check port (optional)
EXPOSE 3000

# Start the bot
CMD ["node", "discord-bot.js"]