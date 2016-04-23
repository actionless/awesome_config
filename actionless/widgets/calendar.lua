--[[
   Licensed under GNU General Public License v2
        * (c) 2013, Luke Bonham
--]]

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")


-- Calendar notification
local calendar = {}
calendar.notification = nil

function calendar:hide()
  if self.notification ~= nil then
    naughty.destroy(self.notification)
    self.notification = nil
  end
end

function calendar:show(t_out, inc_offset)
  self:hide()

  local offs = inc_offset or 0
  local tims = t_out or 0
  local f, c_text, c_title
  local today = tonumber(os.date('%d'))
  local init_t = 'cal  | sed -r -e "s/(^| )( '

  if offs == 0
  then -- current month showing, today highlighted
    if today >= 10 then
      init_t = 'cal  | sed -r -e "s/(^| )('
    end
    self.offset = 0
    self.notify_icon = self.icons .. today .. ".png"
    -- bg and fg inverted to highlight today
    f = io.popen(
      init_t .. today .. ')($| )' ..
      '/\\1' ..
      '<b>' ..
      '<span foreground=\\"' .. self.bg .. '\\"' ..
         ' background=\\"' .. self.fg .. '\\">' ..
        '\\2' ..
      '<\\/span>' ..
      '<\\/b>' ..
      '\\3/"' )

  else -- no current month showing, no day to highlight
    local month = tonumber(os.date('%m'))
    local year = tonumber(os.date('%Y'))
    self.offset = self.offset + offs
    month = month + self.offset
    if month > 12 then
      month = month % 12
      year = year + 1
      if month <= 0 then month = 12 end
    elseif month < 1 then
      month = month + 12
      year = year - 1
      if month <= 0 then month = 1 end
    end
    self.notify_icon = nil
    f = io.popen('cal ' .. month .. ' ' .. year)
  end

  c_title = f:read()
  c_text = 
    "<tt>" ..
    f:read() .. "\n" ..
    f:read("*all"):gsub("\n*$", "") ..
    "</tt>"
  f:close()
  self.notification = naughty.notify({
    title = c_title,
    text = c_text,
    icon = self.notify_icon,
    position = self.position,
    timeout = tims,
    font = beautiful.notification_monofont,
  })
end

function calendar:attach(widget, args)
  args = args or {}
  self.icons = args.icons or beautiful.icons_dir .. "calendar/"
  self.fg = args.fg or beautiful.fg_normal or "#FFFFFF"
  self.bg = args.bg or beautiful.bg_normal or "#FFFFFF"
  self.position = args.position or beautiful.widget_notification_position or "top_right"

  self.offset = 0
  self.notify_icon = nil

  widget:connect_signal("mouse::enter", function () self:show() end)
  widget:connect_signal("mouse::leave", function () self:hide() end)
  widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () self:show(0, -1) end),
    awful.button({ }, 3, function () self:show(0,  1) end)
  ))
end

return calendar
