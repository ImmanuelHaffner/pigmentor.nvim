--- Provides primitives for color conversion
local M = { }

local min = math.min
local max = math.max

local utils = require'pigmentor.utils'

--- Convert HSL to RGB.
--- @param hue number Color hue in degrees ∈ [0°; 360°)
--- @param saturation number Color saturation ∈ [0; 1]
--- @param lightness number Color lightness ∈ [0; 1]
--- @return number red Color red channel ∈ [0; 1]
--- @return number green Color green channel ∈ [0; 1]
--- @return number blue Color blue channel ∈ [0; 1]
--- @see https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB_alternative
function M.hsl_to_rgb(hue, saturation, lightness)
    assert(0 <= hue and hue < 360, "Hue outside bounds [0; 360)")
    assert(0 <= saturation and saturation <= 1, "Saturation outside bounds [0; 1]")
    assert(0 <= lightness and lightness <= 1, "Lightness outside bounds [0; 1]")

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
    assert(0 <= hue and hue < 360, "Hue outside bounds [0; 360)")
    assert(0 <= saturation and saturation <= 1, "Saturation outside bounds [0; 1]")
    assert(0 <= value and value <= 1, "Value outside bounds [0; 1]")

    local function f(n)
        local k = (n + hue / 60) % 6
        return value - value * saturation * max(0, min(k, 4 - k, 1))
    end

    return f(5), f(3), f(1)
end


return M
