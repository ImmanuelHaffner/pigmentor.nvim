local M = { }

local utils = require'pigmentor.utils'
local matchers = require'pigmentor.colormatchers'

local function find_strict(str, pattern, col)
    col = col or 1
    -- vim.print(('find_strict(str="%s", pattern="%s", col=%d)'):format(str, pattern, col))
    local s, e = str:find(pattern .. '[%s%p%c]', col)
    if s then
        e = e - 1
    else
        -- consider match at the end of line (EOL)
        s, e = str:find(pattern .. '$', col)
    end
    if s then
        return s, e
    end
    return nil, nil
end

--- Find all colors in the given buffer.  It is important to do this per buffer, not per window.  We later clear all
--- extmarks in the Pigmentor namespace in this buffer before redrawing.
--- @param pigmentor table
--- @param buf integer
--- @return table the colors found, as a table of tables
function M.find_colors(pigmentor, buf)
    if not pigmentor.config.enabled then return {} end
    if vim.bo[buf].buftype ~= '' then return {} end  -- only support 'normal' buffers

    -- Get the config settings for the current mode.
    local mode_config = utils.get_mode_config(pigmentor.config, vim.api.nvim_get_mode().mode)

    -- Check whether buffer is active and we want to find colors.
    local is_active = buf == vim.api.nvim_get_current_buf()
    if not pigmentor.config.display.inactive and not is_active then
        return {}  -- don't search for colors in inactive buffer
    end

    -- Get visible windows.
    local curr_tab_id = vim.api.nvim_get_current_tabpage()
    local wins = vim.api.nvim_tabpage_list_wins(curr_tab_id)

    local matches = { }
    for _, win in ipairs(wins) do
        if buf == vim.api.nvim_win_get_buf(win) then  -- found a window showing the buffer
            local wininfo = vim.fn.getwininfo(win)[1]
            local rect = {
                row_first = wininfo.topline,                                        -- 1-indexed
                row_last = wininfo.botline,                                         -- 1-indexed
                col_first = wininfo.leftcol and wininfo.leftcol + 1 or 1,           -- 1-indexed
            }
            rect.col_last = rect.col_first + wininfo.width - wininfo.textoff        -- 1-indexed
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
            local matcher_idx
            for idx, matcher in ipairs(matchers) do
                local new_s, new_e = find_strict(line, matcher.pattern, col)
                if not s or (new_s and new_s < s) then
                    matcher_idx = idx
                    s = new_s
                    e = new_e
                end
            end
            if s == nil or s >= rect.col_last then break end  -- no matcher matched
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
                    idx = matcher_idx,
                }
            end

            ::continue::
            col = e + 1
        end
    end

    return matches
end

return M
