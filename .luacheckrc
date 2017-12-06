-- Only allow symbols available in all Lua versions
std = "min"

-- Get rid of "unused argument self"-warnings
self = false

-- The unit tests can use busted
files["spec"].std = "+busted"

-- The default config may set global variables
files["awesomerc.lua"].allow_defined_top = true

-- Global objects defined by the C code
read_globals = {
    "awesome",
    "button",
    "dbus",
    "drawable",
    "drawin",
    "key",
    "keygrabber",
    "mousegrabber",
    "root",
    "selection",
    "tag",
    "window",
    "table.unpack",
    "unpack",
    "math.atan2",
    "jit",
}

-- May not be read-only due to client.focus
globals = {
    "screen",
    "mouse",
    "client",
    "nlog",
    "log",
    "context",
}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
