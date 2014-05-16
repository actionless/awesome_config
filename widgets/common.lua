local wibox			= require("wibox")

local beautiful		= require("widgets.helpers").beautiful


local common = {}


function common.widget()
	local widget_dict = {}

	widget_dict.text_widget = wibox.widget.textbox('')
	widget_dict.text_bg = wibox.widget.background()
	widget_dict.text_bg:set_widget(widget_dict.text_widget)

	widget_dict.icon_widget = wibox.widget.imagebox()
	widget_dict.icon_bg = wibox.widget.background()
	widget_dict.icon_bg:set_widget(widget_dict.icon_widget)

	widget_dict.widget = wibox.layout.fixed.horizontal()
	widget_dict.widget:add(widget_dict.icon_bg)
	widget_dict.widget:add(widget_dict.text_bg)

	return setmetatable(widget_dict, { __index = widget_dict.widget })
end

return common
