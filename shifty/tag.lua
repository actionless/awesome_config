local tag = {}

local name                 -- Name of the tag
local layout               -- a layout from awful.layout.suit (e.g. awful.layout.suit.tile)
local mwfact               -- how big the master window is
local nmaster              -- how many columns for master windows
local ncol                 -- how many columns for non-master windows
local exclusive            -- if true, only clients from rules (config.apps) allowed in this tag
local persist              -- persist after no apps are in it
local nopopup              -- do not focus on creation
local leave_kills          -- if true, tag won't be deleted until unselected
local position             -- determines position in taglist (then what does index do?)
local icon                 -- image file for icon
local icon_only            -- if true, no text (just icon)
local init                 -- if true, create on startup (implies persist)
local sweep_delay          -- ???
local keys = {}            -- a table of keys, which are associated with the tag
local overload_keys = {}   -- ???
local index                -- Index on the taglist, if nil, position is used
local rel_index            -- ???
local run                  -- a lua function which is execute on tag creation
local spawn                -- shell command which is execute on tag creation (ex. a programm)
local screen               -- which screen to spawn on (see above)
local max_clients          -- if more than this many clients are started, then a new tag is made

function tag.setName(value)
  name = value
end

function tag.getName()
  return name
end

function tag.setLayout(value)
  layout = value
end

function tag.getLayout()
  return layout
end

function tag.setMwfact(value)
  mwfact = value
end

function tag.getMwfact()
  return mwfact
end

function tag.setNmaster(value)
  nmaster = value
end

function tag.getNmaster()
  return nmaster
end

function tag.setNcol(value)
  ncol = value
end

function tag.getNcol()
  return ncol
end

function tag.setExclusive(value)
  exclusive = value
end

function tag.getExclusive()
  return exclusive
end

function tag.setPersist(value)
  persist = value
end

function tag.getPersist()
  return persist
end

function tag.setNopopup(value)
  nopopup = value
end

function tag.getNopopup()
  return nopopup
end

function tag.setLeaveKills(value)
  leave_kills = value
end

function tag.getLeaveKills()
  return leave_kills
end

function tag.setPosition(value)
  position = value
end

function tag.getPosition()
  return position
end

function tag.setIcon(value)
  icon = value
end

function tag.getIcon()
  return icon
end

function tag.setIconOnly(value)
  icon_only = value
end

function tag.getIconOnly()
  return icon_only
end

function tag.setInit(value)
  init = value
end

function tag.getInit()
  return init
end

function tag.setSweepDelay(value)
  sweep_delay = value
end

function tag.getSweepDelay()
  return sweep_delay
end

function tag.setKeys(value)
  keys = value
end

function tag.getKeys()
  return keys
end

function tag.setOverloadKeys(value)
  overload_keys = value
end

function tag.getOverloadKeys()
  return overload_keys
end

function tag.setIndex(value)
  index = value
end

function tag.getIndex()
  return index
end

function tag.setRelIndex(value)
  rel_index = value
end

function tag.getRelIndex()
  return rel_index
end

function tag.setSpawn(value)
  spawn = value
end

function tag.getSpawn()
  return spawn
end

function tag.setScreen(value)
  screen = value
end

function tag.getScreen()
  return screen
end

function tag.setMaxClients(value)
  max_clients = value
end

function tag.getMaxClients()
  return max_clients
end

return tag={}
