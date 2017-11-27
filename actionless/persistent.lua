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
  return tag, (screen and screen.index), tag_id
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

function persistent.tag.get_all_layouts(screen, fallback)
  return db.get_or_set("tag_layout_ids_"..screen.index, fallback)
end


function persistent.tag._connect_signal(signal_name, tag_callback)
  tag.connect_signal(signal_name, function(_t)
    if not awesome.startup then
      local t, screen_id, tag_id = get_tag_and_screen(_t)
      if t and screen_id and tag_id then
          tag_callback(t, screen_id, tag_id)
      end
    end
  end)
end

function persistent.tag.master_width_factor_save(t, screen_id, tag_id)
  local db_id = "tag_mwfact_"..screen_id
  local current_mwfacts = db.get(db_id)
  current_mwfacts[tag_id] = t.master_width_factor
  db.set(db_id, current_mwfacts)
end
persistent.tag._connect_signal(
  "property::master_width_factor",
  persistent.tag.master_width_factor_save
)

function persistent.tag.master_fill_policy_save(t, screen_id, tag_id)
  local db_id = "tag_mfpol_"..screen_id
  local layout_expand_masters = db.get(db_id)
  layout_expand_masters[tag_id] = t.master_fill_policy
  db.set(db_id, layout_expand_masters)
end
persistent.tag._connect_signal(
  "property::master_fill_policy",
  persistent.tag.master_fill_policy_save
)

function persistent.tag.name_save(t, screen_id, tag_id)
  db.update_child(
    "tag_names_"..screen_id,
    tag_id,
    t.name
  )
end
persistent.tag._connect_signal(
  "property::name",
  persistent.tag.name_save
)

function persistent.tag.layout_save(t, screen_id, tag_id)
  local layout = t.layout
  db.update_child(
    "tag_layout_ids_"..screen_id,
    tag_id,
    helpers.layout_get_id(layout)
  )
end
persistent.tag._connect_signal(
  "property::layout",
  persistent.tag.layout_save
)

return persistent
