local hex_digit = '[0-9a-fA-F]'

-- Array of known color formats.
local M = {
    {
        kind = 'hex_rgba',
        pattern = '#' .. string.rep(hex_digit, 8),
        to_vim_color = function(str)
            return str:sub(1, 7)
        end,
    },
    {
        kind = 'hex_rgb',
        pattern = '#' .. string.rep(hex_digit, 6),
        to_vim_color = function(str)
            return str:sub(1, 7)
        end,
    },
    {
        kind = 'hex_rgb_short',
        pattern = '#' .. string.rep(hex_digit, 3),
        to_vim_color = function(str)
            local r = str:sub(2, 2)
            local g = str:sub(2, 2)
            local b = str:sub(3, 3)
            return '#' .. r:rep(2) .. g:rep(2) .. b:rep(2)
        end,
    },
}

return M
