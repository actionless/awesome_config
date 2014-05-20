local wibox			= require("wibox")

local beautiful		= require("actionless.helpers").beautiful


local common = {}


function common.widget()
	local widget = {}

	widget.text_widget = wibox.widget.textbox('')
	widget.text_bg = wibox.widget.background()
	widget.text_bg:set_widget(widget.text_widget)

	widget.icon_widget = wibox.widget.imagebox()
	widget.icon_bg = wibox.widget.background()
	widget.icon_bg:set_widget(widget.icon_widget)

	widget.widget = wibox.layout.fixed.horizontal()
	widget.widget:add(widget.icon_bg)
	widget.widget:add(widget.text_bg)

	function widget:set_image(...)
		return widget.icon_widget:set_image(...)
	end

	function widget:set_text(...)
		return widget.text_widget:set_text(...)
	end

	function widget:set_markup(...)
		return widget.text_widget:set_markup(...)
	end
  
  function widget:set_bg(...)
		widget.text_bg:set_bg(...)
    widget.icon_bg:set_bg(...)
	end

  function widget:set_fg(...)
		widget.text_bg:set_fg(...)
    widget.icon_bg:set_fg(...)
	end

	return setmetatable(widget, { __index = widget.widget })
end

return common
