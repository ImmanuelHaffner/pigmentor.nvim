local M = { }

--- Sets up autocmds for Pigmentor.
--- @param pigmentor table
function M.setup(pigmentor)
    pigmentor.augroup = vim.api.nvim_create_augroup('pigmentor.nvim', { clear = true })

    -- When to refresh every window showing a buffer.  'FileType' and 'buftype' decide whether a buffer is
    -- highlighted at all, and both are set after `BufReadPost`.
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged', 'BufReadPost', 'BufWinEnter', 'FileType' }, {
        group = pigmentor.augroup,
        callback = function(ev) pigmentor.refresh_buffer(ev.buf) end,
    })
    vim.api.nvim_create_autocmd('OptionSet', {
        group = pigmentor.augroup,
        pattern = 'buftype',
        callback = function() pigmentor.refresh_buffer() end,
    })

    -- When to clear the extmarks of the window being left.
    vim.api.nvim_create_autocmd({ 'WinLeave' }, {
        group = pigmentor.augroup,
        callback = function()
            if not pigmentor.config.display.inactive then
                pigmentor.clear_window(vim.api.nvim_get_current_win())
            end
        end
    })

    -- When to refresh all visible buffers.
    vim.api.nvim_create_autocmd({ 'VimEnter', 'SessionLoadPost', 'TabEnter' }, {
        group = pigmentor.augroup,
        callback = function()
            pigmentor.refresh_visible_buffers()
        end,
    })

    -- Release a closed window's namespace.
    vim.api.nvim_create_autocmd('WinClosed', {
        group = pigmentor.augroup,
        callback = function(ev)
            local win = tonumber(ev.match)
            if win then pigmentor.release_window(win) end
        end,
    })
end

return M
