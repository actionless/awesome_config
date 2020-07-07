-- https://github.com/awesomeWM/awesome/issues/2599#issuecomment-455847701

local protected_call = require("gears.protected_call")
local lgi = require("lgi")
--local GLib = lgi.GLib
local Gio = lgi.Gio
local cairo = lgi.cairo
local GdkPixbuf = lgi.GdkPixbuf

local h_table = require("actionless.util.table")


local CACHE_SIZE = 128
local cache = {}

local module = {}

local function do_async_load_image(uri, callback)
    log("loading url: "..uri)
    local input, err = Gio.File.new_for_uri(uri):async_read()
    if err then
        callback(nil, tostring(err))
        return
    end
    log("loading pixbuf: "..uri)
    local pixbuf, err2 = GdkPixbuf.Pixbuf.async_new_from_stream(input)
    if err2 then
        callback(nil, tostring(err))
        return
    end

    local surface = cairo.Surface(awesome.pixbuf_to_surface(pixbuf._native), true)
    log("loading surface: "..uri)
    callback(surface)
end
function module.async_load_image(uri, callback)
    Gio.Async.start(protected_call.call)(do_async_load_image, uri, callback)
end

-- All of the above is intended to be just copied 1:1 to your config. The below
-- is to be replaced with your own code. Note that this requires at least
-- awesome v4.2-236-gc5badcbe3, because this uses awesome.pixbuf_to_surface.

local function create_save_callback(filepath)
  local function my_callback(surface, err)
      if err then
          log("Error occurred: " .. err)
      end
      if surface then
          surface:write_to_png(filepath)
          log("saved "..filepath)
      end
  end
  return my_callback
end


function module.save_image_async(url, filepath, callback)
  log('gonna '..url..' as '..filepath)
  if cache[url] then
    log('cached '..url..' as '..filepath)
    local cache_keys = h_table.keys(cache)
    if #cache_keys > CACHE_SIZE then
      cache[cache_keys[cache_keys[1] ~= url and 1 or 2]] = nil
    end
    local surface = cache[url]
    create_save_callback(filepath)(surface, nil)
    if callback then
      return callback(surface, nil)
    end
  end
  module.async_load_image(
    url,
    function(surface, err)
      log('savin '..url..' as '..filepath)
      create_save_callback(filepath)(surface, err)
      cache[url] = surface
      if callback then
        callback(surface, err)
      end
    end
  )
end


return module
