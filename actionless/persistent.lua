local awful = require("awful")

local db = require("utils.db")

local helpers = require("actionless.helpers")

local persistent = {
  layout = {},
  tag = {},
  titlebar = {},
  lcarslist = {},
}

local function get_tag_and_screen(tag, screen, tag_id)
  if tag then
    screen = screen or tag.screen
  else
    screen = screen or awful.screen.focused()
    tag = screen.selected_tag
  end
  tag_id = tag_id or tag.index
  return tag, screen.index, tag_id
end


function persistent.layout.get_all_ids(screen, fallback)
  return db.get_or_set("tag_layout_ids_"..screen.index, fallback)
end

function persistent.layout.set(layout, tag, screen, tag_id)
  tag, screen, tag_id = get_tag_and_screen(tag, screen, tag_id)
  awful.layout.set(layout, tag)
  db.update_child(
    "tag_layout_ids_"..screen,
    tag_id,
    helpers.layout_get_id(layout)
  )
end

function persistent.tag.get_all_names(screen, fallback)
  return db.get_or_set("tag_names_"..screen.index, fallback)
end

function persistent.tag.rename(new_name, tag, screen, tag_id)
  tag, screen, tag_id = get_tag_and_screen(tag, screen, tag_id)
  tag.name = new_name
  db.update_child(
    "tag_names_"..screen,
    tag_id,
    new_name
  )
end

function persistent.tag.get_all_mwfact(screen, fallback)
  return db.get_or_set("tag_mwfact_"..screen.index, fallback)
end

function persistent.tag.incmwfact(add, tag, screen, tag_id)
  tag, screen, tag_id = get_tag_and_screen(tag, screen, tag_id)
  awful.tag.incmwfact(add, tag)
  local db_id = "tag_mwfact_"..screen
  local current_mwfacts = db.get(db_id)
  current_mwfacts[tag_id] = current_mwfacts[tag_id] + add
  db.set(db_id, current_mwfacts)
end

function persistent.tag.get_all_mfpol(screen, fallback)
  return db.get_or_set("tag_mfpol_"..screen.index, fallback)
end

function persistent.tag.togglemfpol(tag, screen, tag_id)
  tag, screen, tag_id = get_tag_and_screen(tag, screen, tag_id)
  awful.tag.togglemfpol(tag)
  tag:emit_signal("property::layout")
  local db_id = "tag_mfpol_"..screen
  local layout_expand_masters = db.get(db_id)
  if layout_expand_masters[tag_id] == "expand" then
    layout_expand_masters[tag_id] = "master_width_factor"
  else
    layout_expand_masters[tag_id] = "expand"
  end
  db.set(db_id, layout_expand_masters)
end


function persistent.titlebar.set(enabled)
  db.set("titlebars_enabled", enabled)
end

function persistent.titlebar.get()
  return db.get_or_set("titlebars_enabled", false)
end


function persistent.lcarslist.set(enabled)
  db.set("lcarslist_enabled", enabled)
end

function persistent.lcarslist.get()
  return db.get_or_set("lcarslist_enabled", false)
end


return persistent
