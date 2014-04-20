local awful = require("awful")
local wibox = require("wibox")

local settings = require("widgets").settings
local beautiful = require("widgets").helpers.beautiful


bars = {}


function bars.make_border(c, num_clients)
	if not settings.gtk3_app_classes[c.class] then
		c.border_width = beautiful.border_width
	end
	if num_clients == 1 then
		c.border_color = beautiful.border_normal
	else
		c.border_color = beautiful.border_focus
	end
end


function bars.remove_border(c)
	remove_titlebar(c)
	c.border_width = 0
	--c.border_color = beautiful.border_normal
end


function bars.remove_titlebar(c)
	awful.titlebar(c, {size = 0})
end


function bars.make_titlebar(c)
	c.border_color = beautiful.titlebar_focus
	-- buttons for the titlebar
	local buttons = awful.util.table.join(
		awful.button({ }, 1, function()
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
                awful.button({ }, 2, function()
                        client.focus = c
                        c:raise()
			c.maximized_horizontal = not c.maximized_horizontal
                        c.maximized_vertical   = not c.maximized_vertical
                end),
		awful.button({ }, 3, function()
			client.focus = c
			c:raise()
			awful.mouse.client.resize(c)
		end)
		)
	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(awful.titlebar.widget.closebutton(c))
	left_layout:add(awful.titlebar.widget.minimizebutton(c))
	--left_layout:add(awful.titlebar.widget.maximizedbutton(c))
	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(awful.titlebar.widget.ontopbutton(c))
	right_layout:add(awful.titlebar.widget.stickybutton(c))
	-- The title goes in the middle
	local middle_layout = wibox.layout.flex.horizontal()
	local title = awful.titlebar.widget.titlewidget(c)
	title:set_align("center")
	title:set_font(beautiful.titlebar_font)
	middle_layout:add(title)
	middle_layout:buttons(buttons)
	-- Now bring it all together
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_right(right_layout)
	layout:set_middle(middle_layout)

	awful.titlebar(c,{size=16}):set_widget(layout)
end


return bars
