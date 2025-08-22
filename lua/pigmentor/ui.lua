local M = { }

--- Places an *inline* extmark and a highlight group for a given match.
--- @param pigmentor table
--- @param buf integer buffer ID
--- @param match table the matched color
--- @param hl_number integer unique number for the highlight group
function M.place_inline_extmark(pigmentor, buf, match, hl_number)
    -- Create new highlight group.  The name includes buffer ID and highligh group counter for scoping.
    local hl_group = ('PigmentorHiBuf%dColor%d'):format(buf, hl_number)
    local hex_color = string.sub(match.text, 1, 7)
    vim.api.nvim_set_hl(0, hl_group, {
        fg = hex_color,
    })

    -- Place new extmark.
    vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.e, {
        virt_text = {{ pigmentor.config.display.glyph, hl_group }},
        virt_text_pos = 'inline',
        strict = false,
    })
end

--- Places an *overlay* extmark and a highlight group for a given match.
--- @param pigmentor table
--- @param buf integer buffer ID
--- @param match table the matched color
--- @param hl_number integer unique number for the highlight group
function M.place_highlight_extmark(pigmentor, buf, match, hl_number)
    -- Create new highlight group.  The name includes buffer ID and highligh group counter for scoping.
    local hl_group = ('PigmentorHiBuf%dColor%d'):format(buf, hl_number)
    local hex_color = string.sub(match.text, 1, 7)
    vim.api.nvim_set_hl(0, hl_group, {
        bg = hex_color,
    })

    -- Place new extmark.
    vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.s - 1, {
        end_col = match.e,
        virt_text_pos = 'overlay',
        hl_group = hl_group,
        hl_mode = 'replace',
    })
    vim.print('hl extmark placed')
end

--- Redraws a single buffer.
--- @param buf integer buffer ID
function M.redraw_buffer(pigmentor, buf, matches)
    -- Clear extmarks and highlight groups in this buffer.
    vim.api.nvim_buf_clear_namespace(buf, pigmentor.ns, 0, -1)
    local hl_counter = 1

    -- Process matches.
    for _, match in pairs(matches) do
        local line = match.line - 1
        local col = match.e
        -- Check whether an extmark was already created.
        local ext_marks = vim.api.nvim_buf_get_extmarks(buf, pigmentor.ns, { line, match.s }, { line, match.e }, {
            type = 'virt_text'
        })

        if #ext_marks == 0 then
            if pigmentor.config.display.style == 'inline' then
                M.place_inline_extmark(pigmentor, buf, match, hl_counter)
            elseif pigmentor.config.display.style == 'highlight' then
                M.place_highlight_extmark(pigmentor, buf, match, hl_counter)
            end
            hl_counter = hl_counter + 1
        end
    end
end

return M
