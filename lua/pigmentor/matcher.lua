local M = { }

local utils = require'pigmentor.utils'

local pat_hex_digit = '[0-9a-fA-F]'

local matchers = {
    { kind = 'hex_rgba', pattern = '#' .. string.rep(pat_hex_digit, 8) },
    { kind = 'hex_rgb', pattern = '#' .. string.rep(pat_hex_digit, 6) },
}

--- Find all colors in the file.
--- @param config table
--- @param args table
--- @return table the colors found, as a table of tables
function M.find_colors(config, ev)
    if vim.bo[ev.buf].buftype ~= '' then return {} end  -- only support 'normal' buffers

    -- Don't find colors while in certain modes.
    local mode = vim.api.nvim_get_mode().mode
    local mode_config = utils.get_mode_config(config, mode)

    -- Check whether buffer is active and we want to find colors.
    local is_active = ev.buf == vim.api.nvim_get_current_buf()
    if not config.display.inactive and not is_active then return {} end

    local curr_tab_id = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(curr_tab_id)

    local matches = { }
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf == ev.buf then  -- found a window showing the buffer
            local wininfo = vim.fn.getwininfo(win)[1]
            local rect = {
                row_first = wininfo.topline,                                        -- 1-indexed
                row_last = wininfo.botline,                                         -- 1-indexed
                col_first = wininfo.leftcol and wininfo.leftcol + 1 or 1,           -- 1-indexed
            }
            rect.col_last = rect.col_first + wininfo.width - wininfo.textoff      -- 1-indexed
            local new_matches = M.find_colors_in_range(buf, win, rect, mode_config)
            for k, v in pairs(new_matches) do
                if matches[k] == nil then
                    matches[k] = v
                end
            end
        end
    end

    return matches
end

function M.find_colors_in_range(buf, win, rect, mode_config)
    local matches = { }

    -- Get the visible lines.
    local lines = vim.api.nvim_buf_get_lines(buf, rect.row_first - 1, rect.row_last, false)
    local _, cursor_line, cursor_col = table.unpack(vim.fn.getcursorcharpos(win))

    for line_idx, line in ipairs(lines) do
        local col = rect.col_first
        local line_num = line_idx + rect.row_first - 1

        while true do
            local s, e
            local kind
            for _, matcher in ipairs(matchers) do
                s, e = string.find(line, matcher.pattern, col)
                if s then
                    kind = matcher.kind
                    break  -- break on first matcher matching
                end
            end
            if not s or s >= rect.col_last then break end  -- no matcher matched
            if s then
                if line_num == cursor_line then  -- current line
                    if s <= cursor_col and cursor_col <= e then  -- cursor on item
                        if mode_config.cursor == false then
                            goto continue  -- skip item under cursor
                        end
                    elseif mode_config.line == false then
                        goto continue  -- skip item in current line
                    end
                elseif mode_config.visible == false then
                    goto continue  -- skip visible
                end

                local color_str = string.sub(line, s, e)
                matches[{line_num, s}] = {  -- uniquely identify matches by their location, avoiding duplicates
                    text = color_str,
                    line = line_num,
                    s = s,
                    e = e,
                    kind = kind,
                }
            end

            ::continue::
            col = e
        end
    end

    return matches
end

return M
