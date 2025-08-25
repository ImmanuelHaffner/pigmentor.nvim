local decimal = '%d*%.?%d*'

local function round(n) return math.floor(n + .5) end

local function clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

--- Convert RBG channel relative ratio to absolute value.
--- @param ratio number
--- @return integer
local function channel_rel_to_abs(ratio)
    return clamp(round(ratio * 255), 0, 255)
end

local function rgb_rel_to_abs(r, g, b)
    return channel_rel_to_abs(r), channel_rel_to_abs(g), channel_rel_to_abs(b)
end

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
            local R, G, B = rgb_rel_to_abs(r, g, b)
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
            local R, G, B = rgb_rel_to_abs(r, g, b)
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
            local R, G, B = rgb_rel_to_abs(r, g, b)
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
            local R, G, B = rgb_rel_to_abs(r, g, b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
    {
        -- LaTeX definecolor RGB
        kind = 'latex_definecolor',
        pattern = '\\definecolor{[%w_]+}{RGB}{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*}',
        to_vim_color = function(self, str)
            local R, G, B = str:match(self.pattern)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
    {
        -- LaTeX definecolor HTML
        kind = 'latex_definecolor',
        pattern = '\\definecolor{[%w_]+}{HTML}{(' .. ('%x'):rep(6) .. ')}',
        to_vim_color = function(self, str)
            local hex = str:match(self.pattern)
            return '#' .. hex
        end,
    },
}

return M
