-- NVIM CONFIGURATION

-- Determine the value of $VIMFILES based on the operating system
local vimfiles
if vim.fn.has('unix') == 1 then
  vimfiles = vim.fn.expand('$HOME') .. '/.config/vim'
elseif vim.fn.has('win32') == 1 then
  vimfiles = vim.fn.expand('$HOME') .. '/vimfiles'
end
vim.fn.setenv('VIMFILES', vimfiles)

-- Use an autocmd to run the shebang detection when a file is opened
vim.api.nvim_exec([[
  augroup ShebangFiletype
    autocmd!
    autocmd BufReadPost * lua require('shebang').detect_shebang()
  augroup END
]], false)

-- Source Vimscript files from vim configuration
vim.cmd('source ' .. vimfiles .. '/vimrc.d/xdg.vim')      -- Change XDG directories to the same as vim
vim.cmd('source ' .. vimfiles .. '/vimrc.d/opts.vim')     -- Setting options
vim.cmd('source ' .. vimfiles .. '/vimrc.d/mappings.vim') -- Key mappings
vim.cmd('source ' .. vimfiles .. '/vimrc.d/autocmds.vim') -- Auto commands dependent on filetype
vim.cmd('source ' .. vimfiles .. '/vimrc.d/plugins.vim')  -- Plugins and plugin configuration

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 600 }) -- Add the timeout option
  end,
  group = highlight_group,
  pattern = '*',
})

-- Source lua plugin configuration
require('plugin_config')

-- Colour scheme setting generated by shell configuration
local colorscheme_lua_path = vim.fn.expand('~/.config/nvim/lua/colorscheme.lua')
if vim.fn.filereadable(colorscheme_lua_path) == 1 then
  require('colorscheme')
end
