local backends = {
  mpd		= require("actionless.widgets.music.backends.mpd"),
  clementine	= require("actionless.widgets.music.backends.clementine")
}

return backends
