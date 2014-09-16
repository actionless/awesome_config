--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local awful = require("awful")
local client = client
local wibox = require("wibox")
local beautiful = require("beautiful")

local widgets = require("actionless.widgets")


local titlebar = {}

function titlebar.get_titlebar_function(c)
  local position = beautiful.titlebar_position or 'top'
    if position == "left" then
        return c.titlebar_left
    elseif position == "right" then
        return c.titlebar_right
    elseif position == "top" then
        return c.titlebar_top
    elseif position == "bottom" then
        return c.titlebar_bottom
    else
        error("Invalid titlebar position '" .. position .. "'")
    end
end

function titlebar.remove_titlebar(c)
        awful.titlebar.hide(c, beautiful.titlebar_position)
end

function titlebar.remove_border(c)
	titlebar.remove_titlebar(c)
	c.border_width = 0
	--c.border_color = beautiful.border_normal
end

function titlebar.make_titlebar(c)
	c.border_color = beautiful.titlebar_focus_border
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

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(awful.titlebar.widget.closebutton(c))
	left_layout:add(awful.titlebar.widget.minimizebutton(c))
	--left_layout:add(awful.titlebar.widget.maximizedbutton(c))

	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(awful.titlebar.widget.ontopbutton(c))
	right_layout:add(awful.titlebar.widget.stickybutton(c))

	local middle_layout = wibox.layout.flex.horizontal()
	local title = awful.titlebar.widget.titlewidget(c)
	title:set_align("center")
	title:set_font(beautiful.titlebar_font)
	middle_layout:add(title)
	middle_layout:buttons(buttons)

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_right(right_layout)
	layout:set_middle(middle_layout)

	awful.titlebar(
          c,
          { size=28,
            position = beautiful.titlebar_position,
            opacity = beautiful.titlebar_opacity }
        ):set_widget(layout)
end

function titlebar.titlebar_toggle(c)
	if (titlebar.get_titlebar_function(c)(c):geometry()['height'] > 0)
        then
		titlebar.remove_titlebar(c)
	else
		titlebar.remove_titlebar(c)
		titlebar.make_titlebar(c)
	end
end


return titlebar
