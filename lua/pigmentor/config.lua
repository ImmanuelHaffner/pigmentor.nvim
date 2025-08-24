return {
    enabled = true,                     -- whether the plugin is active
    display = {
        inactive = true,                -- show in inactive windows
        style = 'inline',               -- one of inline, highlight
        inline = {
            text_post = '',               -- text after
        },
        highlight = {
            padding = {
                left = 1,
                right = 1,
            },
        },
    },
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
