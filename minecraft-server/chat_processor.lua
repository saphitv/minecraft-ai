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

-- Translate ampersand color codes (&d, &7, &r, etc.) into Minecraft section sign codes (§d ...)
local function colorize(text)
    if not text then return text end
    return (text:gsub("&([0-9a-fk-or])", "§%1"))
end

function M.handle(chatbox, username, message, uuid, isHidden)
    -- Still log player message locally, but DO NOT echo it back into chat (avoid duplicate message)
    local formatted = formatMessage(username, message, uuid, isHidden)
    print(formatted)

    -- Forward to AI if enabled and not a command
    if CONFIG.enableAI and message:sub(1, 1) ~= CONFIG.commandPrefix then
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
            -- Desired format: [playerPrefix] <AI>: response with colored <> and AI text
            local aiText = aiRes.aiMessage or ""
            local aiPrefix = CONFIG.aiPrefix or "AI"
            local aiColor = CONFIG.bracketColorAI or "&d" -- color for <> and AI label
            local colonColor = "&7"
            local reset = "&r"

            local coloredTagRaw = string.format("%s<%s>%s%s:%s ", aiColor, aiPrefix, reset, colonColor, reset)
            local messageOut = colorize(coloredTagRaw) .. aiText

            -- Console log stripped (no color codes) for readability
            print(string.format("[%s] <%s>: %s", CONFIG.playerPrefix, aiPrefix, aiText))

            local okSend, err = sendChatbox(
                chatbox,
                messageOut,
                CONFIG.playerPrefix,
                CONFIG.brackets or "[]",
                CONFIG.bracketColorPlayer,
                CONFIG.chatRange
            )
            if not okSend then logger.warn("Chatbox send failed: " .. tostring(err)) end
        elseif not ok then
            logger.warn("AI response queued (endpoint unreachable)")
        end
    end
end

return M
