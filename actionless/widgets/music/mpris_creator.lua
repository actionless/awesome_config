--[[
  Licensed under GNU General Public License v2
   * (c) 2020, Yauheni Kirylau
--]]

local dbus = dbus -- luacheck: ignore
local Gio = require("lgi").Gio
local GLib = require("lgi").GLib
local g_string		= require("gears.string")
local g_timer = require("gears.timer")

local a_image = require("actionless.util.async_web_image")
local a_table = require("actionless.util.table")

local DEBUG_LOG = false
--local DEBUG_LOG = true
local function _log(...)
  if DEBUG_LOG then
    log(...)
  end
end

log("::MPRIS-CREATOR: Initializing DBus connection...")
local dbus_connection = assert(Gio.bus_get_sync(Gio.BusType.SESSION))
local default_parameters = GLib.Variant('()', {})
local default_reply_type = GLib.VariantType.new("()")

local function find_service_names(match, callback)
  --
  -- qdbus org.freedesktop.DBus /org/freedesktop/DBus GetAll org.freedesktop.DBus
  -- qdbus org.freedesktop.DBus /org/freedesktop/DBus Introspect
  -- qdbus org.freedesktop.DBus / ListNames
  --
  _log("DBUS-SHIT: gonna list names...")
  dbus_connection:call(
    "org.freedesktop.DBus",
    "/",
    "org.freedesktop.DBus",
    "ListNames",
    default_parameters,
    GLib.VariantType.new("(as)"),
    Gio.DBusCallFlags.NO_AUTO_START,
    -1,
    nil,
    function(conn, result)
      local call_result = conn:call_finish(result)
      local values
      if call_result then
        values = call_result.value
      end
      _log("DBUS-SHIT: got names")
      local names_found = {}
      for _, service_name in values[1]:ipairs() do
        if service_name:match(match) then
          table.insert(names_found, service_name)
        end
      end
      callback(names_found)
    end
  )
end

local function create(name, args)
  args = args or {}
  local cmd = args.cmd or name
  local seek = args.seek or false

  local bus_name = "org.mpris.MediaPlayer2."..name
  local object_path = "/org/mpris/MediaPlayer2"
  local default_interface_name = "org.mpris.MediaPlayer2.Player"

  local backend = {
    player_status = {},
    player_cmd = cmd,
  }

  function backend.init(widget)
    backend.player = widget
  end
  -------------------------------------------------------------------------------
  local function dbus_call(method_name, dbus_args)
    dbus_args = dbus_args or {}
    local callback = dbus_args.callback
    local parameters = dbus_args.parameters or default_parameters
    local reply_type = dbus_args.reply_type or default_reply_type
    local interface_name = dbus_args.interface_name or default_interface_name

    --_log("DBUS-SHIT: calling "..method_name.." on "..name.."...")

    local function invoke_callback(conn, result)
        local call_result = conn:call_finish(result)
        local values
        if call_result then
          values = call_result.value
        end
        --_log("DBUS-SHIT: "..method_name.." on "..name.." returned: " .. (values and 'values' or 'nil'))
        if callback then
            callback(values)
        end
    end

    dbus_connection:call(
      bus_name,
      object_path,
      interface_name,
      method_name,
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
      interface_name = "org.freedesktop.DBus.Properties",
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
    elseif result_string:match("Stopped") then
      state = 'stop'
    end
    backend.player_status.state = state
    if state == 'play' or state == 'pause' or state == 'stop' then
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
    for k, v in pairs(player_status) do
      if v == "" then
        player_status[k] = nil
      end
    end
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

local TIMEOUT = 10
local function create_for_match(match, args)

  local player
  local tmp_result = {
    init = function(_p) player=_p end,
    update = function() end,
  }

  local last_instance_id
  local _worker
  function _worker()
    find_service_names(match, function(names)
      if #names == 0 then
        _log("::MPRIS-CREATOR: Service '"..match.."' not found")
        _log("::MPRIS-CREATOR: Retrying in "..tostring(TIMEOUT).." seconds")
      else
        --for _, name in ipairs(names) do
        local name = names[#names]
          local postfix = table.concat(a_table.range(g_string.split(name, '.'), 4), '.')
          if postfix == last_instance_id then
            _log("::MPRIS-CREATOR: backend for "..match.." already exists")
          else
            last_instance_id = postfix
            _log("::MPRIS-CREATOR: Creating MPRIS backend for "..name)
            local backend = create(postfix, args)
            for k, v in pairs(backend) do
              tmp_result[k] = v
            end
            tmp_result.init(player)
            if player then
              player.update()
            end
          end
        --end
      end
    end)
  end

  g_timer{
    callback=function()
      if not player or (player.backend == tmp_result) then
        _worker()
      end
    end,
    timeout=TIMEOUT,
    autostart=true,
    call_now=true,
  }

  return tmp_result
end

return setmetatable({create_for_match=create_for_match}, {__call=function(_, ...)return create(...)end})
