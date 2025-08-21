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

return M
