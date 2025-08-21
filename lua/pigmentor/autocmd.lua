local M = { }

function M.setup(opts)
    local augroup = vim.api.nvim_create_augroup('pigmentor.nvim', { clear = true })

    -- When to redraw
    if opts.redraw then
        vim.api.nvim_create_autocmd( { 'CursorMoved', 'ModeChanged', 'BufReadPost' }, {
            group = augroup,
            callback = opts.redraw
        })
    end
end

return M
