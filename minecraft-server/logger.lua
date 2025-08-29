-- logger.lua
-- Simple leveled logging utilities
local logger = {}

local function log(level, msg)
    print(string.format("[%s] %s", level, msg))
end

function logger.info(msg) log("INFO", msg) end
function logger.warn(msg) log("WARN", msg) end
function logger.error(msg) log("ERROR", msg) end

return logger
