local generate_theme = require("actionless.common_theme").generate_theme

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/vertex"

local vertex = {}

vertex.bg = "#3d3e40"
vertex.fg = "#f3f3f5"
vertex.base = "#2b2b2c"
vertex.select = "#4080fb"

-- TERMINAL COLORSCHEME:
--
color = {}
color.b  = vertex.bg
color.f  = vertex.fg
color.c  = '#cc6699'
color[0]  = vertex.base
color[1]  = '#CC0000'
color[2]  = '#4E9A06'
color[3]  = '#C4A000'
color[4]  = vertex.select
color[5]  = '#75507B'
color[6]  = '#06989A'
color[7]  = vertex.fg
color[8]  = '#555753'
color[9]  = '#EF2929'
color[10] = '#8AE234'
color[11] = '#FCE94F'
color[12] = '#729FCF'
color[13] = '#AD7FA8'
color[14] = '#34E2E2'
color[15] = '#eeeeec'

-- PANEL COLORS:
--
panel_colors = {
  taglist='b',
  close=0,
  tasklist='b',
  media=0,
  info=0
}

-- GENERATE DEFAULT THEME:
--
local theme = generate_theme(
  theme_dir,
  color,
  panel_colors
)

theme.panel_enbolden_details	= true


theme.theme = vertex.select

theme.border_width              = "4"
theme.border_focus              = vertex.select
theme.titlebar_focus_border     = vertex.select

theme.panel_widget_fg = vertex.fg
theme.taglist_fg_occupied	= vertex.fg
theme.taglist_fg_empty		= vertex.fg
theme.taglist_fg_focus		= vertex.fg

theme.taglist_bg_focus		= vertex.base
theme.tasklist_fg_focus		= vertex.fg
theme.tasklist_fg_minimize	= color[8]
theme.tasklist_bg_minimize	= vertex.base

theme.titlebar_fg_focus         = theme.tasklist_fg_focus
theme.titlebar_fg_normal        = color[8]

theme.player_artist = vertex.select
theme.player_title = vertex.fg

-- CUSTOMIZE default theme:-----------------------------------------------

-- WALLPAPER:
-- Use nitrogen:
theme.wallpaper_cmd     = "nitrogen --restore"
-- Use wallpaper tile:
--theme.wallpaper = theme_dir .. '/pattern.png'

-- PANEL DECORATIONS:
--
theme.widget_decoration_arrl = 'sq'
theme.widget_decoration_arrr = 'sq'
theme.show_widget_icon = true

-- FONTS:
--
--theme.font = "Source Code Pro Bold 10.5"
--theme.sans_font = "Source Sans Pro Bold 10.3"
--
--theme.font = "Meslo LG S for Lcarsline Bold 10.5"
--theme.sans_font = "PT Sans Bold 10.3"
--
-- use ~/.fonts.conf, Luke ;)
theme.font = "Monospace 10.5"
theme.sans_font = "Sans 10.3"

theme.tasklist_font = "Sans Bold 10.3"
theme.titlebar_font = theme.tasklist_font
theme.taglist_font = theme.font
--
-- Don't use sans font:
--theme.sans_font	= theme.font

return theme
