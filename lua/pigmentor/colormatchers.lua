local decimal = '%d*%.?%d*'

local function round(n) return math.floor(n + .5) end

-- Array of known color formats.
local M = {
    {
        -- Hexadecimal RGBA (8 digits)
        kind = 'hex_rgba',
        pattern = '#' .. string.rep('%x', 8),
        to_vim_color = function(_, str)
            return str:sub(1, 7)
        end,
    },
    {
        -- Hexadecimal RGB (6 digits)
        kind = 'hex_rgb',
        pattern = '#' .. string.rep('%x', 6),
        to_vim_color = function(_, str)
            return str:sub(1, 7)
        end,
    },
    {
        -- Short hexadecimal RGB (3 digits)
        kind = 'hex_rgb_short',
        pattern = '#' .. string.rep('%x', 3),
        to_vim_color = function(_, str)
            local R = str:sub(2, 2)
            local G = str:sub(3, 3)
            local B = str:sub(4, 4)
            return '#' .. R:rep(2) .. G:rep(2) .. B:rep(2)
        end,
    },
    {
        -- CSS rgba
        kind = 'css_rgba',
        pattern = 'rgba%(%s*(' .. decimal .. ')%s+' ..
                           '(' .. decimal .. ')%s+' ..
                           '(' .. decimal .. ')%s+' ..
                           '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            local r, g, b = str:match(self.pattern)
            local R, G, B = round(255 * r), round(255 * g), round(255 * b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
    {
        -- CSS rgba (legacy)
        kind = 'css_rgba',
        pattern = 'rgba%(%s*(' .. decimal .. ')%s*,%s*' ..
                           '(' .. decimal .. ')%s*,%s*' ..
                           '(' .. decimal .. ')%s*,%s*' ..
                           '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            local r, g, b = str:match(self.pattern)
            local R, G, B = round(255 * r), round(255 * g), round(255 * b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
    {
        -- CSS rgb
        kind = 'css_rgb',
        pattern = 'rgb%(%s*(' .. decimal .. ')%s+' ..
                          '(' .. decimal .. ')%s+' ..
                          '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            local r, g, b = str:match(self.pattern)
            local R, G, B = round(255 * r), round(255 * g), round(255 * b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
    {
        -- CSS rgb (legacy)
        kind = 'css_rgb',
        pattern = 'rgb%(%s*(' .. decimal .. ')%s*,%s*' ..
                          '(' .. decimal .. ')%s*,%s*' ..
                          '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            local r, g, b = str:match(self.pattern)
            local R, G, B = round(255 * r), round(255 * g), round(255 * b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
}

return M
