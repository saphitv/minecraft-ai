-- api_client.lua
-- Reusable HTTP API helper for ComputerCraft / Advanced Peripherals environment
-- Provides: dynamic base URL loading, retries, simple queue buffering, status cache

---@diagnostic disable: undefined-global
local http = http --[[@as any]]
local fs = fs --[[@as any]]
local textutils = textutils --[[@as any]]
local sleep = sleep or function(...) end
---@diagnostic enable: undefined-global

local M = {}

-- Default configuration
local DEFAULTS = {
  baseUrl = "https://minecraft-ai.saphi.app",  -- public endpoint
  fallbackBaseUrl = "http://localhost:3000",    -- local dev fallback
  configFile = "api_config.json",               -- optional JSON override written next to program
  maxRetries = 3,
  retryBackoff = 2, -- seconds (exponential)
  queueFile = "api_queue.json", -- persisted unsent payloads
  enableQueue = true,
  timeout = 5 -- (informational; ComputerCraft http has built-in timeouts)
}

local state = {
  baseUrl = DEFAULTS.baseUrl,
  statusCache = nil,
  lastStatusAt = 0,
  queue = {},
  loaded = false
}

-- Utility: safe JSON encode/decode (ComputerCraft supplies textutils)
local function toJSON(tbl)
  local ok, res = pcall(textutils.serializeJSON or textutils.serialiseJSON, tbl)
  return ok and res or nil
end

local function fromJSON(str)
  if not str or str == '' then return nil end
  local ok, res = pcall(textutils.unserializeJSON or textutils.unserialiseJSON, str)
  return ok and res or nil
end

-- Load config from disk if present
local function loadConfigFile()
  local path = DEFAULTS.configFile
  if fs and fs.exists(path) then
    local h = fs.open(path, 'r')
    if h then
      local contents = h.readAll()
      h.close()
      local cfg = fromJSON(contents)
      if type(cfg) == 'table' and cfg.baseUrl then
        state.baseUrl = cfg.baseUrl
        return true, "Loaded baseUrl from config file: " .. state.baseUrl
      end
    end
  end
  return false, "Using default baseUrl: " .. state.baseUrl
end

-- Persist queue to disk (best-effort)
local function saveQueue()
  if not DEFAULTS.enableQueue or not fs then return end
  local h = fs.open(DEFAULTS.queueFile, 'w')
  if h then h.write(toJSON(state.queue) or '[]'); h.close() end
end

local function loadQueue()
  if not DEFAULTS.enableQueue or not fs or not fs.exists(DEFAULTS.queueFile) then return end
  local h = fs.open(DEFAULTS.queueFile, 'r')
  if not h then return end
  local data = fromJSON(h.readAll())
  h.close()
  if type(data) == 'table' then state.queue = data end
end

-- Public: (re)initialize
function M.init(opts)
  if state.loaded then return end
  if opts and opts.baseUrl then state.baseUrl = opts.baseUrl end
  loadConfigFile()
  loadQueue()
  state.loaded = true
end

-- Allow dynamic override at runtime
function M.setBaseUrl(url)
  state.baseUrl = url
  print("[api] Base URL set to " .. url)
end

function M.getBaseUrl()
  return state.baseUrl
end

-- Core request with retries + fallback
local function doRequest(method, path, bodyTable)
  if not http then
    return nil, "HTTP API not enabled. Run: setComputerCraftSetting('http.enabled', true)"
  end

  local fullUrl = state.baseUrl .. path
  local payload = bodyTable and toJSON(bodyTable) or nil
  local headers = { ["Content-Type"] = "application/json" }

  local attempt = 0
  local wait = DEFAULTS.retryBackoff
  local lastErr
  while attempt < DEFAULTS.maxRetries do
    attempt = attempt + 1
    local ok, res = pcall(function()
      if method == 'GET' then
        local h = http.get(fullUrl)
        if not h then return nil end
        local txt = h.readAll(); h.close(); return txt
      else
        local h = http.post(fullUrl, payload or '{}', headers)
        if not h then return nil end
        local txt = h.readAll(); h.close(); return txt
      end
    end)
    if ok and res then
      local data = fromJSON(res) or res
      return data, nil
    else
      lastErr = res or "unknown error"
      if attempt < DEFAULTS.maxRetries then
        sleep(wait)
        wait = wait * 2
      end
    end
  end

  -- Fallback attempt (single) if baseUrl is not fallback and retries exhausted
  if state.baseUrl ~= DEFAULTS.fallbackBaseUrl then
    print("[api] Primary unreachable, trying fallback...")
    local original = state.baseUrl
    state.baseUrl = DEFAULTS.fallbackBaseUrl
    local data, err = doRequest(method, path, bodyTable)
    if data then return data, nil end
    state.baseUrl = original -- restore
    return nil, err or lastErr
  end

  return nil, lastErr
end

-- Flush queued payloads
function M.flushQueue()
  if not DEFAULTS.enableQueue or #state.queue == 0 then return end
  print("[api] Flushing queued payloads: " .. #state.queue)
  local remaining = {}
  for _, item in ipairs(state.queue) do
    local ok, err = M.sendChat(item.payload, true) -- silent
    if not ok then
      table.insert(remaining, item) -- keep if still failing
    end
  end
  state.queue = remaining
  saveQueue()
end

-- Public endpoint helpers
function M.getStatus(force)
  local now = os.clock()
  if not force and state.statusCache and (now - state.lastStatusAt) < 10 then
    return state.statusCache
  end
  local data, err = doRequest('GET', '/api/chat-status')
  if data then
    state.statusCache = data
    state.lastStatusAt = now
    return data
  end
  return nil, err
end

function M.sendChat(chatData, silent)
  local data, err = doRequest('POST', '/api/chat-status', chatData)
  if not data then
    if not silent then print("[api] Failed to send chat: " .. tostring(err)) end
    if DEFAULTS.enableQueue then
      table.insert(state.queue, { ts = os.time(), payload = chatData })
      saveQueue()
      if not silent then print("[api] Queued chat payload (will retry later). Queue size=" .. #state.queue) end
    end
    return false, err
  end
  if not silent then print("[api] Chat sent OK") end
  return true, data
end

-- Generic (if needed)
function M.request(method, path, body)
  return doRequest(method, path, body)
end

return M
