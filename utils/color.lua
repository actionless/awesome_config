local color = {}

function color.darker(color_value, darker_n)
    local result = "#"
    for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        local bg_numeric_value = tonumber("0x"..s) - darker_n
        if bg_numeric_value < 0 then bg_numeric_value = 0 end
        if bg_numeric_value > 255 then bg_numeric_value = 255 end
        result = result .. string.format("%2.2x", bg_numeric_value)
    end
    return result
end

function color.is_dark(color_value)
    local bg_numeric_value = 0;
    for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        bg_numeric_value = bg_numeric_value + tonumber("0x"..s);
    end
    local is_dark_bg = (bg_numeric_value < 383)
    return is_dark_bg
end

return color
