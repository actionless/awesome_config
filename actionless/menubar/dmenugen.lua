---------------------------------------------------------------------------
--- Menu generation module for menubar
--
-- @author Antonio Terceiro
-- @copyright 2009, 2011-2012 Antonio Terceiro, Alexander Yakushev
-- @release v3.5.2-602-g4996334
-- @module menubar.menu_gen
---------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local h_table = require("actionless.util.table")


-----
-- move this one to awful.util.table ?
----------
local function ReversedTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

local function DedupTable(t)  -- @TODO: unused anymore
    local dedupedTable = {}
    for _, v in ipairs(t) do
        if awful.util.table.hasitem(dedupedTable, v) == nil then
            table.insert(dedupedTable, v)
        end
    end
    return dedupedTable
end

local function DedupTableValues(t)
    local dedupedTable = {}
    local dedupedTableValues = {}
    for _, v in pairs(t) do
        if dedupedTableValues[v] == nil then
            dedupedTableValues[v] = true
            table.insert(dedupedTable, v)
        end
    end
    return dedupedTable
end

local function SortedDedupTable(t)
    local items_count = {}
    for _, v in ipairs(t) do
        items_count[v] = (items_count[v] or 0) + 1
    end

    local quantities = DedupTableValues(items_count)
    table.sort(quantities, function(a, b) return a > b end)

    local result = {}
    local unique_values = {}
    for _, i in ipairs(quantities) do
        for _, v in ipairs(t) do
            if items_count[v] == i and unique_values[v] == nil then
                unique_values[v] = true
                table.insert(result, v)
            end
        end
    end
    return result
end


local menu_gen = {}

--- Specify the mapping of .desktop Categories section to the
-- categories in the menubar. If "use" flag is set to false then any of
-- the applications that fall only to this category will not be shown.
menu_gen.all_categories = { }

--@TODO: merge this func with awful.prompt------------------------------------
--
--- Private data
local history_file_path = awful.util.getdir("cache") .. "/history_dmenu"
local data = {}
data.history = {}
function menu_gen.add_history_record(record, id)
    id = id or history_file_path
    table.insert(data.history[id]['table'], record)
end
function menu_gen.remove_history_record(record, id)
    id = id or history_file_path
    local keys_to_remove = {}
    for i, cmd in ipairs(data.history[id]['table']) do
        if cmd == record then
            table.insert(keys_to_remove, i)
        end
    end
    for _, key in ipairs(ReversedTable(keys_to_remove)) do
        table.remove(data.history[id]['table'], key)
    end
end
--- Load history file in history table
-- @param id The data.history identifier which is the path to the filename.
-- @param[opt] max The maximum number of entries in file.
function menu_gen.history_check_load(id, max)
    id = id or history_file_path
    if id and id ~= ""
        and not data.history[id] then
        data.history[id] = { max = max or 50, table = {} }

        local f = io.open(id, "r")

        -- Read history file
        if f then
            for line in f:lines() do
                table.insert(data.history[id].table, line)
            end
            f:close()
        end
    end
end
--- Save history table in history file
-- @param id The data.history identifier
function menu_gen.history_save(id)
    id = id or history_file_path
    if data.history[id] then
        local f = io.open(id, "w")
        if not f then
            local i = 0
            for d in id:gmatch(".-/") do
                i = i + #d
            end
            awful.util.mkdir(id:sub(1, i - 1))
            f = assert(io.open(id, "w"))
        end
        for i = 1, #data.history[id].table do
            f:write(data.history[id].table[i] .. "\n")
        end
       f:close()
       --nlog(#data.history[id].table)
       --nlog("F:WRITE")
    end
end
------------------------------------------------------------------------------

--- Generate an array of all visible menu entries.
-- @return all menu entries.
function menu_gen.generate()

    --menu_gen.history_save(history_file_path)
    menu_gen.history_check_load(history_file_path, 6666)
    local history_table = data.history[history_file_path]['table']

    local result = {}

    for _, command in ipairs(SortedDedupTable(ReversedTable(history_table))) do
                table.insert(result, { name = command,
                                       cmdline = command,
                                       icon = nil,
                                       category = nil })
    end
    return result
end

return menu_gen

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
