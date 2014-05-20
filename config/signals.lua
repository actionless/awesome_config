local awful = require("awful")
local client = require("client")
local beautiful = require("beautiful")

local bars	= require("actionless.bars")


local signals = {}

function signals.init()
-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	if not startup and not c.size_hints.user_position
	   and not c.size_hints.program_position then
		awful.placement.no_overlap(c)
		awful.placement.no_offscreen(c)
	end
end)
--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

client.connect_signal("focus", function(c)
  if c.maximized_horizontal == true and c.maximized_vertical == true then
    -- maximized
    bars.remove_border(c)
  elseif awful.client.floating.get(c) then
    -- floating client
    bars.make_titlebar(c)
  elseif awful.layout.get(c.screen) == awful.layout.suit.floating then
    -- floating layout
    bars.make_titlebar(c)
  else
    bars.remove_titlebar(c)
    bars.make_border(c)
  end
end)

client.connect_signal("unfocus", function(c)
  if awful.client.floating.get(c) then
    -- floating client
    c.border_color = beautiful.titlebar
  elseif awful.layout.get(c.screen) == awful.layout.suit.floating then
    -- floating layout
    c.border_color = beautiful.titlebar
  else
    c.border_color = beautiful.border_normal
  end
end)

end
-- }}}
return signals
