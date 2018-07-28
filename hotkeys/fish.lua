---------------------------------------------------------------------------
--- VIM hotkeys for awful.hotkeys_widget
--
-- @author Yauheni Kirylau &lt;yawghen@gmail.com&gt;
-- @copyright 2014-2015 Yauheni Kirylau
-- @release v3.5.2-1236-g984b0a3
-- @module awful.hotkeys_popup.keys.vim
---------------------------------------------------------------------------

local hotkeys_popup = require("awful.hotkeys_popup.widget")

local fish_rule_any = {name={"fish", "st "}}
for group_name, group_data in pairs({
    ["Fish"] =             { color="#5f6d93", rule_any=fish_rule_any },
}) do
    hotkeys_popup.add_group_rules(group_name, group_data)
end


local vim_keys = {

    ["Fish"] = {{
        modifiers = {},
        keys = {
            Next="history begin",
            Prior="history end",
        }
    }, {
        modifiers = {"Ctrl"},
        keys = {
            a="BOL",
            e="EOL",
            b="one char back",
            f="one char forward",
            c="cancel",
            d="delete/exit",
            k="kill from cursor to EOL",
            u="kill from BOL to cursor",
            l="clear screen",
            w="kill prev word",
            y="yank from killring",
            p="history prev",
            n="history next",
            t="transpose char with prev",
        }
    }, {
        modifiers = {"Alt"},
        keys = {
            Left="directory/one word back",
            Right="directory/one word forward",
            b="one word back",
            f="one word forward",
            d="kill next word",
            w="print short help",
            l="ls",
            p="| less;",
            c="capitalize",
            u="uppercase",
            h="show man",
            Enter="\\n",
            y="yank pop",
            t="transpose word with prev",
            ["."]="search token in history",

        }
    }, {
        modifiers = {"Alt", "Shift"},
        keys = {
            [","]="beginning of buffer",
            ["."]="end of buffer",
        },
    }},
}

hotkeys_popup.add_hotkeys(vim_keys)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
