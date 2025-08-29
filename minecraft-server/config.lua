-- config.lua
-- Central configuration for the chat monitor / AI relay
local CONFIG = {
    commandPrefix = "!",         -- Prefix for local commands
    aiPrefix = "AI",              -- Display username for AI replies
    playerPrefix = "ChatBot",     -- Prefix shown by chatbox for player echoes
    brackets = "[]",              -- Brackets style for player echoes
    bracketsAI = "<>",            -- Brackets style for AI messages
    bracketColorPlayer = "&3",    -- Color code for brackets (player)
    bracketColorAI = "&d",        -- Color code for brackets (AI)
    chatRange = 100,              -- Chatbox broadcast range
    statusFetchOnStart = true,    -- Pull status once at startup
    flushIntervalSeconds = 30,    -- Attempt queue flush every N seconds
    flushJitter = 5,              -- +/- jitter seconds added to flush scheduling
    enableAI = true               -- Toggle AI forwarding
}

return CONFIG
