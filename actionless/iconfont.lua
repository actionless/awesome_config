beautiful = require("beautiful")

local iconfont = {}

local symbols = {
  net_wifi = ' ',
  music = '',
  music_on = '',
  music_off = '',
  vol_mute = '',
  vol_low = '',
  vol = '',
  vol_high = '',
}

function iconfont.get_symbol(name)
  return symbols[name]
end

return iconfont
