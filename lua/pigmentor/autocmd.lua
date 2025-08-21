local M = { }

function M.setup(pigmentor, opts)
    pigmentor.augroup = vim.api.nvim_create_augroup('pigmentor.nvim', { clear = true })

    -- When to redraw
    if opts.redraw then
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged', 'BufReadPost' }, {
            group = pigmentor.augroup,
            callback = opts.redraw
        })

        vim.api.nvim_create_autocmd({ 'WinLeave' }, {
            group = pigmentor.augroup,
            callback = function(ev)
                if not pigmentor.config.display.inactive then
                    vim.api.nvim_buf_clear_namespace(ev.buf, pigmentor.ns, 0, -1)
                end
            end
        })
    end
end

return M
