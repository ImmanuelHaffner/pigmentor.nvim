local M = { }

local autocmd = require'pigmentor.autocmd'
local matcher = require'pigmentor.matcher'
local ui = require'pigmentor.ui'

--- Sets the plugin configuration.
--- @param opts table plugin configuration
function M.load_config(opts)
    M.config = vim.tbl_deep_extend('force', require'pigmentor.config', opts)
end

--- Refreshes a single buffer.
--- @param buf integer buffer ID
function M.refresh_buffer(buf)
    -- Get list of matches.
    local matches = matcher.find_colors(M.config, buf)

    -- Redraw buffer.
    ui.redraw_buffer(M, buf, matches)
end

--- Refreshes all visible buffers.
function M.refresh_visible_buffers()
    local curr_tab_id = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(curr_tab_id)
    for _, win in ipairs(wins) do
        M.refresh_buffer(vim.api.nvim_win_get_buf(win))
    end
end

function M.setup(opts)
    -- Load configuration.
    M.load_config(opts)

    -- Create plugin namespace.
    M.ns = vim.api.nvim_create_namespace'pigmentor.nvim'

    -- Setup autocmds.
    autocmd.setup(M)
end

return M
