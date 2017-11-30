local awful = require("awful")

local db = require("actionless.util.db")


local persistent = {
  layout = {},
  tag = {},
  titlebar = {},
  lcarslist = {},
}

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

--Tag helpers:
--

local function get_layout_id(layout)
  local layout_name = awful.layout.getname(layout)
  for layout_id, layout2 in ipairs(awful.layout.layouts) do
    if layout_name == awful.layout.getname(layout2) then
      return layout_id
    end
  end
end


local function get_tag_and_screen(t, s, tag_id)
  if t then
    s = s or t.screen
  else
    s = s or awful.screen.focused()
    t = s.selected_tag
  end
  tag_id = tag_id or t.index
  return t, (s and s.index), tag_id
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

--Tag params getters:

function persistent.tag.get_all_names(s, fallback)
  return db.get_or_set("tag_names_"..s.index, fallback)
end

function persistent.tag.get_all_mwfact(s, fallback)
  return db.get_or_set("tag_mwfact_"..s.index, fallback)
end

function persistent.tag.get_all_mfpol(s, fallback)
  return db.get_or_set("tag_mfpol_"..s.index, fallback)
end

function persistent.tag.get_all_layouts(s, fallback)
  return db.get_or_set("tag_layout_ids_"..s.index, fallback)
end

--Tag params setters and signals:

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
  db.update_child(
    "tag_layout_ids_"..screen_id,
    tag_id,
    get_layout_id(t.layout)
  )
end
persistent.tag._connect_signal(
  "property::layout",
  persistent.tag.layout_save
)

return persistent
