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

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

function persistent.layout.get_all_ids(screen, fallback)
  return db.get_or_set("tag_layout_ids_"..screen.index, fallback)
end

function persistent.layout.set(layout, tag, screen, tag_id)
  --@TODO: change on layout signal
  tag, screen, tag_id = get_tag_and_screen(tag, screen, tag_id)
  awful.layout.set(layout, tag)
  db.update_child(
    "tag_layout_ids_"..screen,
    tag_id,
    helpers.layout_get_id(layout)
  )
end

-------------------------------------------------------------------------------
-- Titlebar
-------------------------------------------------------------------------------

function persistent.titlebar.set(enabled)
  db.set("titlebars_enabled", enabled)
end

function persistent.titlebar.get()
  return db.get_or_set("titlebars_enabled", false)
end

-------------------------------------------------------------------------------
-- Lcarslist
-------------------------------------------------------------------------------

function persistent.lcarslist.set(enabled)
  db.set("lcarslist_enabled", enabled)
end

function persistent.lcarslist.get()
  return db.get_or_set("lcarslist_enabled", false)
end

-------------------------------------------------------------------------------
-- Tag
-------------------------------------------------------------------------------

function persistent.tag.get_all_names(screen, fallback)
  return db.get_or_set("tag_names_"..screen.index, fallback)
end

function persistent.tag.get_all_mwfact(screen, fallback)
  return db.get_or_set("tag_mwfact_"..screen.index, fallback)
end

function persistent.tag.get_all_mfpol(screen, fallback)
  return db.get_or_set("tag_mfpol_"..screen.index, fallback)
end

function persistent.tag._connect_signal(signal_name, tag_callback)
  tag.connect_signal(signal_name, function(t)
    if not awesome.startup then
      tag_callback(t)
    end
  end)
end

function persistent.tag.master_width_factor_save(_t)
  local t, screen_id, tag_id = get_tag_and_screen(_t, nil, nil)
  local db_id = "tag_mwfact_"..screen_id
  local current_mwfacts = db.get(db_id)
  current_mwfacts[tag_id] = t.master_width_factor
  db.set(db_id, current_mwfacts)
end
persistent.tag._connect_signal(
  "property::master_width_factor",
  persistent.tag.master_width_factor_save
)

function persistent.tag.master_fill_policy_save(_t)
  local t, screen_id, tag_id = get_tag_and_screen(_t, nil, nil)
  local db_id = "tag_mfpol_"..screen_id
  local layout_expand_masters = db.get(db_id)
  layout_expand_masters[tag_id] = t.master_fill_policy
  db.set(db_id, layout_expand_masters)
end
persistent.tag._connect_signal(
  "property::master_fill_policy",
  persistent.tag.master_fill_policy_save
)

function persistent.tag.name_save(_t)
  local t, s, tag_id = get_tag_and_screen(_t)
  db.update_child(
    "tag_names_"..s,
    tag_id,
    t.name
  )
end
persistent.tag._connect_signal(
  "property::name",
  persistent.tag.name_save
)


return persistent
