local backends = {
  clementine	= require("actionless.widgets.music.backends.clementine"),
  spotify	= require("actionless.widgets.music.backends.spotify"),
  mpd	= require("actionless.widgets.music.backends.mpd"),
  mopidy = require("actionless.widgets.music.backends.mopidy"),
  gradio = require("actionless.widgets.music.backends.gradio"),
}

return backends
