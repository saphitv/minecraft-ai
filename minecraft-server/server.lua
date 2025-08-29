-- Chat Monitor / AI Relay for ComputerCraft with Advanced Peripherals
-- Responsibilities:
--  * Listen to in-game chat events
--  * Mirror to chatbox with formatting
--  * Forward player messages to external AI HTTP endpoint via api_client
--  * Display AI responses
--  * Provide in-chat command interface for diagnostics & config
--
-- Refactored for clearer structure: constants, logging, command dispatch, separation of concerns.

-- Local modules / APIs (ComputerCraft provides peripheral & http globals normally; keep require for environments that support it)
---@diagnostic disable: undefined-global
local peripheral = peripheral or (_G and _G.peripheral) or
    (function()
        local ok, mod = pcall(require, 'peripheral'); if ok then return mod end
    end) --[[@as any]]
local http = http or (_G and _G.http) or
    (function()
        local ok, mod = pcall(require, 'http'); if ok then return mod end
    end) --[[@as any]]
---@diagnostic enable: undefined-global
local api = require("api_client")

api.init() -- Initialize API module (config/queue)

--------------------------------------------------
-- Configuration
--------------------------------------------------
local CONFIG = {
    commandPrefix = "!",         -- Prefix for local commands
    aiPrefix = "AI",              -- Display username for AI replies
    playerPrefix = "ChatBot",     -- Prefix text shown by chatbox for player echoes
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

--------------------------------------------------
-- Logging helpers
--------------------------------------------------
local function log(level, msg)
    print(string.format("[%s] %s", level, msg))
end

local function logInfo(msg) log("INFO", msg) end
local function logWarn(msg) log("WARN", msg) end
local function logError(msg) log("ERROR", msg) end

--------------------------------------------------
-- Peripheral / utilities
--------------------------------------------------

-- Function to find and connect to a chatbox peripheral
local function findChatbox()
    local chatbox = peripheral.find("chat_box") -- Updated identifier (formerly chatBox)
    if not chatbox then
        logWarn("No chatbox peripheral found (Expected 'chat_box').")
        logWarn("Ensure Advanced Peripherals chatbox is connected.")
        return nil
    end
    return chatbox
end

-- Function to format chat messages with advanced features
local function formatMessage(username, message, uuid, isHidden)
    local hiddenIndicator = isHidden and " [HIDDEN]" or ""
    return string.format("[%s%s] %s", username, hiddenIndicator, message)
end

--------------------------------------------------
-- Chatbox sending
--------------------------------------------------
local function sendChatbox(chatbox, text, prefix, brackets, bracketColor, range)
    if not chatbox or type(chatbox.sendMessage) ~= "function" then
        return false, "chatbox unavailable"
    end
    return chatbox.sendMessage(text, prefix, brackets, bracketColor, range)
end

-- Function to get status from Next.js API
local function getAPIStatus()
    local data, err = api.getStatus(true)
    if data then
        if data.message then
            logInfo("API Status: " .. data.message)
        else
            logInfo("API Status received")
        end
    else
        logWarn("Failed to get API status: " .. tostring(err))
    end
    return data
end

--------------------------------------------------
-- Command handlers
--------------------------------------------------
---@type table<string, {desc:string, handler:fun(args:string, ctx:table)}>
local COMMANDS = {}

local function register(cmd, desc, handler)
    COMMANDS[cmd] = { desc = desc, handler = handler }
end

register("apistatus", "Fetch API status + flush queue", function(_, ctx)
    getAPIStatus(); api.flushQueue()
end)

register("setapi", "Set base API URL: !setapi <url>", function(args, ctx)
    local newUrl = args:match("%S+")
    if newUrl then api.setBaseUrl(newUrl); logInfo("Base URL -> " .. newUrl) else logWarn("Usage: !setapi <url>") end
end)

register("flushapi", "Force flush queued requests", function(_, ctx)
    api.flushQueue()
end)

register("reloadapi", "Reinitialize API module", function(_, ctx)
    api.init({ force = true })
    logInfo("API re-init requested (force flag).")
end)

register("help", "List commands", function(_, ctx)
    logInfo("Available commands:")
    for k, v in pairs(COMMANDS) do
        print(string.format("  %s%s - %s", CONFIG.commandPrefix, k, v.desc))
    end
end)

local function isCommand(message)
    return message and message:sub(1, #CONFIG.commandPrefix) == CONFIG.commandPrefix
end

local function executeCommand(message, ctx)
    local base = message:sub(#CONFIG.commandPrefix + 1)
    local cmd, rest = base:match("^(%S+)%s*(.-)$")
    if not cmd or cmd == '' then return false end
    local entry = COMMANDS[cmd]
    if not entry then
        logWarn("Unknown command: " .. cmd)
        return false
    end
    local ok, err = pcall(entry.handler, rest or '', ctx)
    if not ok then logError("Command error: " .. tostring(err)) end
    return true
end

--------------------------------------------------
-- Message processing
--------------------------------------------------
local function handlePlayerMessage(chatbox, username, message, uuid, isHidden)
    local formatted = formatMessage(username, message, uuid, isHidden)
    print(formatted)

    local success, err = sendChatbox(chatbox, formatted, CONFIG.playerPrefix, CONFIG.brackets, CONFIG.bracketColorPlayer, CONFIG.chatRange)
    if not success then logWarn("Chatbox send failed: " .. tostring(err)) end

    if CONFIG.enableAI then
        local payload = {
            username = username,
            message = message,
            uuid = uuid,
            isHidden = isHidden,
            timestamp = os.time(),
            formattedMessage = formatted
        }
        local ok, aiRes = api.sendChat(payload)
        if ok and aiRes and aiRes.aiMessage then
            local aiFormatted = formatMessage(CONFIG.aiPrefix, aiRes.aiMessage, nil, false)
            print(aiFormatted)
            sendChatbox(chatbox, aiFormatted, CONFIG.aiPrefix, CONFIG.bracketsAI, CONFIG.bracketColorAI, CONFIG.chatRange)
        elseif not ok then
            logWarn("AI response queued (endpoint unreachable)")
        end
    end
end

--------------------------------------------------
-- Main loop
--------------------------------------------------

-- Main program
local function main()
    logInfo("Chat Monitor Program Starting...")

    if CONFIG.statusFetchOnStart then
        logInfo("Checking API status...")
        getAPIStatus()
    end

    local chatbox = findChatbox()
    if not chatbox then return end

    logInfo("Chatbox found. Listening for chat messages. Press Ctrl+T to stop.")

    local nextFlushAt = os.epoch('utc') + (CONFIG.flushIntervalSeconds + math.random(-CONFIG.flushJitter, CONFIG.flushJitter)) * 1000

    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        if not message then goto continue end

        if isCommand(message) then
            executeCommand(message, { chatbox = chatbox })
        elseif username then
            handlePlayerMessage(chatbox, username, message, uuid, isHidden)
        end

        local now = os.epoch('utc')
        if now >= nextFlushAt then
            api.flushQueue()
            nextFlushAt = now + (CONFIG.flushIntervalSeconds + math.random(-CONFIG.flushJitter, CONFIG.flushJitter)) * 1000
        end

        ::continue::
    end
end

-- Error handling wrapper
local function safeMain()
    local ok, err = pcall(main)
    if not ok then
        logError(err)
        logWarn("Ensure Advanced Peripherals & http API are enabled.")
    end
end

-- Run the program
safeMain()
