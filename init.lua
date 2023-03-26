-- Plugins and dependencies
local use = require('packer').use

-- To Install run :PackerInstall in a neovim instance
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use 'hrsh7th/nvim-compe' -- auto completion plugin
    use 'altercation/vim-colors-solarized' -- Solarized theme for VIM
    use 'jeffkreeftmeijer/vim-numbertoggle' -- toggles the line number display between relative and absolute 
end)

-- Indentation configurations
vim.opt.autoindent = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true 

-- LSP Configurations
require'lspconfig'.kotlin_language_server.setup {}
require'lspconfig'.tsserver.setup {}

-- Theme configuration see dependencies
vim.cmd('syntax enable')
vim.cmd('set background=dark')
vim.cmd('colorscheme solarized')


-- Show Line number
vim.cmd('set number')

-- this is useful when jumping to specific. Say you 
-- want to jump to line 45 that is 3 lines relative to the line number
-- you can use  3k or 3j and vim would show you 3 then
vim.cmd('set relativenumber')

--require('solarized').set()
-- Set up mappings for LSP-based autocompletion
function OnDemandCompletion()
  -- Check if the current buffer has omnifunc set
  if vim.bo.omnifunc then
    -- Set completefunc to omnifunc and call complete()
    vim.o.completefunc = vim.bo.omnifunc
    vim.api.nvim_input('<C-x><C-o>')
    vim.o.completefunc = ''
  end
end

-- Bind the completion function to a key mapping
vim.api.nvim_set_keymap('i', '<C-Space>', '<Esc>:lua OnDemandCompletion()<CR>a', { noremap = true, silent = true })
