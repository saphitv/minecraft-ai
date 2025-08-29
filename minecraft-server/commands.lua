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

-- registration (mirrors previous inline definitions)
register("apistatus", "Fetch API status + flush queue", function(_, ctx)
    ctx.getAPIStatus(); api.flushQueue()
end)

register("setapi", "Set base API URL: !setapi <url>", function(args, ctx)
    local newUrl = args:match("%S+")
    if newUrl then api.setBaseUrl(newUrl); logger.info("Base URL -> " .. newUrl) else logger.warn("Usage: !setapi <url>") end
end)

register("flushapi", "Force flush queued requests", function(_, ctx)
    api.flushQueue()
end)

register("reloadapi", "Reinitialize API module", function(_, ctx)
    api.init({ force = true })
    logger.info("API re-init requested (force flag).")
end)

register("help", "List available commands", function(_, ctx)
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
