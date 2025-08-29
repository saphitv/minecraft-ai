-- chat_processor.lua
-- Handles player chat forwarding & AI response display
local CONFIG = require("config")
local logger = require("logger")
local api = require("api_client")

local M = {}

local function formatMessage(username, message, uuid, isHidden)
    local hiddenIndicator = isHidden and " [HIDDEN]" or ""
    return string.format("[%s%s] %s", username, hiddenIndicator, message)
end

local function sendChatbox(chatbox, text, prefix, brackets, bracketColor, range)
    if not chatbox or type(chatbox.sendMessage) ~= "function" then
        return false, "chatbox unavailable"
    end
    return chatbox.sendMessage(text, prefix, brackets, bracketColor, range)
end

function M.handle(chatbox, username, message, uuid, isHidden)
    local formatted = formatMessage(username, message, uuid, isHidden)
    print(formatted)

    local success, err = sendChatbox(chatbox, formatted, CONFIG.playerPrefix, CONFIG.brackets, CONFIG.bracketColorPlayer, CONFIG.chatRange)
    if not success then logger.warn("Chatbox send failed: " .. tostring(err)) end

    if CONFIG.enableAI and message:sub(1,1) ~= CONFIG.commandPrefix then
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
            logger.warn("AI response queued (endpoint unreachable)")
        end
    end
end

return M
