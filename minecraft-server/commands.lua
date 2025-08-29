-- commands.lua
-- Command registry & execution logic
local logger = require("logger")
local CONFIG = require("config")
local api = require("api_client")

local M = {}
local COMMANDS = {}

local function register(cmd, desc, handler)
    COMMANDS[cmd] = { desc = desc, handler = handler }
end

-- Utility: send a message to chat (if chatbox present) and log it
local function chatInfo(ctx, msg)
    logger.info(msg)
    if ctx and ctx.chatbox and type(ctx.chatbox.sendMessage) == "function" then
        -- Use player-style formatting so remote users see command feedback
        local ok, err = ctx.chatbox.sendMessage(msg, CONFIG.playerPrefix, CONFIG.brackets, CONFIG.bracketColorPlayer, CONFIG.chatRange)
        if not ok then logger.warn("Chat send failed: " .. tostring(err)) end
    end
end

local function chatWarn(ctx, msg)
    logger.warn(msg)
    if ctx and ctx.chatbox and type(ctx.chatbox.sendMessage) == "function" then
        ctx.chatbox.sendMessage("(warn) " .. msg, CONFIG.playerPrefix, CONFIG.brackets, CONFIG.bracketColorPlayer, CONFIG.chatRange)
    end
end

-- registration (mirrors previous inline definitions)
register("apistatus", "Fetch API status + flush queue", function(_, ctx)
    local data = ctx.getAPIStatus()
    api.flushQueue()
    if data and data.message then
        chatInfo(ctx, "API: " .. data.message .. " (queue flushed)")
    else
        chatInfo(ctx, "API status requested & queue flushed")
    end
end)

register("setapi", "Set base API URL: !setapi <url>", function(args, ctx)
    local newUrl = args:match("%S+")
    if newUrl then
        api.setBaseUrl(newUrl)
        chatInfo(ctx, "Base URL -> " .. newUrl)
    else
        chatWarn(ctx, "Usage: !setapi <url>")
    end
end)

register("flushapi", "Force flush queued requests", function(_, ctx)
    api.flushQueue()
    chatInfo(ctx, "API queue flush requested")
end)

register("reloadapi", "Reinitialize API module", function(_, ctx)
    api.init({ force = true })
    chatInfo(ctx, "API re-init requested (force flag)")
end)

register("help", "List available commands", function(_, ctx)
    -- Build concise list for single chat line (avoid spamming too many messages)
    local list = {}
    for k, _ in pairs(COMMANDS) do table.insert(list, k) end
    table.sort(list)
    chatInfo(ctx, "Commands: " .. CONFIG.commandPrefix .. table.concat(list, ", " .. CONFIG.commandPrefix))
    -- Also print detailed list to the local console
    logger.info("Available commands:")
    for k, v in pairs(COMMANDS) do
        print(string.format("  %s%s - %s", CONFIG.commandPrefix, k, v.desc))
    end
end)

function M.isCommand(message)
    return message and message:sub(1, #CONFIG.commandPrefix) == CONFIG.commandPrefix
end

function M.execute(message, ctx)
    local base = message:sub(#CONFIG.commandPrefix + 1)
    local cmd, rest = base:match("^(%S+)%s*(.-)$")
    if not cmd or cmd == '' then return false end
    local entry = COMMANDS[cmd]
    if not entry then
        logger.warn("Unknown command: " .. cmd)
        return false
    end
    local ok, err = pcall(entry.handler, rest or '', ctx)
    if not ok then logger.error("Command error: " .. tostring(err)) end
    return true
end

return M
