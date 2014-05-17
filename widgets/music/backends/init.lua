local backends = {
  mpd		= require("widgets.music.backends.mpd"),
  clementine	= require("widgets.music.backends.clementine")
}

return backends
