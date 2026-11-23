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

-- Every 'buftype' Neovim knows, so that the legacy allowlist form of `buftypes` can be expressed as rules.
local all_buftypes = { '', 'acwrite', 'help', 'nofile', 'nowrite', 'prompt', 'quickfix', 'terminal' }

--- Translates the legacy configuration keys into rules: `buftypes` given as a list (an allowlist) and
--- `ignore_filetypes` (a blocklist).
--- @param opts table plugin configuration
--- @return table opts
local function normalize(opts)
    opts = vim.deepcopy(opts or { })
    if type(opts.buftypes) == 'table' and opts.buftypes[1] ~= nil then
        local allowed = { }
        for _, buftype in ipairs(opts.buftypes) do allowed[buftype] = true end
        opts.buftypes = { }
        for _, buftype in ipairs(all_buftypes) do opts.buftypes[buftype] = allowed[buftype] or false end
    end
    if opts.ignore_filetypes then
        opts.filetypes = opts.filetypes or { }
        for _, ft in ipairs(opts.ignore_filetypes) do
            if opts.filetypes[ft] == nil then opts.filetypes[ft] = false end
        end
        opts.ignore_filetypes = nil
    end
    return opts
end

local function resolve_buf(buf)
    if buf == nil or buf == 0 then return vim.api.nvim_get_current_buf() end
    return buf
end

local function resolve_win(win)
    if win == nil or win == 0 then return vim.api.nvim_get_current_win() end
    return win
end

--- Sets the plugin configuration.
--- @param opts table plugin configuration
function M.load_config(opts)
    M.config = require'pigmentor.config'
    M.update_config(opts)
end

--- Updates the plugin configuration with overrides of \p opts
--- @param opts table plugin configuration overrides
function M.update_config(opts)
    M.config = vim.tbl_deep_extend('force', M.config, normalize(opts))
    M.internal = M.internal or {
        win_ns = { },   -- window ID -> namespace scoped to that window
        win_buf = { },  -- window ID -> buffer the window's namespace has extmarks in
        ns_pool = { },  -- namespaces released by closed windows, for reuse
    }
end

--- Whether \p buf should be highlighted according to its override and the rules, ignoring the master switch.
local function buf_wanted(buf)
    local override = vim.b[buf].pigmentor_enabled
    if override ~= nil then return override end
    local ft_rule = M.config.filetypes[vim.bo[buf].filetype]
    if ft_rule ~= nil then return ft_rule end
    local bt_rule = M.config.buftypes[vim.bo[buf].buftype]
    if bt_rule ~= nil then return bt_rule end
    return M.config.default
end

--- Whether \p win should show highlights, ignoring the master switch.
local function win_wanted(win)
    local override = vim.w[win].pigmentor_enabled
    if override ~= nil then return override end
    return buf_wanted(vim.api.nvim_win_get_buf(win))
end

--- Check whether pigmentor is active for the given buffer, disregarding window overrides.
--- Resolution order: master switch `enabled`, then the buffer override (`vim.b.pigmentor_enabled`), then the rule
--- for the buffer's 'filetype', then the rule for its 'buftype', then `default`.
--- @param buf? integer buffer ID (defaults to current buffer)
--- @return boolean
function M.is_buf_active(buf)
    return M.config.enabled and buf_wanted(resolve_buf(buf))
end

--- Check whether pigmentor is active for the given window.
--- A window override (`vim.w.pigmentor_enabled`) takes precedence over everything but the master switch; without
--- one, the window follows its buffer (see `is_buf_active()`).
--- @param win? integer window ID (defaults to current window)
--- @return boolean
function M.is_win_active(win)
    return M.config.enabled and win_wanted(resolve_win(win))
end

local function set_buf(buf, value)
    vim.b[buf].pigmentor_enabled = value
    M.refresh_buffer(buf)
    return M.is_buf_active(buf)
end

--- Enable pigmentor for a single buffer, overriding the rules.
--- @param buf? integer buffer ID (defaults to current buffer)
--- @return boolean active whether the buffer is now highlighted
function M.enable_buf(buf) return set_buf(resolve_buf(buf), true) end

