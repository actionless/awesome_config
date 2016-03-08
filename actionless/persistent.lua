local awful = require("awful")

local db = require("utils.db")

local helpers = require("actionless.helpers")

local persistent = {
  layout = {},
  tag = {},
  titlebar = {},
}

function persistent.layout.set(layout, tag, screen)
  if tag then
    screen = screen or awful.tag.getscreen(tag)
  else
    screen = screen or awful.screen.focused()
    tag = awful.tag.selected(screen)
  end
  awful.layout.set(layout, tag)
  db.update_child(
    "tag_layout_ids_"..screen,
    awful.tag.getidx(tag),
    helpers.layout_get_id(layout)
  )
end

function persistent.titlebar.set(enabled)
  db.set("enable_titlebars", enabled)
end

function persistent.titlebar.get()
  return db.get_or_set("enable_titlebars", false)
end

return persistent
