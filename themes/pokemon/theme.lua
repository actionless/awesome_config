local getdir = require("awful.util").getdir
local g_string = require("gears.string")
local dpi = require("beautiful.xresources").apply_dpi

local create_theme = require("actionless.common_theme").create_theme


local theme_dir = getdir("config").."/themes/pokemon/"
local icons_dir = getdir("config").."/icons/pokemon_hidpi/"

local theme = dofile(getdir("config").."/themes/gtk/theme.lua")
-- remove all the icons:
for full_name, value in pairs(theme) do
  if (
      type(value)=="string" and
      g_string.startswith(value, theme.icons_dir) and
      (value ~= theme.icons_dir)
  ) then
    theme[full_name] = nil
  end
end

theme.dir = theme_dir
theme.icons_dir = icons_dir

theme.show_widget_icon = true
theme.recolor_widget_icons = false
theme.panel_widget_width = dpi(30)

theme = create_theme({ theme=theme, icons_dir=icons_dir, theme_dir=theme_dir })

return theme
