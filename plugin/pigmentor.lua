-- Prevent the plugin from being loaded twice
if vim.g.loaded_pigmentor == 1 or vim.g.loaded_pigmentor == true then
  return
end

-- Check Neovim version compatibility (assuming modern features)
if vim.fn.has('nvim-0.9') == 0 then
  vim.notify('pigmentor.nvim requires Neovim >= 0.9.0', vim.log.levels.ERROR)
  return
end

-- Mark plugin as loaded
vim.g.loaded_pigmentor = 1

-- Require the main module
require'pigmentor'.setup{}
