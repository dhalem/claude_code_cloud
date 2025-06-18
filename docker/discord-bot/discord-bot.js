#!/usr/bin/env node
// Generalized Discord Bot

const { Client, GatewayIntentBits, SlashCommandBuilder, EmbedBuilder } = require('discord.js');
const axios = require('axios');
require('dotenv').config();

// Validate environment variables
const BOT_TOKEN = process.env.DISCORD_BOT_TOKEN;
const CHANNEL_ID = process.env.DISCORD_CHANNEL_ID;
const WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL;

if (!BOT_TOKEN) {
    console.error('❌ Missing DISCORD_BOT_TOKEN environment variable!');
    process.exit(1);
}

// Create Discord client
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers
    ]
});

// Bot ready event
client.once('ready', () => {
    console.log(`✅ Bot logged in as ${client.user.tag}`);
    if (CHANNEL_ID) {
        console.log(`📍 Monitoring channel ID: ${CHANNEL_ID}`);
    }
    
    // Set bot status
    client.user.setActivity('the automation', { type: 'WATCHING' });
    
    // Register slash commands
    registerCommands();
});

// Register slash commands
async function registerCommands() {
    const commands = [
        new SlashCommandBuilder()
            .setName('ping')
            .setDescription('Check if bot is responsive'),
        
        new SlashCommandBuilder()
            .setName('status')
            .setDescription('Show bot status'),
        
        new SlashCommandBuilder()
            .setName('send')
            .setDescription('Send a webhook message')
            .addStringOption(option =>
                option.setName('message')
                    .setDescription('Message to send')
                    .setRequired(true)
            ),
        
        new SlashCommandBuilder()
            .setName('help')
            .setDescription('Show available commands')
    ];
    
    try {
        await client.application.commands.set(commands);
        console.log('✅ Slash commands registered');
    } catch (error) {
        console.error('❌ Error registering commands:', error);
    }
}

// Handle slash commands
client.on('interactionCreate', async interaction => {
    if (!interaction.isCommand()) return;
    
    const { commandName } = interaction;
    
    try {
        switch (commandName) {
            case 'ping':
                await interaction.reply('🏓 Pong! Bot is responsive.');
                break;
                
            case 'status':
                await handleStatus(interaction);
                break;
                
            case 'send':
                await handleSend(interaction);
                break;
                
            case 'help':
                await handleHelp(interaction);
                break;
        }
    } catch (error) {
        console.error('Error handling command:', error);
        await interaction.reply({ 
            content: '❌ An error occurred while processing your command.', 
            ephemeral: true 
        });
    }
});

// Command handlers
async function handleStatus(interaction) {
    const uptime = process.uptime();
    const hours = Math.floor(uptime / 3600);
    const minutes = Math.floor((uptime % 3600) / 60);
    
    const embed = new EmbedBuilder()
        .setTitle('🤖 Bot Status')
        .addFields(
            { name: 'Status', value: '✅ Online', inline: true },
            { name: 'Uptime', value: `${hours}h ${minutes}m`, inline: true },
            { name: 'Latency', value: `${client.ws.ping}ms`, inline: true }
        )
        .setColor(0x5865F2)
        .setTimestamp();
    
    await interaction.reply({ embeds: [embed] });
}

async function handleSend(interaction) {
    const message = interaction.options.getString('message');
    
    if (!WEBHOOK_URL) {
        return interaction.reply({ 
            content: '❌ Webhook URL not configured.', 
            ephemeral: true 
        });
    }
    
    try {
        await axios.post(WEBHOOK_URL, {
            content: message,
            username: interaction.user.username
        });
        
        await interaction.reply({ 
            content: '✅ Message sent via webhook!', 
            ephemeral: true 
        });
    } catch (error) {
        console.error('Error sending webhook:', error);
        await interaction.reply({ 
            content: '❌ Failed to send webhook message.', 
            ephemeral: true 
        });
    }
}

async function handleHelp(interaction) {
    const embed = new EmbedBuilder()
        .setTitle('🤖 Bot Commands')
        .setDescription('Available commands:')
        .addFields(
            { name: '/ping', value: 'Check if bot is responsive' },
            { name: '/status', value: 'Show bot status and uptime' },
            { name: '/send <message>', value: 'Send a message via webhook' },
            { name: '/help', value: 'Show this help message' }
        )
        .setColor(0x5865F2)
        .setTimestamp();
    
    await interaction.reply({ embeds: [embed], ephemeral: true });
}

// Optional: Monitor specific channel for messages
if (CHANNEL_ID) {
    client.on('messageCreate', async message => {
        // Skip bot messages
        if (message.author.bot) return;
        
        // Only process messages from the monitored channel
        if (message.channel.id !== CHANNEL_ID) return;
        
        // Add your message processing logic here
        console.log(`📨 New message in monitored channel: ${message.content}`);
    });
}

// Error handling
client.on('error', error => {
    console.error('Discord client error:', error);
});

process.on('unhandledRejection', error => {
    console.error('Unhandled promise rejection:', error);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down gracefully...');
    client.destroy();
    process.exit(0);
});

// Log in to Discord
client.login(BOT_TOKEN).catch(error => {
    console.error('❌ Failed to login:', error);
    process.exit(1);
});