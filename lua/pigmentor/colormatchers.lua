local hex_digit = '[0-9a-fA-F]'
local decimal = '%d*%.?%d*'

local function round(n) return math.floor(n + .5) end

-- Array of known color formats.
local M = {
    {
        -- Hexadecimal RGBA (8 digits)
        kind = 'hex_rgba',
        pattern = '#' .. string.rep(hex_digit, 8),
        to_vim_color = function(str)
            return str:sub(1, 7)
        end,
    },
    {
        -- Hexadecimal RGB (6 digits)
        kind = 'hex_rgb',
        pattern = '#' .. string.rep(hex_digit, 6),
        to_vim_color = function(str)
            return str:sub(1, 7)
        end,
    },
    {
        -- Short hexadecimal RGB (3 digits)
        kind = 'hex_rgb_short',
        pattern = '#' .. string.rep(hex_digit, 3),
        to_vim_color = function(str)
            local R = str:sub(2, 2)
            local G = str:sub(3, 3)
            local B = str:sub(4, 4)
            return '#' .. R:rep(2) .. G:rep(2) .. B:rep(2)
        end,
    },
    {
        -- CSS rgba
        kind = 'css_rgba',
        pattern = 'rgba%(' ..
                  '%s*(' .. decimal .. ')%s*,%s*(' .. decimal .. ')%s*,%s*(' .. decimal .. ')%s*,%s*(' .. decimal .. ')%s*%)',
        to_vim_color = function(str)
            local r, g, b = str:match('rgba%(' .. '%s*(' .. decimal .. ')%s*,%s*(' .. decimal .. ')%s*,%s*(' .. decimal .. ')%s*,%s*(' .. decimal .. ')%s*%)')
            local R, G, B = round(255 * r), round(255 * g), round(255 * b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
}

return M
