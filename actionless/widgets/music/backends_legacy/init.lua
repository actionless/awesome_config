local backends = {
  mpd		= require("actionless.widgets.music.backends_legacy.mpd"),
  cmus		= require("actionless.widgets.music.backends_legacy.cmus"),
}

return backends
