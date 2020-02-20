local awful = require("awful")
local beautiful = require("beautiful")
local delayed_call = require("gears.timer").delayed_call
local g_table = require("gears.table")
local ruled = require("ruled")

local titlebar	= require("actionless.titlebar")
local persistent = require("actionless.persistent")
local tag_helpers = require("actionless.util.tag")
local round_up_client_corners = require("actionless.client_border_shape").round_up_client_corners


local function clog(msg, c) -- luacheck: ignore
  --if c and c.class == 'mpv' then
  --  nlog({msg, c and c.name})
  --end
  --log(msg .. " " .. c.name .. " " .. tostring(c:tags()[1]))
  --if c and c.class == "Spotify" then nlog(msg) end
end


--=============================================================================
-- Unfocused (normal) window logic

local function _on_client_unfocus (c)
  if not c or not c.valid then return end
  if c.minimized then return end
  c.border_color = beautiful.border_normal
  local t = tag_helpers.get_client_tag(c)
  local layout = t.layout
  local num_tiled = #tag_helpers.get_tiled(t)
  if c.titlebars_enabled ==false then
    clog("F: tile: titlebars disabled explicitly", c)
    c.border_width = 0
    --titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
    titlebar.remove_border(c)
  elseif persistent.titlebar.get() and (
    num_tiled > 1 or (
      num_tiled > 0 and t.master_fill_policy ~= 'expand'
    )
  ) then
    clog("U: tile: titlebars enabled explicitly", c)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif c.maximized or c.fullscreen then
    clog("U: maximized", c)
    --set_default_screen_padding(s)
    c.border_width = 0
    titlebar.remove_border(c)
  elseif c.floating and c.class == 'mpv' then
    clog("U: floating mpv", c)
    titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif c.floating then
    clog("U: floating client", c)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif layout == awful.layout.suit.floating then
    clog("U: floating layout", c)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif num_tiled > 1 then
    clog("U: multiple tiling clients", c)
    titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
  elseif num_tiled == 1 then
    if t.master_fill_policy == 'expand' and screen.count() == 1 then
      clog("U: one tiling client: expand", c)
      titlebar.remove_border(c)
    else
      clog("U: one tiling client", c)
      titlebar.make_border(c, beautiful.actionless_titlebar_bg_normal, beautiful.titlebar_shadow_normal)
    end
  else
    nlog('Signals: U: How did that happened?')
    nlog(num_tiled)
  end
end

local function on_client_unfocus(c, force, callback)

  local function unfocus_sequence()
    _on_client_unfocus(c)
    if callback then
      callback(c)
    end
  end

  if force then
    unfocus_sequence()
    return
  end
  delayed_call(function()
    if not c.valid or c == client.focus then
      return
    end
    -- Actually draw changes only if client is visible:
    if c.sticky then
      unfocus_sequence()
      return
    end
    for _, sel_tag in ipairs(c.screen.selected_tags) do
      for _, cli_tag in ipairs(c:tags()) do
        if sel_tag.index == cli_tag.index then
          unfocus_sequence()
        end
      end
    end
  end)
end

--=============================================================================
-- Focused (active, selected) window logic

