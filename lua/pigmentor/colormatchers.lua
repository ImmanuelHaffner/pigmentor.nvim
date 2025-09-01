local color = require'pigmentor.color'
local decimal = '%d*%.?%d*'
local utils = require'pigmentor.utils'

local function parse_rgb(str, pattern)
    local r, g, b = str:match(pattern)
    r, g, b = utils.tonumbers(r, g, b)
    if utils.any_nil(r, g, b) then return nil end
    local R, G, B = color.rgb_rel_to_abs(r, g, b)
    return ('#%02x%02x%02x'):format(R, G, B)
end

local function parse_hsl(str, pattern)
    local h, s, l = str:match(pattern)
    h, s, l = utils.tonumbers(h, s, l)
    if utils.any_nil(h, s, l) then return nil end
    local r, g, b = color.hsl_to_rgb(h, s, l)
    local R, G, B = color.rgb_rel_to_abs(r, g, b)
    return ('#%02x%02x%02x'):format(R, G, B)
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
            return parse_rgb(str, self.pattern)
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
            return parse_rgb(str, self.pattern)
        end,
    },
    {
        -- CSS rgb
        kind = 'css_rgb',
        pattern = 'rgb%(%s*(' .. decimal .. ')%s+' ..
                          '(' .. decimal .. ')%s+' ..
                          '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            return parse_rgb(str, self.pattern)
        end,
    },
    {
        -- CSS rgb (legacy)
        kind = 'css_rgb',
        pattern = 'rgb%(%s*(' .. decimal .. ')%s*,%s*' ..
                          '(' .. decimal .. ')%s*,%s*' ..
                          '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            return parse_rgb(str, self.pattern)
        end,
    },
    {
        -- CSS HSL
        kind = 'css_hsl',
        pattern = 'hsla?%(%s*(' .. --[[hue]]        decimal .. ')%s+' ..
                            '(' .. --[[saturation]] decimal .. ')%s+' ..
                            '(' .. --[[lightness]]  decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            return parse_hsl(str, self.pattern)
        end,
    },
    {
        -- CSS HSL (legacy)
        kind = 'css_hsl',
        pattern = 'hsla?%(%s*(' .. --[[hue]]        decimal .. ')%s*,%s*' ..
                            '(' .. --[[saturation]] decimal .. ')%s*,%s*' ..
                            '(' .. --[[lightness]]  decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            return parse_hsl(str, self.pattern)
        end,
    },
    {
        -- LaTeX definecolor RGB
        kind = 'latex_definecolor',
        pattern = '\\definecolor{[%w_]+}{RGB}{%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*}',
        to_vim_color = function(self, str)
            local R, G, B = str:match(self.pattern)
            R, G, B = utils.tonumbers(R, G, B)
            if utils.any_nil(R, G, B) then return nil end
            return ('#%02x%02x%02x'):format(
                color.clamp_8bit_channel(R),
                color.clamp_8bit_channel(G),
                color.clamp_8bit_channel(B))
        end,
    },
    {
        -- LaTeX definecolor rgb
        kind = 'latex_definecolor',
        pattern = '\\definecolor{[%w_]+}{rgb}{' ..
                  '%s*(' .. decimal .. ')%s*,' ..
                  '%s*(' .. decimal .. ')%s*,' ..
                  '%s*(' .. decimal .. ')%s*}',
        to_vim_color = function(self, str)
            local r, g, b = str:match(self.pattern)
            r, g, b = utils.tonumbers(r, g, b)
            if utils.any_nil(r, g, b) then return nil end
            local R, G, B = color.rgb_rel_to_abs(r, g, b)
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
