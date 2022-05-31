local cairo = require('lgi').cairo
local Rsvg = require('lgi').Rsvg

local awesome_menubar = require("menubar")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local gstring = require('gears.string')


local ICON_SIZES = {
  '512x512',
  '256x256',
  'scalable',
  '128x128',
  '96x96',
  '64x64',
  '32x32',
  '24x24',
  '22x22',
  'symbolic',
}
local FORMATS = {
  '.svg',
  '.png',
  '-symbolic.svg',
  '.symbolic.png',
}
local ICON_THEMES

local module = {}

--module.default_icon_size = 128
module.default_icon_size = nil

function module.resize_svg(input_image, icon_width, icon_height)

  if not module.default_icon_size then
    module.default_icon_size = beautiful.menu_height
  end

  icon_width = icon_width or module.default_icon_size
  icon_height = icon_height or icon_width

  local img = cairo.ImageSurface(cairo.Format.ARGB32, icon_width, icon_height)
  local cr = cairo.Context(img)
  local handle = assert(Rsvg.Handle.new_from_file(input_image))
  local dim = handle:get_dimensions()
  local aspect = math.min(icon_width/dim.width, icon_height/dim.height)
  cr:scale(aspect, aspect)
  handle:render_cairo(cr)
  return img
end

local function do_lookup(category, name, icon_themes, icon_sizes)
  for _, icon_theme_name in ipairs(icon_themes) do
    for _, icon_root in ipairs({
      os.getenv('HOME') .. '/.icons/',
      '/usr/share/icons/',
    }) do
      for _, icon_size in ipairs(icon_sizes) do
        for _, extension in ipairs(FORMATS) do
          for _, path in ipairs({
            icon_root .. icon_theme_name .. "/" .. icon_size .. "/" .. category .. "/" .. name .. extension,
            icon_root .. icon_theme_name .. "/" .. category .. "/" .. icon_size .. "/" .. name .. extension,
          }) do
            if gfs.file_readable(path) then
              --log("R:"..path)
              return path
            end
          end
        end
      end
    end
  end
end

local _path_cache = {}

function module.get_icon(category, name, args)
  if not name then
    return
  end
  if category == 'apps' or category == 'categories' then
    local awesome_found = awesome_menubar.utils.lookup_icon(name)
    if awesome_found then return awesome_found end
  end

  if not ICON_THEMES then
    ICON_THEMES = {
      beautiful.icon_theme,
      'gnome',
      'Adwaita',
      'breeze',
      'hicolor',
      --'locolor',
    }
  end

  args = args or {}
  local icon_sizes = args.icon_sizes or ICON_SIZES
  local icon_themes = args.icon_themes or ICON_THEMES

  local cache_id = string.format('%s/%s/%s/%s', category, name, icon_themes, icon_sizes)
  if _path_cache[cache_id] == nil then
    _path_cache[cache_id] = do_lookup(category, name, icon_themes, icon_sizes) or false
  end
  local path = _path_cache[cache_id]
  if not path then
    return nil
  end
  if gstring.endswith(path, '.svg') then
    return module.resize_svg(path)
  else
    return path
  end
end

function module.get_app_icon(name, args)
  return module.get_icon('apps', name, args)
end

return module
