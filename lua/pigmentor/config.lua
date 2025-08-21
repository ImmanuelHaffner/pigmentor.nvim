return {
    display = {
        style = 'inline',               -- one of inline, highlight
        glyph = '',                   -- glyph for inline style
    },
    inactive = true,                    -- show in inactive window
    modes = {
        n = {
            cursor = true,              -- show for item under cursor
            line = true,                -- show for current line
            visible = true,             -- show for all visible lines
        },
        no = {
            cursor = false,
            line = false,
            visible = false,
        },
        i = {
            cursor = false,
            line = false,
            visible = true,
        },
        [{ 'v', 'V', '' }] = {
            cursor = false,
            line = false,
            visible = false,
        },
    },
}
