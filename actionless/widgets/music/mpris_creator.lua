--[[
  Licensed under GNU General Public License v2
   * (c) 2020, Yauheni Kirylau
--]]

local dbus = dbus -- luacheck: ignore
local Gio = require("lgi").Gio
local GLib = require("lgi").GLib
local g_string		= require("gears.string")

local a_image = require("actionless.util.async_web_image")


local dbus_connection = assert(Gio.bus_get_sync(Gio.BusType.SESSION))
local default_parameters = GLib.Variant('()', {})
local default_reply_type = GLib.VariantType.new("()")


local function create(name, args)
  args = args or {}
  local cmd = args.cmd or name
  local seek = args.seek or false

  local dbus_path1 = "org.mpris.MediaPlayer2."..name
  local dbus_path2 = "/org/mpris/MediaPlayer2"
  local dbus_path3 = "org.mpris.MediaPlayer2.Player"

  local backend = {
    player_status = {},
    player_cmd = cmd,
  }

  function backend.init(widget)
    backend.player = widget
  end
  -------------------------------------------------------------------------------
  local function dbus_call(action, dbus_args)
    dbus_args = dbus_args or {}
    local callback = dbus_args.callback
    local parameters = dbus_args.parameters or default_parameters
    local reply_type = dbus_args.reply_type or default_reply_type
    local dbus_path = dbus_args.dbus_path3 or dbus_path3

    local function invoke_callback(conn, result)
        local call_result = conn:call_finish(result)
        local values
        if call_result then
          values = call_result.value
        end
        if callback then
            callback(values)
        end
    end

    dbus_connection:call(
      dbus_path1,
      dbus_path2,
      dbus_path,
      action,
      parameters,
      reply_type,
      Gio.DBusCallFlags.NO_AUTO_START,
      -1,
      nil,
      invoke_callback
    )
  end
  -------------------------------------------------------------------------------
  function backend.toggle()
    dbus_call("PlayPause")
  end

  function backend.next_song()
    dbus_call("Next")
  end

  function backend.prev_song()
    dbus_call("Previous")
  end

  -------------------------------------------------------------------------------
  function backend.update(parse_status_callback)
    dbus_call("GetAll", {
      callback=function(result)
        backend._post_update(result, parse_status_callback)
      end,
      dbus_path3 = "org.freedesktop.DBus.Properties",
      reply_type = GLib.VariantType.new("(a{sv})"),
      parameters = GLib.Variant('(s)', {"org.mpris.MediaPlayer2.Player"})
    })
  end

  -------------------------------------------------------------------------------
  function backend._post_update(result, parse_status_callback)
    if not result then
      parse_status_callback({})
      return
    end

    local result_string = result[1].PlaybackStatus
    local state = nil
    if result_string:match("Playing") then
      state  = 'play'
    elseif result_string:match("Paused") then
      state = 'pause'
    end
    backend.player_status.state = state
    if state == 'play' or state == 'pause' then
      backend.parse_metadata(result[1].Metadata, parse_status_callback)
    else
      parse_status_callback(backend.player_status)
    end
  end

  -------------------------------------------------------------------------------
  function backend.parse_metadata(result, parse_status_callback)
    --  todo:
    --[Variant: [Argument: a{sv} {
    --"bitrate" = [Variant(int): 979],
    --"mpris:length" = [Variant(qlonglong): 297000000],
    --"xesam:autoRating" = [Variant(int): 51],
    --"xesam:contentCreated" = [Variant(QString): "2016-12-08T23:31:33"],
    --"xesam:discNumber" = [Variant(int): 1],
    --"xesam:genre" = [Variant(QStringList): {"Metal"}],
    --"xesam:lastUsed" = [Variant(QString): "2018-12-06T14:59:30"],
    --"xesam:trackNumber" = [Variant(int): 3],
    --"xesam:useCount" = [Variant(int): 1],}]]
    --)
    local player_status = {
      state = backend.player_status.state,
      artist = result['xesam:artist'] and result['xesam:artist'][1],
      title = result['xesam:title'],
      album = result['xesam:album'],
      cover_url=result['mpris:artUrl'],
      file=result['xesam:url'],
      date=result['year'],
    }
    backend.player_status = player_status
    parse_status_callback(backend.player_status)
  end

  -------------------------------------------------------------------------------
  function backend.get_coverart(
    player_status, _, output_coverart_path, notification_callback
  )
    if player_status.cover_url and (
      player_status.cover_url ~= backend.player.last_cover_url
    ) then
      backend.player.last_cover_url = player_status.cover_url
      if g_string.startswith(player_status.cover_url, '/') or
        g_string.startswith(player_status.cover_url, 'file://')
      then
        if notification_callback then
          notification_callback()
        end
      else
        a_image.save_image_async(
          player_status.cover_url,
          output_coverart_path,
          notification_callback
        )
      end
    end
  end

  -------------------------------------------------------------------------------
  if seek then
    function backend.seek()
      dbus_call("Seek", {
        parameters = GLib.Variant('(x)', {seek*1000000})
      })
    end
  end

  -------------------------------------------------------------------------------
  return backend
end

return create
