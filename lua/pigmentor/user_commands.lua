local M = { }

local function report(scope, active)
    vim.notify(('Pigmentor %s %s'):format(active and 'enabled' or 'disabled', scope), vim.log.levels.INFO)
end

function M.setup(pigmentor)
    local scopes = {
        { suffix = '', scope = 'globally', fns = { pigmentor.enable, pigmentor.disable, pigmentor.toggle } },
        { suffix = 'Buf', scope = 'for this buffer',
          fns = { pigmentor.enable_buf, pigmentor.disable_buf, pigmentor.toggle_buf, pigmentor.reset_buf } },
        { suffix = 'Win', scope = 'for this window',
          fns = { pigmentor.enable_win, pigmentor.disable_win, pigmentor.toggle_win, pigmentor.reset_win } },
    }
    local actions = { 'Enable', 'Disable', 'Toggle', 'Reset' }
    for _, s in ipairs(scopes) do
        for i, fn in ipairs(s.fns) do
            local desc = actions[i] == 'Reset'
                and ('Drop the Pigmentor override %s'):format(s.scope)
                or ('%s Pigmentor color highlighting %s'):format(actions[i], s.scope)
            vim.api.nvim_create_user_command('Pigmentor' .. actions[i] .. s.suffix, function()
                report(s.scope, fn())
            end, { desc = desc })
        end
    end

    vim.api.nvim_create_user_command('PigmentorRefresh', pigmentor.refresh_visible_buffers, {
        desc = 'Refresh Pigmentor highlighting in all visible buffers'
    })

    vim.api.nvim_create_user_command('PigmentorCycleStyle', pigmentor.cycle_display_style, {
        desc = 'Cycle through Pigmentor display styles (inline, highlight, hybrid)'
    })
end

return M
