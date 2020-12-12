local awful_util = require("awful.util")
local gears_timer = require("gears.timer")

local pickle = require("actionless.util.pickle")


local db = {
  -- "public":
  auto_write_timeout = 60,
  filename = awful_util.getdir("config") .. "/config/config.db",
  --@TODO:
  --filename = awful_util.getdir("config") .. "/local.db",

  -- "private":
  _file_table = nil,
  _was_changed = false,
}

db._init = function()
  if not db._file_table then
    db._file_table = pickle.load(db.filename)
    if not db._file_table then
      db._file_table = {}
      db.write()
    end
    gears_timer({
      callback=db.write,
      timeout=db.auto_write_timeout,
      autostart=true,
      call_now=false,
    })
    awesome.connect_signal('exit', db.write)
  end
end

db.write = function()
  if db._was_changed then
    pickle.save(db._file_table, db.filename)
    db._was_changed = false
  end
end

db.get = function(key)
  db._init()
  return db._file_table[key]
end

db.set = function(key, value)
  db._init()
  db._file_table[key] = value
  db._was_changed = true
end

db.get_or_set = function(key, fallback_value)
  local value = db.get(key)
  if not value then
    value = fallback_value
    db.set(key, value)
  end
  return value
end

db.update_child = function(key, child_key, child_value)
  local value = db.get(key)
  value[child_key] = child_value
  db.set(key, value)
end

return db
