local beautiful = require("beautiful")
local awful = require("awful")
awful.rules = require("awful.rules")

local settings = require("actionless.settings")


local rules = {}

function rules.init(status)
-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus = awful.client.focus.filter,
                   raise = true,
                   keys = status.clientkeys,
                   buttons = status.clientbuttons,
                   size_hints_honor = false},
  callback = awful.client.setslave },

  { rule = { class = "MPlayer" },
    properties = { floating=true } },
  { rule = { class = "Chromium" },
    properties = { tag=status.tags[1][2], raise=false } },
  { rule = { class = "Skype" },
    properties = { tag=status.tags[1][4], raise=false } },

}
-- }}}

for class in pairs(settings.gtk3_app_classes) do
  local rule = { rule = {class = class}, properties = {border_width=0}}
  table.insert(awful.rules.rules, rule)
end

end
return rules
