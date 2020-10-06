local awesome_menubar = require("menubar")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")


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
  --'.svg',
  '.png',
  '.symbolic.png',
  '.svg',
  '-symbolic.svg',
}
local ICON_THEMES

local module = {}

function module.get_icon(category, name, args)
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

  if category == 'apps' or category == 'categories' then
    local awesome_found = awesome_menubar.utils.lookup_icon(name)
    if awesome_found then return awesome_found end
  end
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

return module
