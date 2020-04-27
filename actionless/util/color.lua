local h_string = require('actionless.util.string')


local color = {}

function color.darker(color_value, darker_n)
  darker_n = darker_n or 10
    local result = "#"
    for s in color_value:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        local bg_numeric_value = tonumber("0x"..s) - darker_n
        if bg_numeric_value < 0 then bg_numeric_value = 0 end
        if bg_numeric_value > 255 then bg_numeric_value = 255 end
        result = result .. string.format("%2.2x", bg_numeric_value)
    end
    return result
end


function color.mix(color1, color2, ratio)
    ratio = ratio or 0.5
    local result = "#"
    local channels1 = color1:gmatch("[a-fA-F0-9][a-fA-F0-9]")
    local channels2 = color2:gmatch("[a-fA-F0-9][a-fA-F0-9]")
    for _ = 1,3 do
        local bg_numeric_value = math.ceil(
          tonumber("0x"..channels1())*ratio +
          tonumber("0x"..channels2())*(1-ratio)
        )
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

function color.choose_contrast_color(reference, candidate1, candidate2)
    if color.is_dark(reference) then
        if not color.is_dark(candidate1) then
            return candidate1
        else
            return candidate2
        end
    else
        if color.is_dark(candidate1) then
            return candidate1
        else
            return candidate2
        end
    end
end

function color.transparentize(hex_color, opacity)
  if (opacity < 0) or (opacity > 1) then error("Opacity should be within 0 and 1") end
  return h_string.max_length(hex_color, 7) .. string.format("%2.2x", opacity*255)
end

return color