local function on_client_focus(c)
  if not c or not c.valid then return end
  local t = tag_helpers.get_client_tag(c)
  local layout = t.layout
  local num_tiled = #tag_helpers.get_tiled(t)

  c.border_color = beautiful.border_focus
  --

  if c.titlebars_enabled ==false then
    clog("F: tile: titlebars disabled explicitly", c)
    c.border_width = 0
    --titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    titlebar.remove_border(c)
  elseif persistent.titlebar.get() and (
    num_tiled > 1 or (
      num_tiled > 0 and t.master_fill_policy ~= 'expand'
    )
  ) then
    clog("F: tile: titlebars enabled explicitly", c)
    --choose_screen_padding(s, t, num_tiled)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif c.maximized or c.fullscreen then
    clog("F: maximized", c)
    --set_default_screen_padding(s)
    c.border_width = 0
    titlebar.remove_border(c)
  elseif c.floating and c.class == 'mpv' then
    clog("F: floating mpv", c)
    titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif c.floating then
    clog("F: floating client", c)
    --choose_screen_padding(s, t, num_tiled)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif layout == awful.layout.suit.floating then
    clog("F: floating layout", c)
    --choose_screen_padding(s, t, num_tiled)
    titlebar.make_titlebar(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif num_tiled > 1 then
    clog("F: multiple tiling clients", c)
    --set_default_screen_padding(s)
    c.border_width = beautiful.border_width
    titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
  elseif num_tiled == 1 then
    if t.master_fill_policy == 'expand' and screen.count() == 1 then
      clog("F: one tiling client: expand", c)
      --set_default_screen_padding(s)
      titlebar.remove_border(c)
    else
      clog("F: one tiling client", c)
      --set_mwfact_screen_padding(t)
      c.border_width = beautiful.border_width
      titlebar.make_border(c, beautiful.actionless_titlebar_bg_focus, beautiful.titlebar_shadow_focus)
    end
  else
    clog("F: zero tiling clients -- other tag?", c)
    return on_client_unfocus(c)
  end

  --c.border_color = beautiful.border_focus
end


--=============================================================================
-- Common signal handlers

local function on_client_signal(c, args)
  args = args or {}
  if c == client.focus and not args.unfocus_only then
    on_client_focus(c)
  else
    on_client_unfocus(c)
  end
end

local function on_tag_signal(t, args)
  for _, c in ipairs(t:clients()) do
    on_client_signal(c, args)
  end
end


--=============================================================================
-- INIT

local signals = {}
function signals.init(_)

  -- enable autofocus
  require("awful.autofocus")

  -- disable popups when hovering titlebar buttons
  awful.titlebar.enable_tooltip = false
  awful.titlebar.fallback_name = ''

  -- remove useless gaps for single expanded window
  awful.tag.object.get_gap = function(t)
    t = t or awful.screen.focused().selected_tag
    if not t then return end
    local num_tiled = #tag_helpers.get_tiled(t)
    if num_tiled == 1 and t.master_fill_policy == "expand" then
      return 0
    end
    return awful.tag.getproperty(t, "useless_gap") or beautiful.useless_gap or 0
  end

  -- SIGNALS

  -- Tag changed
  screen.connect_signal("tag::history::update", function (s)
    --if #s.selected_tags > 1 or s.selected_tags[1] and s.selected_tags[1].name == 'Revelation' then
      for _, t in ipairs(s.selected_tags) do
        on_tag_signal(t, {unfocus_only = true})
      end
    --end
  end)

  -- Tag property changed
  tag.connect_signal("property::layout", on_tag_signal)
  tag.connect_signal("property::master_fill_policy", on_tag_signal)
  tag.connect_signal("property::gap", on_tag_signal)

  -- New client appears
  client.disconnect_signal("request::manage", ruled.client.apply)
  client.connect_signal("request::manage", function(c)
      if awesome.startup then
          local rules = ruled.client.matching_rules(c, ruled.client.rules)
          for _,rule in ipairs(rules) do
              if rule.apply_on_restart then
                  ruled.client.execute(c, rule.properties, { rule.callback })
              else
                  local mini_properties = {}
                  for _, prop in ipairs({
                    "buttons",
                    "keys",
                    "size_hints_honor",
                    "raise",
                  }) do
                    if rule.properties[prop] ~= nil then
                      mini_properties[prop] = rule.properties[prop]
                    end
                  end
                if #(g_table.keys(mini_properties)) > 0 then
                  ruled.client.execute(c, mini_properties, { })
                end
              end
          end
      else
          ruled.client.apply(c)
      end
  --end)
  --client.connect_signal("manage", function (c)
    local awesome_startup = awesome.startup
    delayed_call(function()
        if c == client.focus then
          on_client_focus(c)
          if awesome_startup then
            round_up_client_corners(c, false, "MF")
          end
        else
          on_client_unfocus(c, true, function(_c)
            if awesome_startup then
              round_up_client_corners(_c, false, "MU")
            end
          end)
        end
    end)
  end)

  -- when clients dissapears let's update all tags where it was before:
  client.connect_signal("unmanage", function(c)
      for _, t in ipairs(c.screen.selected_tags) do
        on_tag_signal(t)
      end
  end)

  -- Other client callbacks:

  client.connect_signal("focus", function(c)
    return on_client_focus(c)
  end)

  client.connect_signal("unfocus", function(c)
    return on_client_unfocus(c)
  end)

  client.connect_signal("property::maximized", function (c)
    delayed_call(function()
      on_client_signal(c)
    end)
  end)

  client.connect_signal("property::fullscreen", function (c)
    delayed_call(function()
      on_client_signal(c)
    end)
  end)

  client.connect_signal("property::size", function (c)
    if not awesome.startup then
      round_up_client_corners(c, false, "S")
    end
  end)

  --client.connect_signal("request::titlebars", function(c)
    --titlebar.make_titlebar(c)
  --end)


end

return signals
