return {
    enabled = true,                     -- master switch; when false, nothing is highlighted anywhere
    default = true,                     -- whether to highlight a buffer that no filetype or buftype rule matches
    filetypes = {},                     -- per-filetype rules, e.g. `{ css = true, markdown = false }`
    buftypes = {                        -- per-buftype rules, consulted when no filetype rule matches
        acwrite = false,
        prompt = false,
        terminal = false,
    },
    display = {
        inactive = true,                -- show in inactive windows
        style = 'inline',               -- one of inline, highlight, hybrid
        priority = 150,                 -- highlight priority, slightly above treesitter
        inline = {
            text_pre = nil,             -- text before
            text_post = '●',            -- text after
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
        [{ 'v', 'V', '\x16' }] = {
            cursor = false,
            line = false,
            visible = false,
        },
    },
}
