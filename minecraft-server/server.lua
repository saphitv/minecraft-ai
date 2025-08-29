-- server.lua
-- Orchestrates peripherals, commands, and main loop using modular components.

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
local CONFIG = require("config")
local logger = require("logger")
local commands = require("commands")
local chatProcessor = require("chat_processor")

api.init()

--------------------------------------------------
-- Peripheral / utilities
--------------------------------------------------

-- Function to find and connect to a chatbox peripheral
local function findChatbox()
    local chatbox = peripheral.find("chat_box")
    if not chatbox then
        logger.warn("No chatbox peripheral found (Expected 'chat_box').")
        logger.warn("Ensure Advanced Peripherals chatbox is connected.")
        return nil
    end
    return chatbox
end

-- Function to format chat messages with advanced features
-- (formatting & sending moved to chat_processor.lua)

-- Function to get status from Next.js API
local function getAPIStatus()
    local data, err = api.getStatus(true)
    if data then
        if data.message then
            logger.info("API Status: " .. data.message)
        else
            logger.info("API Status received")
        end
    else
        logger.warn("Failed to get API status: " .. tostring(err))
    end
    return data
end

-- (commands handled by commands.lua)

--------------------------------------------------
-- Message processing
--------------------------------------------------
-- (player message handling moved to chat_processor.lua)

--------------------------------------------------
-- Main loop
--------------------------------------------------

-- Main program
local function main()
    logger.info("Chat Monitor Program Starting...")

    if CONFIG.statusFetchOnStart then
    logger.info("Checking API status...")
        getAPIStatus()
    end

    local chatbox = findChatbox()
    if not chatbox then return end

    logger.info("Chatbox found. Listening for chat messages. Press Ctrl+T to stop.")

    local nextFlushAt = os.epoch('utc') + (CONFIG.flushIntervalSeconds + math.random(-CONFIG.flushJitter, CONFIG.flushJitter)) * 1000

    while true do
        local event, username, message, uuid, isHidden = os.pullEvent("chat")
        if not message then goto continue end

        if commands.isCommand(message) then
            commands.execute(message, { chatbox = chatbox, getAPIStatus = getAPIStatus })
        elseif username then
            chatProcessor.handle(chatbox, username, message, uuid, isHidden)
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
        logger.error(err)
        logger.warn("Ensure Advanced Peripherals & http API are enabled.")
    end
end

-- Run the program
safeMain()
