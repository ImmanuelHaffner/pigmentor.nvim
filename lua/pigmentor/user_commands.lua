local M = { }

function M.setup(pigmentor)
    vim.api.nvim_create_user_command('PigmentorEnable', pigmentor.enable, {
        desc = 'Enable Pigmentor color highlighting'
    })

    vim.api.nvim_create_user_command('PigmentorDisable', pigmentor.disable, {
        desc = 'Disable Pigmentor color highlighting'
    })

    vim.api.nvim_create_user_command('PigmentorToggle', pigmentor.toggle, {
        desc = 'Toggle Pigmentor color highlighting'
    })

    vim.api.nvim_create_user_command('PigmentorRefresh', pigmentor.refresh_visible_buffers, {
        desc = 'Refresh Pigmentor highlighting in all visible buffers'
    })

    vim.api.nvim_create_user_command('PigmentorCycleStyle', pigmentor.cycle_display_style, {
        desc = 'Cycle through Pigmentor display styles (inline, highlight, hybrid)'
    })
end

return M
