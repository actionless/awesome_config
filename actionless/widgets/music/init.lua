local music = {
  backends	= require("actionless.widgets.music.backends"),
  widget	= require("actionless.widgets.music.widget"),
  tag_parser	= require("actionless.widgets.music.tag_parser"),
  backends_legacy = require("actionless.widgets.music.backends_legacy"),
  widget_legacy	= require("actionless.widgets.music.widget_legacy"),
}

return music
