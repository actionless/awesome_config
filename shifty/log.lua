local naughty = require("naughty")

local log = {}
local enabled = false

--- Enables or disables logging
-- @param value Boolean to enable or disable
function log.enable(value)
  enabled = value
end

--- Shows a popup and logs to a file
-- @param message The text message.
-- @param log_level 1 = INFO, 2 = WARN, 3 = ERROR, if nothting is provided 1 is used.
function log.log(message, log_level)
  if enabled == false then
    return false
  end

  if log_level == nil then
    log_level = 1
  end

  local log_table = {
    { level = "INFO", bg_colour = "#18F92C", fg_colour  = "#0E0E0E" },
    { level = "WARN", bg_colour = "#9E731F", fg_colour  = "#0E0E0E" },
    { level = "ERROR", bg_colour = "#FF0015", fg_colour  = "#000000" }
  }
  -- %c eg: Wed Jan 30 14:25:13 2013
  local time = os.date("%c")
  message = time .. " - " .. log_table[log_level].level .. " - " .. message ..  "\n" .. debug.traceback()

  local home = os.getenv("HOME")
  local log_file = io.open(home .. "/shifty.log", "a+")
  log_file:write(message .."\n")
  log_file:close()

  naughty.notify({ text = message, bg = log_table[log_level].bg_colour, fg = log_table[log_level].fg_colour})
end

return log
