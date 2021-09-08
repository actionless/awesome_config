local lgi = require("lgi")
local gio = lgi.Gio
local glib = lgi.GLib

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

return filesystem