--- Disable pigmentor for a single buffer, overriding the rules.
--- @param buf? integer buffer ID (defaults to current buffer)
--- @return boolean active whether the buffer is now highlighted
function M.disable_buf(buf) return set_buf(resolve_buf(buf), false) end

--- Toggle pigmentor for a single buffer.
--- @param buf? integer buffer ID (defaults to current buffer)
--- @return boolean active whether the buffer is now highlighted
function M.toggle_buf(buf)
    buf = resolve_buf(buf)
    return set_buf(buf, not buf_wanted(buf))
end

--- Drop a buffer's override, so it follows the rules again.
--- @param buf? integer buffer ID (defaults to current buffer)
--- @return boolean active whether the buffer is now highlighted
function M.reset_buf(buf) return set_buf(resolve_buf(buf), nil) end

local function set_win(win, value)
    vim.w[win].pigmentor_enabled = value
    M.refresh_window(win)
    return M.is_win_active(win)
end

--- Enable pigmentor for a single window, overriding its buffer.
--- @param win? integer window ID (defaults to current window)
--- @return boolean active whether the window now shows highlights
function M.enable_win(win) return set_win(resolve_win(win), true) end

--- Disable pigmentor for a single window, overriding its buffer.
--- @param win? integer window ID (defaults to current window)
--- @return boolean active whether the window now shows highlights
function M.disable_win(win) return set_win(resolve_win(win), false) end

--- Toggle pigmentor for a single window.
--- @param win? integer window ID (defaults to current window)
--- @return boolean active whether the window now shows highlights
function M.toggle_win(win)
    win = resolve_win(win)
    return set_win(win, not win_wanted(win))
end

--- Drop a window's override, so it follows its buffer again.
--- @param win? integer window ID (defaults to current window)
--- @return boolean active whether the window now shows highlights
function M.reset_win(win) return set_win(resolve_win(win), nil) end

--- Returns the namespace scoped to \p win, allocating one if needed.
--- Extmarks are per buffer, so a buffer shown in two windows can only be highlighted differently in each if every
--- window draws into a namespace of its own that only it displays.
local function win_ns(win)
    local ns = M.internal.win_ns[win]
    if not ns then
        ns = table.remove(M.internal.ns_pool) or vim.api.nvim_create_namespace('')
        vim.api.nvim__ns_set(ns, { wins = { win } })
        M.internal.win_ns[win] = ns
    end
    return ns
end

--- Removes the extmarks \p win placed, wherever its buffer was at the time.
--- @param win integer window ID
function M.clear_window(win)
    local ns, buf = M.internal.win_ns[win], M.internal.win_buf[win]
    if ns and buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    end
    M.internal.win_buf[win] = nil
end

--- Clears a closed window's extmarks and returns its namespace to the pool.
--- @param win integer window ID
function M.release_window(win)
    M.clear_window(win)
    local ns = M.internal.win_ns[win]
    if ns then
        M.internal.win_ns[win] = nil
        table.insert(M.internal.ns_pool, ns)
    end
end

--- Refreshes a single window.
--- @param win? integer window ID (defaults to current window)
function M.refresh_window(win)
    win = resolve_win(win)
    if not vim.api.nvim_win_is_valid(win) then return end

    -- Always clear first, so that a transition to inactive removes the highlights.
    M.clear_window(win)
    if not M.is_win_active(win) then return end
    if not M.config.display.inactive and win ~= vim.api.nvim_get_current_win() then return end

    local buf = vim.api.nvim_win_get_buf(win)
    ui.redraw_buffer(M, buf, win_ns(win), finder.find_colors(M, win))
    M.internal.win_buf[win] = buf
end

--- Refreshes every window of the current tab page that shows \p buf.
--- @param buf? integer buffer ID (defaults to current buffer)
function M.refresh_buffer(buf)
    buf = resolve_buf(buf)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == buf then
            M.refresh_window(win)
        end
    end
end

--- Refreshes all windows of the current tab page.
function M.refresh_visible_buffers()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        M.refresh_window(win)
    end
end

function M.disable()
    M.config.enabled = false
    M.refresh_visible_buffers()
    return false
end

function M.enable()
    M.config.enabled = true
    M.refresh_visible_buffers()
    return true
end

function M.toggle()
    M.config.enabled = not M.config.enabled
    M.refresh_visible_buffers()
    return M.config.enabled
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
