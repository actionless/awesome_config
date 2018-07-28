local awful_util = require("awful.util")

local nixos = {}

function nixos.get_nix_xresources_theme_path()
  local result
  result = awful_util.pread("readlink -e /nix/store/*-awesome-3*/share/awesome/themes/xresources | tail -n 1")
  result = string.gsub(result, "\n", "")
  print("DEBUG")
  print(result)
  print("DEBUG_END")
  return result
end

return nixos
