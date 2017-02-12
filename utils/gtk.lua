local xresources = require("beautiful.xresources")

local gtk = {
  cached_theme_variables = nil
}


local function get_gtk_color_matcher(_style_context, color_name)
  --local m = _style_context:lookup_color(color_name):to_string():gmatch("[0-9]+")
  --return "#" .. string.format("%2.2x", m()) .. string.format("%2.2x", m()) .. string.format("%2.2x", m())
  --
  local color = _style_context:lookup_color(color_name)
  if not color then return nil end
  local hex = color:to_string()
  print("found "..color_name.." = "..hex)
    --color:free()
  return hex:gmatch("[0-9]+")
end

local function lookup_gtk_color_to_hex(_style_context, color_name)
  local m = get_gtk_color_matcher(_style_context, color_name)
  return m and (
    "#" .. string.format("%2.2x", m()) .. string.format("%2.2x", m()) .. string.format("%2.2x", m())
  )
end

local function lookup_gtk_color_fake_int(_style_context, color_name)
  local m = get_gtk_color_matcher(_style_context, color_name)
  return m and tonumber(m())
end


function gtk.get_theme_variables()
  if gtk.cached_theme_variables then
    return gtk.cached_theme_variables
  end

  local lgi = require('lgi')
  local Gtk = lgi.Gtk
  local window = Gtk.Window{
    --on_destroy = Gtk.main_quit,
  }
  local style_context = window:get_style_context()
  local result = {}

  result.bg_color = lookup_gtk_color_to_hex(style_context, "theme_bg_color")
  result.fg_color = lookup_gtk_color_to_hex(style_context, "theme_fg_color")
  result.base_color = lookup_gtk_color_to_hex(style_context, "theme_base_color")
  result.text_color = lookup_gtk_color_to_hex(style_context, "theme_text_color")
  result.selected_bg_color = lookup_gtk_color_to_hex(style_context, "theme_selected_bg_color")
  result.selected_fg_color = lookup_gtk_color_to_hex(style_context, "theme_selected_fg_color")

  result.tooltip_bg_color = lookup_gtk_color_to_hex(style_context, "theme_tooltip_bg_color") or
    result.bg_color
  result.tooltip_fg_color = lookup_gtk_color_to_hex(style_context, "theme_tooltip_fg_color") or
    result.fg_color
  result.osd_bg_color = lookup_gtk_color_to_hex(style_context, "osd_bg") or
    result.tooltip_bg_color
  result.osd_fg_color = lookup_gtk_color_to_hex(style_context, "osd_fg") or
    result.tooltip_fg_color
  result.osd_border_color = lookup_gtk_color_to_hex(style_context, "osd_borders_color") or
    result.osd_fg_color
  result.menubar_bg_color = lookup_gtk_color_to_hex(style_context, "menubar_bg_color") or
    result.bg_color
  result.menubar_fg_color = lookup_gtk_color_to_hex(style_context, "menubar_fg_color") or
    result.fg_color

  result.button_bg_color = lookup_gtk_color_to_hex(style_context, "button_bg_color") or
    result.bg_color
  result.button_fg_color = lookup_gtk_color_to_hex(style_context, "button_fg_color") or
    result.fg_color
  result.header_button_bg_color = lookup_gtk_color_to_hex(style_context, "header_button_bg_color") or
    result.menubar_bg_color
  result.header_button_fg_color = lookup_gtk_color_to_hex(style_context, "header_button_fg_color") or
    result.menubar_fg_color

  result.wm_bg_color = lookup_gtk_color_to_hex(style_context, "wm_bg") or
    result.menubar_bg_color
  result.wm_border_focused_color = lookup_gtk_color_to_hex(style_context, "wm_border_focused") or
    result.selected_bg_color
  result.wm_title_focused_color = lookup_gtk_color_to_hex(style_context, "wm_title_focused") or
    result.menubar_bg_color
  result.wm_icons_focused_color = lookup_gtk_color_to_hex(style_context, "wm_icons_focused") or
    result.menubar_fg_color
  result.wm_border_unfocused_color = lookup_gtk_color_to_hex(style_context, "wm_border_unfocused") or
    result.wm_bg_color
  result.wm_title_unfocused_color = lookup_gtk_color_to_hex(style_context, "wm_title_unfocused") or
    result.menubar_bg_color
  result.wm_icons_unfocused_color = lookup_gtk_color_to_hex(style_context, "wm_icons_unfocused") or
    result.menubar_fg_color
  result.roundness = lookup_gtk_color_fake_int(style_context, "roundness") or 0
  result.spacing = lookup_gtk_color_fake_int(style_context, "spacing") or xresources.apply_dpi(3)

  gtk.cached_theme_variables = result
  window:destroy()
  return result
end

return gtk
