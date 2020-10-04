local backends = {
  clementine	= require("actionless.widgets.music.backends.clementine"),
  spotify	= require("actionless.widgets.music.backends.spotify"),
  mpd	= require("actionless.widgets.music.backends.mpd"),
  mopidy = require("actionless.widgets.music.backends.mopidy"),
  gradio = require("actionless.widgets.music.backends.gradio"),  -- @TODO: removeme
  shortwave = require("actionless.widgets.music.backends.shortwave"),
  goodvibes = require("actionless.widgets.music.backends.goodvibes"),
  mpv = require("actionless.widgets.music.backends.mpv"),
  headset = require("actionless.widgets.music.backends.headset"),
  firefox = require("actionless.widgets.music.backends.firefox"),
}

return backends
