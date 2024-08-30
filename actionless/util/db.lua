local awful_util = require("awful.util")
local gears_timer = require("gears.timer")

local pickle = require("actionless.util.pickle")
local log = require("actionless.util.debug").log


local db_module = {
  dbs = {}
}

function db_module.db(filename)

  filename = filename or awful_util.getdir("config") .. "/config/config.db"

  if db_module.dbs[filename] then
    return db_module.dbs[filename]
  end

  local db = {
    -- "public":
    auto_write_timeout = 60,
    filename = filename,
    --@TODO:
    --filename = awful_util.getdir("config") .. "/local.db",

    -- "private":
    _file_table = nil,
    _was_changed = false,
  }

  db._init = function()
    if not db._file_table then
      log("DB: init...")
      db._file_table = pickle.load(db.filename)
      if not db._file_table then
        log("DB: no data found, creating new one...")
        db._file_table = {}
        db.write()
      end
      gears_timer({
        callback=function() db.write() end,
        timeout=db.auto_write_timeout,
        autostart=true,
        call_now=false,
      })
      awesome.connect_signal('exit', db.write_sync)
    end
  end

  db.write_sync = function()
    if db._was_changed then
      pickle.save_sync(db._file_table, db.filename)
      db._was_changed = false
    end
  end

  db.write = function(callback)
    if not db._was_changed then
      if callback then
        callback()
      end
    else
      pickle.save(db._file_table, db.filename, function()
        db._was_changed = false
        if callback then
          callback()
        end
      end)
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
    if value == nil then
      log("DB: no value found for ".. key .. " - using fallback")
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

  db_module.dbs[filename] = db
  return db

end

function db_module.set(...)
  local db = db_module.db()
  return db.set(...)
end
function db_module.get(...)
  local db = db_module.db()
  return db.get(...)
end
function db_module.get_or_set(...)
  local db = db_module.db()
  return db.get_or_set(...)
end
function db_module.update_child(...)
  local db = db_module.db()
  return db.update_child(...)
end

return db_module
