--[[
     Licensed under GNU General Public License v2
      * (c) 2014  Yauheni Kirylau
--]]

local os = os
local parse = require("utils.parse")

local xresources = {}

xresources.fallback = {
  --black
  ["0"] = '#000000',
  ["8"] = '#465457',
  --red
  ["1"] = '#cb1578',
  ["9"] = '#dc5e86',
  --green
  ["2"] = '#8ecb15',
  ["10"] = '#9edc60',
  --yellow
  ["3"] = '#cb9a15',
  ["11"] = '#dcb65e',
  --blue
  ["4"] = '#6f15cb',
  ["12"] = '#7e5edc',
  --purple
  ["5"] = '#cb15c9',
  ["13"] = '#b75edc',
  --cyan
  ["6"] = '#15b4cb',
  ["14"] = '#5edcb4',
  --white
  ["7"] = '#888a85',
  ["15"] = '#ffffff',
  --
  c  = '#ae81ff',
  bg  = '#0e0021',
  fg  = '#bcbcbc',
}

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
  colors.bg = string.match(query, "*background:[^#]*(#[%a%d]+)") or xresources.fallback.bg
  colors.fg = string.match(query, "*foreground:[^#]*(#[%a%d]+)") or xresources.fallback.fg
  for i,color in string.gmatch(query, "%*color(%d+):[^#]*(#[%a%d]+)") do
    colors[i] = color
  end
  if not colors["15"] then return xresources.fallback end
  return colors
end


function xresources.compute_fontsize(size)
  if not xresources.dpi then
    local file = io.popen(
      "xrdb -query"
    )
    local query = file:read('*a')
    xresources.dpi = tonumber(string.match(query, "dpi:[%s]+([%d]+)"))
    file:close()
  end
  if not xresources.dpi then
    return size
  else
    return size/96*xresources.dpi
  end
end



return xresources
