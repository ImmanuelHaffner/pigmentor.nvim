local M = { }

local autocmd = require'pigmentor.autocmd'
local config = require'pigmentor.config'
local matcher = require'pigmentor.matcher'

function M.load_config(opts)
    M.config = vim.tbl_deep_extend('force', config, opts)
end

function M.setup(opts)
    M.load_config(opts)

    -- Create plugin namespace
    local ns = vim.api.nvim_create_namespace'pigmentor.nvim'

    autocmd.setup{
        redraw = function(ev)
            -- Clear extmarks and highlight groups in this buffer.
            vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
            local hl_counter = 1

            -- Get list of matches.
            local matches = matcher.find_colors(M.config, ev)

            -- Process matches.
            for _, match in pairs(matches) do
                local line = match.line - 1
                local col = match.e
                -- Check whether an extmark was already created.
                local ext_marks = vim.api.nvim_buf_get_extmarks(ev.buf, ns, { line, col }, { line, col }, {
                    type = 'virt_text'
                })

                if #ext_marks == 0 then
                    -- Create new highlight group.
                    local hl_group = ('PigmentorHi%d'):format(hl_counter)
                    local fg = string.sub(match.text, 1, 7)
                    hl_counter = hl_counter + 1
                    vim.api.nvim_set_hl(0, hl_group, {
                        fg = fg,
                    })

                    -- Place new extmark.
                    vim.api.nvim_buf_set_extmark(ev.buf, ns, line, col, {
                        virt_text = {{ M.config.display.glyph, hl_group }},
                        virt_text_pos = 'inline',
                        strict = false,
                    })
                end
            end
        end,
    }
end

return M
