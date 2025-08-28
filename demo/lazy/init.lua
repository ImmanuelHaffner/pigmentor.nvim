-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim with pigmentor
require('lazy').setup({
  {
    'ImmanuelHaffner/pigmentor.nvim',
    -- Use the local development version
    dir = vim.fn.getcwd(),
    config = function()
      require('pigmentor').setup({
        -- Enable the plugin by default
        enabled = true,
        -- Set a simple display style for testing
        display = {
          style = 'inline'
        }
      })
    end,
    -- Load immediately for testing
    lazy = false,
    priority = 1000,
  }
}, {
  -- Lazy.nvim configuration
  dev = {
    path = '~/.local/share/nvim/lazy',
  }
})

-- Create a test buffer with some colors for demonstration
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Create a new buffer with test content
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)

    local test_content = {
      '/* Test colors for pigmentor.nvim */',
      '',
      '/* Hexadecimal colors */',
      '#FF0000  /* Red */',
      '#00FF00  /* Green */',
      '#0000FF  /* Blue */',
      '#FF00FF  /* Magenta */',
      '#FFFF00  /* Yellow */',
      '#00FFFF  /* Cyan */',
      '#000000  /* Black */',
      '#FFFFFF  /* White */',
      '',
      '/* RGB colors */',
      'rgb(255, 0, 0)    /* Red */',
      'rgb(0, 255, 0)    /* Green */',
      'rgb(0, 0, 255)    /* Blue */',
      'rgba(255, 0, 0, 0.5)  /* Semi-transparent red */',
      '',
      '/* CSS Color names (if supported) */',
      'color: red;',
      'background: blue;',
      '',
      '/* LaTeX definecolor examples */',
      '\\definecolor{myred}{RGB}{255,0,0}',
      '\\definecolor{mygreen}{RGB}{0,255,0}',
      '\\definecolor{myblue}{RGB}{0,0,255}',
      '\\definecolor{myyellow}{rgb}{1.0,1.0,0.0}',
      '\\definecolor{mymagenta}{rgb}{1.0,0.0,1.0}',
      '\\definecolor{mycyan}{rgb}{0.0,1.0,1.0}',
      '\\definecolor{myorange}{HTML}{FF8000}',
      '\\definecolor{mypurple}{HTML}{8000FF}',
      '\\definecolor{mylime}{HTML}{80FF00}',
      '',
      '/* Commands to test: */',
      '/* :PigmentorToggle - Toggle color highlighting */',
      '/* :PigmentorCycleDisplayStyle - Cycle through display styles */',
      '/* :PigmentorEnable - Enable highlighting */',
      '/* :PigmentorDisable - Disable highlighting */'
    }

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, test_content)
    vim.bo[buf].buftype = 'nofile'

    -- Set some helpful options
    vim.opt.number = true
    vim.opt.wrap = false

    print('Pigmentor.nvim test environment loaded!')
    print('Try :PigmentorToggle to toggle color highlighting')
  end
})
