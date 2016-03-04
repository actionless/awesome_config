local awful_util = require("awful.util")
local pickle = require("utils.pickle")
local helpers = require("actionless.helpers")


local db = {
  file_table = nil,
  was_changed = false
}

db.filename = awful_util.getdir("config") .. "/config/config.db"

db.init = function()
  if not db.file_table then
    db.file_table = pickle.load(db.filename)
    if not db.file_table then
      db.file_table = {}
      db.write()
    end
    helpers.newinterval(60, db.write)
    awesome.connect_signal('exit', db.write)
  end
end

db.write = function()
  if db.was_changed then
    pickle.save(db.file_table, db.filename)
    db.was_changed = false
  end
end

db.get = function(key)
  db.init()
  return db.file_table[key]
end

db.set = function(key, value)
  db.init()
  db.file_table[key] = value
  db.was_changed = true
end

db.get_or_set = function(key, fallback_value)
    local value = db.get(key)
    if not value then 
      value = fallback_value
      db.set(key, value)
    end
    return value
end

function db.update_child(key, child_key, child_value)
  local value = db.get(key)
  value[child_key] = child_value
  db.set(key, value)
end

return db
