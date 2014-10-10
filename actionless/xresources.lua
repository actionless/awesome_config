--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local os = os
local parse = require("actionless.parse")

local xresources = {}

function xresources.read(path)
  path = path or os.getenv("HOME") .. "/.Xresources"
  local result = parse.find_values_in_file(
    path,
    ".*%*(.*):[%s%t]+(.*)",
    {
      color0='color0',
      color1='color1',
      color2='color2',
      color3='color3',
      color4='color4',
      color5='color5',
      color6='color6',
      color7='color7',
      color8='color8',
      color9='color9',
      color10='color10',
      color11='color11',
      color12='color12',
      color13='color13',
      color14='color14',
      color15='color15',
      background='background',
      foreground='foreground',
      cursorColor='cursorColor',
      colorUL='colorUL',
      underlineColor='underlineColor'
    }
  )
  return result
end

function xresources.get_theme(xresources_table)
  local result = {}
  for i = 0, 15 do
    result[i] = xresources_table['color' .. tostring(i)]
  end
  result.b = xresources_table.background
  result.f = xresources_table.foreground
  result.c = xresources_table.colorUL
  return result
end

function xresources.read_theme(path)
  return xresources.get_theme(
    xresources.read(path)
  )
end

function xresources.get_current_theme()
  local colors = {}
  local file = io.popen("xrdb -query")
  local query = file:read('*a')
  file:close()
  for i,color in string.gmatch(query, "%*color(%d+):[^#]*(#[%a%d]+)") do
    colors[tonumber(i)] = color
  end
  colors.b = string.match(query, "*background:[^#]*(#[%a%d]+)")
  colors.f = string.match(query, "*foreground:[^#]*(#[%a%d]+)")
  return colors
end

return xresources
