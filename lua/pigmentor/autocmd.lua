local M = { }

--- Sets up autocmds for Pigmentor.
--- @param pigmentor table
function M.setup(pigmentor)
    pigmentor.augroup = vim.api.nvim_create_augroup('pigmentor.nvim', { clear = true })

    -- When to refresh a single buffer.
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged', 'BufReadPost' }, {
        group = pigmentor.augroup,
        callback = function(ev) pigmentor.refresh_buffer(ev.buf) end,
    })

    -- When to clear extmarks and highlight groups in a buffer.
    vim.api.nvim_create_autocmd({ 'WinLeave' }, {
        group = pigmentor.augroup,
        callback = function(ev)
            if not pigmentor.config.display.inactive then
                vim.api.nvim_buf_clear_namespace(ev.buf, pigmentor.ns, 0, -1)
            end
        end
    })

    -- When to refresh all visible buffers.
    vim.api.nvim_create_autocmd({ 'TabEnter' }, {
        group = pigmentor.augroup,
        callback = function(ev)
            pigmentor.refresh_visible_buffers()
        end,
    })
end

return M
