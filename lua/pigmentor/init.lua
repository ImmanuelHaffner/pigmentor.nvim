local M = { }

-- Ensure table.unpack is available
table.unpack = table.unpack or unpack

local finder = require'pigmentor.finder'
local ui = require'pigmentor.ui'

local display_style_cycler = {
    ['inline'] = 'highlight',
    ['highlight'] = 'hybrid',
    ['hybrid'] = 'inline',
}

--- Sets the plugin configuration.
--- @param opts table plugin configuration
function M.load_config(opts)
    M.config = require'pigmentor.config'
    M.update_config(opts)
end

--- Updates the plugin configuration with overrides of \p opts
--- @param opts table plugin configuration overrides
function M.update_config(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts)

    M.internal = M.internal or { }
    M.internal.buftypes = { }
    for _, buftype in ipairs(M.config.buftypes) do
        M.internal.buftypes[buftype] = true
    end
    M.internal.ignore_filetypes = { }
    for _, ft in ipairs(M.config.ignore_filetypes) do
        M.internal.ignore_filetypes[ft] = true
    end
    M.internal.buf_disabled = M.internal.buf_disabled or { }
end

--- Check whether pigmentor is active for the given buffer.
--- Returns false when the plugin is globally disabled, the buffer's buftype
--- is not in the allowlist, the buffer's filetype is in the blocklist, or
--- the buffer has been individually disabled via `disable_buf()`.
--- @param buf integer buffer ID
--- @return boolean
function M.is_buf_active(buf)
    if not M.config.enabled then return false end
    if not M.internal.buftypes[vim.bo[buf].buftype] then return false end
    if M.internal.ignore_filetypes[vim.bo[buf].filetype] then return false end
    if M.internal.buf_disabled[buf] then return false end
    return true
end

--- Disable pigmentor for a single buffer and clear its extmarks.
--- @param buf? integer buffer ID (defaults to current buffer)
function M.disable_buf(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    M.internal.buf_disabled[buf] = true
    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
end

--- Re-enable pigmentor for a single buffer and refresh it.
--- @param buf? integer buffer ID (defaults to current buffer)
function M.enable_buf(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    M.internal.buf_disabled[buf] = nil
    M.refresh_buffer(buf)
end

--- Toggle pigmentor for a single buffer.
--- @param buf? integer buffer ID (defaults to current buffer)
function M.toggle_buf(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    if M.internal.buf_disabled[buf] then
        M.enable_buf(buf)
    else
        M.disable_buf(buf)
    end
end

--- Refreshes a single buffer.
--- @param buf integer buffer ID
function M.refresh_buffer(buf)
    if not M.is_buf_active(buf) then
        return
    end

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
    M.config.enabled = true
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
    require'pigmentor.autocmd'.setup(M)
    -- Create user commands
    require'pigmentor.user_commands'.setup(M)

    -- If setup runs *after* VimEnter (e.g. lazy.nvim loads the plugin at
    -- VimEnter, by which point our VimEnter autocmd will never fire), kick off
    -- an initial render so visible buffers are highlighted immediately instead
    -- of requiring the user to move the cursor or switch tabs first.
    if vim.v.vim_did_enter == 1 then
        vim.schedule(function() M.refresh_visible_buffers() end)
    end
end

return M
