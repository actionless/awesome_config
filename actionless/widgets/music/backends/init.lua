--[[
  Licensed under GNU General Public License v2
   * (c) 2014-2021, Yauheni Kirylau
--]]

local mpris_creator = require("actionless.widgets.music.mpris_creator")

local backends = {
  clementine = mpris_creator('clementine', {seek=30}),
  firefox = mpris_creator.create_for_match('MediaPlayer2.firefox', {seek=30}),
  goodvibes = mpris_creator('Goodvibes', {cmd='goodvibes', key_artist="goodvibes:station"}),
  gradio = mpris_creator('gradio'),  -- @TODO: removeme
  headset = mpris_creator('headset', {seek=60}),
  mopidy = require("actionless.widgets.music.backends.mopidy"),
  mpd = require("actionless.widgets.music.backends.mpd"),
  mpv = mpris_creator.create_for_match('MediaPlayer2.mpv', {seek=30}),
  shortwave = mpris_creator('de.haeckerfelix.Shortwave', {cmd='shortwave'}),
  spotify = require("actionless.widgets.music.backends.spotify"),
  strawberry = mpris_creator('strawberry', {seek=30}),
  tuner = mpris_creator('Tuner', {cmd='com.github.louis77.tuner'}),
}
return backends
