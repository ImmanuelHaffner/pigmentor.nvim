local M = { }

function M.setup(opts)
    vim.notify('Set up pigmentor with ' .. vim.inspect(opts))
end

vim.print('loading pigmentor')

return M
