--- Provides primitives for color conversion
local M = { }

local min = math.min
local max = math.max

local utils = require'pigmentor.utils'

function M.clamp_8bit_channel(value)
    return utils.clamp(value, 0, 255)
end

--- Convert RBG channel relative ratio to absolute value.
--- @param ratio number Color relative value ∈ [0; 1]
--- @return integer value Color absolute value ∈ [0; 255]
function M.channel_rel_to_abs(ratio)
    return M.clamp_8bit_channel(utils.round(ratio * 255))
end

--- Convert relative RGB [0; 1]³ to absolute RGB [0; 255]³.
--- @param r number Color red channel ∈ [0; 1]
--- @param g number Color green channel ∈ [0; 1]
--- @param b number Color blue channel ∈ [0; 1]
--- @return integer red Color red channel ∈ [0; 255]
--- @return integer green Color green channel ∈ [0; 255]
--- @return integer blue Color blue channel ∈ [0; 255]
function M.rgb_rel_to_abs(r, g, b)
    return M.channel_rel_to_abs(r), M.channel_rel_to_abs(g), M.channel_rel_to_abs(b)
end

--- Convert HSL to RGB.
--- @param hue number Color hue in degrees ∈ [0°; 360°)
--- @param saturation number Color saturation ∈ [0; 1]
--- @param lightness number Color lightness ∈ [0; 1]
--- @return number red Color red channel ∈ [0; 1]
--- @return number green Color green channel ∈ [0; 1]
--- @return number blue Color blue channel ∈ [0; 1]
--- @see https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
function M.hsl_to_rgb(hue, saturation, lightness)
    if (hue < 0 or hue >= 360) then hue = 0 end
    saturation = utils.clamp(saturation, 0, 1)
    lightness = utils.clamp(lightness, 0, 1)

    local function f(n)
        local k = (n + hue / 30) % 12
        local a = saturation * min(lightness, 1 - lightness)
        return lightness - a * max(-1, min(k - 3, 9 - k, 1))
    end

    return f(0), f(8), f(4)
end

--- Convert HSL to RGB.
--- @param hue number Color hue in degrees ∈ [0°; 360°)
--- @param saturation number Color saturation ∈ [0; 1]
--- @param value number Color value ∈ [0; 1]
--- @return number red Color red channel ∈ [0; 1]
--- @return number green Color green channel ∈ [0; 1]
--- @return number blue Color blue channel ∈ [0; 1]
--- @see https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
function M.hsv_to_rgb(hue, saturation, value)
    if (hue < 0 or hue >= 360) then hue = 0 end
    saturation = utils.clamp(saturation, 0, 1)
    value = utils.clamp(value, 0, 1)

    local function f(n)
        local k = (n + hue / 60) % 6
        return value - value * saturation * max(0, min(k, 4 - k, 1))
    end

    return f(5), f(3), f(1)
end


return M
