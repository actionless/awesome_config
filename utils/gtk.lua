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
    --color:free()
  return hex:gmatch("[0-9]+")
end


local function lookup_gtk_color_to_hex(_style_context, color_name)
  local m = get_gtk_color_matcher(_style_context, color_name)
  return m and (
    "#" .. string.format("%2.2x", m()) .. string.format("%2.2x", m()) .. string.format("%2.2x", m())
  )
end


function gtk.get_theme_variables()
  if gtk.cached_theme_variables then
    return gtk.cached_theme_variables
  end

  local result = {}
  local lgi = require('lgi')
  local Gtk = lgi.Gtk
  local window
  pcall(function()
    window = Gtk.Window{
      --on_destroy = Gtk.main_quit,
    }
  end)
  if not window then
    print("Seems like GTK+3 is not installed or theme is not set correctly.")
    return result
  end
  local style_context = window:get_style_context()

  for _, color_data in ipairs({
    {"bg_color", "theme_bg_color"},
    {"fg_color", "theme_fg_color"},
    {"base_color", "theme_base_color"},
    {"text_color", "theme_text_color"},
    {"selected_bg_color", "theme_selected_bg_color"},
    {"selected_fg_color", "theme_selected_fg_color"},
    --
    {"tooltip_bg_color", "theme_tooltip_bg_color", "bg_color"},
    {"tooltip_fg_color", "theme_tooltip_fg_color", "fg_color"},
    {"osd_bg_color", "osd_bg", "tooltip_bg_color"},
    {"osd_fg_color", "osd_fg", "tooltip_fg_color"},
    {"osd_border_color", "osd_borders_color", "osd_fg_color"},
    {"menubar_bg_color", "menubar_bg_color", "bg_color"},
    {"menubar_fg_color", "menubar_fg_color", "fg_color"},
    --
    {"button_bg_color", "button_bg_color", "bg_color"},
    {"button_fg_color", "button_fg_color", "fg_color"},
    {"header_button_bg_color", "header_button_bg_color", "menubar_bg_color"},
    {"header_button_fg_color", "header_button_fg_color", "menubar_fg_color"},
    --
    {"wm_bg_color", "wm_bg", "menubar_bg_color"},
    {"wm_border_focused_color", "wm_border_focused", "selected_bg_color"},
    {"wm_title_focused_color", "wm_title_focused", "menubar_bg_color"},
    {"wm_icons_focused_color", "wm_icons_focused", "menubar_fg_color"},
    {"wm_border_unfocused_color", "wm_border_unfocused", "wm_bg_color"},
    {"wm_title_unfocused_color", "wm_title_unfocused", "menubar_bg_color"},
    {"wm_icons_unfocused_color", "wm_icons_unfocused", "menubar_fg_color"},
  }) do
    local result_key, style_context_key, fallback_key = (unpack or table.unpack)(color_data)
    result[result_key] = lookup_gtk_color_to_hex(style_context, style_context_key) or
      result[fallback_key]
  end
  local font = style_context:get_font("NORMAL")
  result.font_family = font:get_family()
  result.font_size = font:get_size()/1024

  local button = Gtk.Button()
  local button_style_context = button:get_style_context()
  for result_key, style_context_property in pairs({
    border_radius="border-radius",
    border_width="border-top-width",
  }) do
    local property = button_style_context:get_property(style_context_property, "NORMAL")
    result[result_key] = property.value
    property:unset()
  end
  button:destroy()

  window:destroy()
  gtk.cached_theme_variables = result
  return result
end


return gtk
