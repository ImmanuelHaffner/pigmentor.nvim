local color = require'pigmentor.color'
local decimal = '%d*%.?%d*'
local utils = require'pigmentor.utils'

local function clamp_8bit_channel(value)
    return utils.clamp(value, 0, 255)
end

--- Convert RBG channel relative ratio to absolute value.
--- @param ratio number Color relative value ∈ [0; 1]
--- @return integer value Color absolute value ∈ [0; 255]
local function channel_rel_to_abs(ratio)
    return clamp_8bit_channel(utils.round(ratio * 255))
end

--- Convert relative RGB [0; 1]³ to absolute RGB [0; 255]³.
--- @param r number Color red channel ∈ [0; 1]
--- @param g number Color green channel ∈ [0; 1]
--- @param b number Color blue channel ∈ [0; 1]
--- @return integer red Color red channel ∈ [0; 255]
--- @return integer green Color green channel ∈ [0; 255]
--- @return integer blue Color blue channel ∈ [0; 255]
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
        -- CSS HSL
        kind = 'css_hsl',
        pattern = 'hsl(a?)%(%s*(' .. decimal .. ')%s+' ..
                          '(' .. decimal .. ')%s+' ..
                          '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            local _, h, s, l = str:match(self.pattern)
            local r, g, b = color.hsl_to_rgb(utils.tonumbers(h, s, l))
            local R, G, B = rgb_rel_to_abs(r, g, b)
            return ('#%02x%02x%02x'):format(R, G, B)
        end,
    },
    {
        -- CSS HSL (legacy)
        kind = 'css_hsl',
        pattern = 'hsl(a?)%(%s*(' .. decimal .. ')%s*,%s*' ..
                              '(' .. decimal .. ')%s*,%s*' ..
                              '(' .. decimal .. ')%s*%)',
        to_vim_color = function(self, str)
            local _, h, s, l = str:match(self.pattern)
            local r, g, b = color.hsl_to_rgb(utils.tonumbers(h, s, l))
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
            return ('#%02x%02x%02x'):format(
                clamp_8bit_channel(tonumber(R)),
                clamp_8bit_channel(tonumber(G)),
                clamp_8bit_channel(tonumber(B)))
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
            local R, G, B = rgb_rel_to_abs(r, g, b)
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
