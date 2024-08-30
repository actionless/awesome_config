local lgi = require("lgi")
local gio = lgi.Gio
local glib = lgi.GLib

local log = require("actionless.util.debug").get_decorated_logger('UTIL.FILESYSTEM')
local gstring = require('gears.string')


local filesystem = {}

function filesystem.is_readable(gio_file, callback)
  gio_file:query_info_async(
    "standard::type,access::can-read",
    gio.FileQueryInfoFlags.NONE, glib.PRIORITY_DEFAULT,
    nil,
    function(_, gfileinfo_result)
      local gfileinfo = gio_file:query_info_finish(gfileinfo_result)
      if (
        gfileinfo and gfileinfo:get_file_type() ~= "DIRECTORY" and
        gfileinfo:get_attribute_boolean("access::can-read")
      ) then
        callback(true)
      else
        callback(false)
      end
  end, nil)
end

function filesystem.read_file(file_name, callback)
  local gfile = gio.File.new_for_path(file_name)
  filesystem.is_readable(gfile, function(is_readable)
    if not is_readable then
      log("file '"..file_name.."' is not found or not readable...")
      callback(nil)
    else
      gfile:load_contents_async(nil, function(_, contents_result)
        local result = gfile:load_contents_finish(contents_result)
        callback(result)
      end, nil)
    end
  end)
end

function filesystem.write_file(file_name, text, callback, is_retry)
    log("writing to file...")
    local gfile = gio.File.new_for_path(file_name)
    filesystem.is_readable(gfile, function(is_readable)

      if not is_readable then
        if is_retry then
          log("failed creating file "..file_name)
          if callback then
            callback(false)
          end
        end
        log("creating file...")
        gfile:create_readwrite_async(gio.FileCreateFlags.NONE, glib.PRIORITY_DEFAULT, nil, function(_, create_result)
          log{
            "file created",
            gfile:create_readwrite_finish(create_result)
          }
          filesystem.write_file(file_name, text, callback, true)
        end, nil) -- create_readwrite end

      else
        gfile:open_readwrite_async(glib.PRIORITY_DEFAULT, nil, function(_, io_stream_result)
          local io_stream = gfile:open_readwrite_finish(io_stream_result)
          io_stream:seek(0, glib.SeekType.SET, nil)
          local file = io_stream:get_output_stream()
          file:write_all_async(text, glib.PRIORITY_DEFAULT, nil, function(_, write_result)
            local length_written = file:write_all_finish(write_result)
            log{
              "file written",
              length_written
            }
            file:truncate(length_written, nil)
            file:close_async(glib.PRIORITY_DEFAULT, nil, function(_, file_close_result)
              log{
                "output stream closed",
                file:close_finish(file_close_result)
              }
              io_stream:close_async(glib.PRIORITY_DEFAULT, nil, function(_, stream_close_result)
                log{
                  "file stream closed",
                  io_stream:close_finish(stream_close_result)
                }
                if callback then
                  callback(true)
                end
              end, nil) -- io_stream:close end
            end, nil) -- file:close end
          end, nil) -- file:write end
        end, nil) -- open_readwrite end

      end
    end)  -- is_readable - end
end

function filesystem.get_username()
  local homedir = os.getenv("HOME")
  local parts = gstring.split(homedir, "/")
  return parts[#parts]
end

return filesystem
