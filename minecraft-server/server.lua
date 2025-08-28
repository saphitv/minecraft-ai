-- Chat Monitor Program for ComputerCraft with Advanced Peripherals
-- This program listens for chat messages and displays them using a chatbox peripheral
-- Also communicates with a Next.js API server

-- Load required APIs
peripheral = require("peripheral")
http = require("http")

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
    local apiUrl = "http://localhost:3000/api/chat-status"  -- Adjust URL as needed

    local success, response = pcall(function()
        local handle = http.post(apiUrl, textutils.serialiseJSON(chatData), {
            ["Content-Type"] = "application/json"
        })

        if handle then
            local responseText = handle.readAll()
            handle.close()
            return responseText
        else
            return nil
        end
    end)

    if success and response then
        print("Successfully sent data to API")
        return true
    else
        print("Failed to send data to API: " .. tostring(response))
        return false
    end
end

-- Function to get status from Next.js API
local function getAPIStatus()
    local apiUrl = "http://localhost:3000/api/chat-status"

    local success, response = pcall(function()
        local handle = http.get(apiUrl)
        if handle then
            local responseText = handle.readAll()
            handle.close()
            return responseText
        else
            return nil
        end
    end)

    if success and response then
        local statusData = textutils.unserialiseJSON(response)
        if statusData then
            print("API Status: " .. statusData.message)
            return statusData
        end
    else
        print("Failed to get API status")
    end

    return nil
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

        -- Check if the message is from a player (not system/command messages)
        if username and message then
            -- Format the message with all available information
            local formattedMessage = formatMessage(username, message, uuid, isHidden)

            -- Print to computer console
            print(formattedMessage)

            -- Send to chatbox with enhanced formatting
            -- Using custom prefix "ChatBot", brackets "[]", and bracket color
            local success, errorMsg = chatbox.sendMessage(
                formattedMessage,     -- message
                "ChatBot",            -- prefix
                "[]",                 -- brackets
                "&3",                 -- bracket color (cyan)
                100                   -- range (100 blocks)
            )

            -- Check if message was sent successfully
            if not success then
                print("Failed to send message: " .. errorMsg)
            end

            -- Send chat data to Next.js API
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
