local M = { }

function M.get_mode_config(config, mode)
    for key, mode_config in pairs(config.modes) do
        if type(key) == 'string' and key == mode then
            return mode_config
        end

        if type(key) == 'table' then
            for _, m in ipairs(key) do
                if m == mode then
                    return mode_config
                end
            end
        end
    end

    return config.modes.n  -- fall back to normal mode
end

function M.round(n) return math.floor(n + .5) end

function M.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

--- Convert a pack of strings to a pack of numbers.
--- @param ... string
--- @return number ...
function M.tonumbers(...)
    local args = { ... }
    local t = { }
    for _, v in ipairs(args) do
        t[#t + 1] = tonumber(v)
    end
    return table.unpack(t)
end

return M
