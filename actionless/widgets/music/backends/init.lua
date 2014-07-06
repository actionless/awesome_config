local backends = {
  mpd		= require("actionless.widgets.music.backends.mpd"),
  cmus		= require("actionless.widgets.music.backends.cmus"),
  clementine	= require("actionless.widgets.music.backends.clementine")
}

return backends
