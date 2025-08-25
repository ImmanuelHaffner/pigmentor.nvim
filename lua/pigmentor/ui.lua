local matchers = require'pigmentor.colormatchers'

local M = { }

function M.compose_extmark_virt_text(data, hl_group)
    if type(data) == 'string' then
        return {{ data, hl_group }}
    elseif type(data) == 'table' then
        local invert = false
        local res = {}
        for _, part in ipairs(data) do
            table.insert(res, { part, invert and hl_group .. 'Inverted' or hl_group })
            invert = not invert
        end
        return res
    end
    return {}
end

function M.create_highlight_group(buf, match, hl_number)
    -- Get normal highlight group.
    local hl_normal = vim.api.nvim_get_hl(0, { name = 'Normal' })

    -- Create new highlight group.  The name includes buffer ID and highligh group counter for scoping.
    local hl_group = ('PigmentorHiBuf%dColor%d'):format(buf, hl_number)
    local matcher = matchers[match.idx]
    local vim_color = matcher:to_vim_color(match.text)
    vim.api.nvim_set_hl(0, hl_group, {
        fg = vim_color, bg = hl_normal.bg,
    })
    vim.api.nvim_set_hl(0, hl_group .. 'Inverted', {
        bg = vim_color, fg = hl_normal.bg,
    })

    return hl_group
end

--- Places an *inline* extmark and a highlight group for a given match.
--- @param pigmentor table
--- @param buf integer buffer ID
--- @param match table the matched color
--- @param hl_number integer unique number for the highlight group
function M.place_inline_extmark(pigmentor, buf, match, hl_number)
    local hl_group = M.create_highlight_group(buf, match, hl_number)
    local inline_conf = pigmentor.config.display.inline

    -- Place pre extmark.
    vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.s - 1, {
        -- virt_text = {{ pigmentor.config.display.glyph, hl_group }},
        virt_text = M.compose_extmark_virt_text(inline_conf.text_pre, hl_group),
        virt_text_pos = 'inline',
        strict = false,
    })

    -- Place post extmark.
    vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.e, {
        -- virt_text = {{ pigmentor.config.display.glyph, hl_group }},
        virt_text = M.compose_extmark_virt_text(inline_conf.text_post, hl_group),
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
    local hl_group = M.create_highlight_group(buf, match, hl_number) .. 'Inverted'
    local highlight_conf = pigmentor.config.display.highlight

    -- Padding left.
    if highlight_conf.padding.left and highlight_conf.padding.left > 0 then
        vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.s - 1, {
            virt_text =  {{ string.rep(' ', highlight_conf.padding.left), hl_group }},
            virt_text_pos = 'inline',
        })
    end

    -- Place new extmark.
    vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.s - 1, {
        end_col = match.e,
        virt_text_pos = 'overlay',
        hl_group = hl_group,
        hl_mode = 'replace',
    })

    -- Padding right.
    if highlight_conf.padding.right and highlight_conf.padding.right > 0 then
        vim.api.nvim_buf_set_extmark(buf, pigmentor.ns, match.line - 1, match.e, {
            virt_text =  {{ string.rep(' ', highlight_conf.padding.right), hl_group }},
            virt_text_pos = 'inline',
        })
    end
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
