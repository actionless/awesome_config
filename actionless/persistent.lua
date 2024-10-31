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
  tag.connect_signal(signal_name, function(t2)
    if not awesome.startup then
      local t, screen_id, tag_id = get_tag_and_screen(t2)
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

function persistent.tag.get_all_uselessgaps(s, fallback)
  return db.get_or_set("tag_usellessgaps_"..s.index, fallback)
end

function persistent.tag.get_all_mastercounts(s, fallback)
  return db.get_or_set("tag_mastercounts_"..s.index, fallback)
end

function persistent.tag.get_all_columncounts(s, fallback)
  return db.get_or_set("tag_columncounts_"..s.index, fallback)
end


--Tag params setters and signals:

function persistent.tag.master_width_factor_save(t, screen_id, tag_id)
  local db_id = "tag_mwfact_"..screen_id
  local current_mwfacts = db.get(db_id)
  current_mwfacts[tag_id] = t.master_width_factor
  db.set(db_id, current_mwfacts)
end

function persistent.tag.master_fill_policy_save(t, screen_id, tag_id)
  local db_id = "tag_mfpol_"..screen_id
  local layout_expand_masters = db.get(db_id)
  layout_expand_masters[tag_id] = t.master_fill_policy
  db.set(db_id, layout_expand_masters)
end

function persistent.tag.name_save(t, screen_id, tag_id)
  db.update_child(
    "tag_names_"..screen_id,
    tag_id,
    t.name
  )
end

function persistent.tag.layout_save(t, screen_id, tag_id)
  db.update_child(
    "tag_layout_ids_"..screen_id,
    tag_id,
    get_layout_id(t.layout)
  )
end

function persistent.tag.uselessgaps_save(t, screen_id, tag_id)
  local db_id = "tag_usellessgaps_"..screen_id
  local uselessgaps = db.get(db_id)
  uselessgaps[tag_id] = t.gap
  db.set(db_id, uselessgaps)
end

function persistent.tag.mastercount_save(t, screen_id, tag_id)
  db.update_child(
    "tag_mastercounts_"..screen_id,
    tag_id,
    t.master_count
  )
end

function persistent.tag.columncount_save(t, screen_id, tag_id)
  db.update_child(
    "tag_columncounts_"..screen_id,
    tag_id,
    t.column_count
  )
end


-- Init signals:

function persistent.init_tag_signals()
  persistent.tag._connect_signal(
    "property::master_width_factor",
    persistent.tag.master_width_factor_save
  )
  persistent.tag._connect_signal(
    "property::master_fill_policy",
    persistent.tag.master_fill_policy_save
  )
  persistent.tag._connect_signal(
    "property::name",
    persistent.tag.name_save
  )
  persistent.tag._connect_signal(
    "property::layout",
    persistent.tag.layout_save
  )
  persistent.tag._connect_signal(
    -- @TODO: see https://github.com/awesomeWM/awesome/issues/3692
    "property::useless_gap",
    persistent.tag.uselessgaps_save
  )
  persistent.tag._connect_signal(
    "property::master_count",
    persistent.tag.mastercount_save
  )
  persistent.tag._connect_signal(
    "property::column_count",
    persistent.tag.columncount_save
  )
end

return persistent
