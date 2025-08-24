local M = { }

local autocmd = require'pigmentor.autocmd'
local finder = require'pigmentor.finder'
local ui = require'pigmentor.ui'

local display_style_cycler = {
    ['inline'] = 'highlight',
    ['highlight'] = 'inline',
}

--- Sets the plugin configuration.
--- @param opts table plugin configuration
function M.load_config(opts)
    M.config = vim.tbl_deep_extend('force', require'pigmentor.config', opts)
end

--- Refreshes a single buffer.
--- @param buf integer buffer ID
function M.refresh_buffer(buf)
    -- Get list of matches.
    local matches = finder.find_colors(M, buf)

    -- Redraw buffer.
    ui.redraw_buffer(M, buf, matches)
end

--- Refreshes all visible buffers.
function M.refresh_visible_buffers()
    local curr_tab_id = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(curr_tab_id)

    -- Find and deduplicate visible buffers to refresh.
    local bufs = { }  -- set of buffer IDs
    for _, win in ipairs(wins) do
        bufs[vim.api.nvim_win_get_buf(win)] = true
    end

    -- Refresh all visible buffers.
    for buf, _ in pairs(bufs) do
        M.refresh_buffer(buf)
    end
end

function M.disable()
    M.config.enabled = false
    M.refresh_visible_buffers()
end

function M.enable()
    M.config.enabled = false
    M.refresh_visible_buffers()
end

function M.toggle()
    M.config.enabled = not M.config.enabled
    M.refresh_visible_buffers()
end

function M.cycle_display_style()
    local next_style = display_style_cycler[M.config.display.style]
    if next_style == nil then
        next_style = 'inline'
    end
    M.config.display.style = next_style
    M.refresh_visible_buffers()
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
