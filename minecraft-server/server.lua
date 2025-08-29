-- Chat Monitor Program for ComputerCraft with Advanced Peripherals
-- Listens for chat messages, displays them via chatbox, and syncs with external API

-- Local modules / APIs (ComputerCraft provides peripheral & http globals normally; keep require for environments that support it)
---@diagnostic disable: undefined-global
local peripheral = peripheral or (_G and _G.peripheral) or (function() local ok, mod = pcall(require, 'peripheral'); if ok then return mod end end) --[[@as any]]
local http = http or (_G and _G.http) or (function() local ok, mod = pcall(require, 'http'); if ok then return mod end end) --[[@as any]]
---@diagnostic enable: undefined-global
local api = require("api_client")

api.init() -- loads config / queue

-- Function to find and connect to a chatbox peripheral
local function findChatbox()
    local chatbox = peripheral.find("chatBox")
    if not chatbox then
        print("No chatbox peripheral found!")
        print("Make sure you have an Advanced Peripherals chatbox connected.")
        return nil
    end
    return chatbox
end

-- Function to format chat messages with advanced features
local function formatMessage(username, message, uuid, isHidden)
    local hiddenIndicator = isHidden and " [HIDDEN]" or ""
    return string.format("[%s%s] %s", username, hiddenIndicator, message)
end

-- Function to send chat data to Next.js API
local function sendToAPI(chatData)
    return api.sendChat(chatData)
end

-- Function to get status from Next.js API
local function getAPIStatus()
    local data, err = api.getStatus(true)
    if data then
        if data.message then
            print("API Status: " .. data.message)
        else
            print("API Status received")
        end
    else
        print("Failed to get API status: " .. tostring(err))
    end
    return data
end

-- Main program
local function main()
    print("Chat Monitor Program Starting...")

    -- Check API status
    print("Checking Next.js API status...")
    local apiStatus = getAPIStatus()

    -- Find chatbox peripheral
    local chatbox = findChatbox()
    if not chatbox then
        return
    end

    print("Chatbox found! Listening for chat messages...")
    print("Press Ctrl+T to stop the program.")

    -- Main loop to listen for chat events
    while true do
        -- Wait for a chat event (captures all 4 parameters: username, message, uuid, isHidden)
        local event, username, message, uuid, isHidden = os.pullEvent("chat")

        -- Command handling (local commands start with !)
        if message == "!apistatus" then
            getAPIStatus()
            api.flushQueue()
        elseif message and message:sub(1,9) == "!setapi " then
            local newUrl = message:sub(10):gsub("%s+$", "")
            if newUrl ~= '' then api.setBaseUrl(newUrl) end
        elseif message == "!flushapi" then
            api.flushQueue()
        elseif message == "!reloadapi" then
            api.init({ force = true })
            print("[api] Reload attempted.")
        end

        -- Check if the message is from a player (not system/command messages)
        if username and message then
            -- Format the message with all available information
            local formattedMessage = formatMessage(username, message, uuid, isHidden)

            -- Print to computer console
            print(formattedMessage)

            -- Send to chatbox with enhanced formatting
            -- Using custom prefix "ChatBot", brackets "[]", and bracket color
            local success, errorMsg = chatbox.sendMessage(
                formattedMessage, -- message
                "ChatBot",        -- prefix
                "[]",             -- brackets
                "&3",             -- bracket color (cyan)
                100               -- range (100 blocks)
            )

            -- Check if message was sent successfully
            if not success then
                print("Failed to send message: " .. errorMsg)
            end

            -- Send chat data to API (skip if it was an internal command beginning with '!')
            if message:sub(1,1) ~= '!' then
                local chatData = {
                    username = username,
                    message = message,
                    uuid = uuid,
                    isHidden = isHidden,
                    timestamp = os.time(),
                    formattedMessage = formattedMessage
                }
                sendToAPI(chatData)
            end

            -- Periodically try to flush queued requests (non-blocking quick check)
            if math.random() < 0.1 then
                api.flushQueue()
            end
        end
    end
end

-- Error handling wrapper
local function safeMain()
    local success, error = pcall(main)
    if not success then
        print("Error: " .. error)
        print("Make sure Advanced Peripherals is installed and configured correctly.")
    end
end

-- Run the program
safeMain()
