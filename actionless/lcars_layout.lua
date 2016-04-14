
--[[

     Licensed under GNU General Public License v2
      * (c) 2014       projektile, worron
      * (c) 2013       Luke Bonham
      * (c) 2009       Donald Ephraim Curtis
      * (c) 2008       Julien Danjolu

--]]

local tag       = require("awful.tag")
local beautiful = require("beautiful")
local ipairs    = ipairs
local math      = { floor = math.floor,
                    ceil  = math.ceil,
                    max   = math.max,
                    min   = math.min }

local uselesstile = {}

-- Transformation functions
local function flip(canvas, geometry)
    return {
        -- vertical only
        x = 2 * canvas.x + canvas.width - geometry.x - geometry.width,
        y = geometry.y,
        width = geometry.width,
        height = geometry.height
    }
end

local function swap(geometry)
    return { x = geometry.y, y = geometry.x, width = geometry.height, height = geometry.width }
end

-- Find geometry for secondary windows column
local function cut_column(wa, n, index)
    local width = wa.width / n
    local area = { x = wa.x + (index - 1) * width, y = wa.y, width = width, height = wa.height }

    return area
end

-- Find geometry for certain window in column
local function cut_row(wa, factor, index, used)
    local height = wa.height * factor.window[index] / factor.total
    local area = { x = wa.x, y = wa.y + used, width = wa.width, height = height }

    return area
end

-- Client geometry correction depending on useless gap and window border
local function size_correction(c, geometry, useless_gap)
    geometry.width  = math.max(geometry.width  - 2 * c.border_width - useless_gap.w, 1)
    geometry.height = math.max(geometry.height - 2 * c.border_width - useless_gap.h, 1)
    geometry.x = geometry.x + useless_gap.x / 2
    geometry.y = geometry.y + useless_gap.y / 2
end

-- Check size factor for group of clients and calculate total
local function calc_factor(n, winfactors)
    local factor = { window = winfactors, total = 0, min = 1 }

    for i = 1, n do
        if not factor.window[i] then
            factor.window[i] = factor.min
        else
            factor.min = math.min(factor.window[i], factor.min)
            if factor.window[i] < 0.05 then factor.window[i] = 0.05 end
        end
        factor.total = factor.total + factor.window[i]
    end

    return factor
end

-- Tile group of clients in given area
-- @canvas need for proper transformation only
-- @winfactors table with clients size factors
local function tile_column(canvas, area, list, useless_gap, transformation, winfactors)
    local used = 0
    local factor = calc_factor(#list, winfactors)

    for i, c in ipairs(list) do
        local g = cut_row(area, factor, i, used)
        used = used + g.height

        -- swap workarea dimensions
        if transformation.flip then g = flip(canvas, g) end
        if transformation.swap then g = swap(g) end

        -- useless gap and border correction
        size_correction(c, g, useless_gap)

        c:geometry(g)
    end
end

--Main tile function
local function tile(p, orientation)

    -- Theme vars
    local ugw = beautiful.useless_gap or 0
    local useless_gap = {x=ugw, y=ugw, h=ugw, w=ugw}
    local global_border = 0 --beautiful.global_border_width or 0

    -- Aliases
    local wa = p.workarea
    local cls = p.clients
    local t = screen[p.screen].selected_tag

    -- Nothing to tile here
    if #cls == 0 then return end

    -- Get tag prop
    local nmaster = math.min(t.master_count, #cls)
    local mwfact = t.master_width_factor

    if nmaster == 0 then
        mwfact = 0
    elseif nmaster == #cls then
        mwfact = 1
    end

    -- clients size factor
    local data = tag.getdata(t).windowfact

    if not data then
        data = {}
        tag.getdata(t).windowfact = data
    end

    -- Split master and other windows
    local cls_master, cls_other = {}, {}

    for i, c in ipairs(cls) do
        if i <= nmaster then
            table.insert(cls_master, c)
        else
            table.insert(cls_other, c)
        end
    end

    -- Workarea size correction depending on useless gap and global border
    wa.height = wa.height - 2 * global_border - useless_gap.h + ((#cls_other >= 1) and useless_gap.h*3 or 0)
    wa.width  = wa.width -  2 * global_border - useless_gap.w
    wa.x = wa.x + useless_gap.x / 2 + global_border
    wa.y = (#cls_other >= 1) and 0 or wa.y + useless_gap.x / 2 + global_border

    -- Find which transformation we need for given orientation
    local transformation = {
        swap = orientation == 'top' or orientation == 'bottom',
        flip = orientation == 'left' or orientation == 'top'
    }

    -- Swap workarea dimensions if orientation vertical
    if transformation.swap then wa = swap(wa) end

    -- Tile master windows
    local master_area = {
        x = (#cls_other >= 1)
          and wa.x + beautiful.panel_height*0 + ugw*1
          or wa.x,
        y = wa.y,
        width  = (#cls_other >= 1)
          and wa.width * mwfact - beautiful.panel_height * 2 - ugw*2
          or ((nmaster > 0) and wa.width * mwfact or 0),
        height = wa.height + ugw
    }

    if not data[0] then data[0] = {} end
    tile_column(
       wa, master_area, cls_master,
       {
            x=ugw,
            y=ugw,
            w=ugw*2,
            h=ugw,
         },
       transformation,
       data[0]
    )

    -- Tile other windows
    local other_area = {
        x = (nmaster >= 1)
          and wa.x + master_area.width + beautiful.panel_height*2 + ugw*4
          or wa.x + master_area.width + ugw*2,
        y = wa.y,
        width = (nmaster >= 1)
          and wa.width - master_area.width - beautiful.panel_height * 2 - ugw*5
          or wa.width - master_area.width - ugw*2,
        height = wa.height + ugw
    }

    -- get column number for other windows
    local ncol = math.min(t.column_count, #cls_other)

    -- split other windows to column groups
    local last_small_column = ncol - #cls_other % (ncol > 0 and ncol or 1)
    local rows_min = math.floor(#cls_other / ncol)

    local client_index = 1
    for i = 1, ncol do
        local position = transformation.flip and ncol - i + 1 or i
        local rows = i <= last_small_column and rows_min or rows_min + 1
        local column = {}

        for _ = 1, rows do
            table.insert(column, cls_other[client_index])
            client_index = client_index + 1
        end

        -- and tile
        local column_area = cut_column(other_area, ncol, position)

        if not data[i] then data[i] = {} end
        tile_column(
          wa, column_area, column, {
            x=ugw,
            y=ugw,
            w=ugw*2,
            h=ugw,
         }, transformation, data[i]
       )
    end
end

-- Layout constructor
local function construct_layout(name, orientation)
    return {
        name = name,
        -- @p screen number to tile
        arrange = function(p) return tile(p, orientation) end
    }
end

-- Build layouts with different tile direction
uselesstile.right  = construct_layout("uselesstile", "right")
uselesstile.left   = construct_layout("uselesstileleft", "left")
uselesstile.bottom = construct_layout("uselesstilebottom", "bottom")
uselesstile.top    = construct_layout("lcars", "top")

-- Module aliase
uselesstile.arrange = uselesstile.right.arrange
uselesstile.name = uselesstile.right.name

return uselesstile
