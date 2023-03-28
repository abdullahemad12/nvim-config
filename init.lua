-- Plugins and dependencies
local use = require('packer').use

-- To Install run :PackerInstall in a neovim instance
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use 'hrsh7th/nvim-compe' -- auto completion plugin
    use 'altercation/vim-colors-solarized' -- Solarized theme for VIM
    use 'jeffkreeftmeijer/vim-numbertoggle' -- toggles the line number display between relative and absolute 
    use 'nvim-tree/nvim-tree.lua' -- File explorer tree
    use 'prettier/vim-prettier'
    use 'dense-analysis/ale' -- for linting
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


-- Setup file explorer

-- disable netrw at the very start of your init.lua (strongly advised by the official docs)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

vim.cmd('NvimTreeToggle') -- open tree by default 

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
local opts =  { noremap = true, silent = true }
vim.api.nvim_set_keymap('i', '<C-Space>', '<Esc>:lua OnDemandCompletion()<CR>a', opts) -- maps autocomplete to "ctrl-space"
vim.api.nvim_set_keymap('n', '<C-l>', ':NvimTreeRefresh', opts) -- maps tree refresh to "ctrl-l"
vim.api.nvim_set_keymap('n', '<C-t>', ':NvimTreeToggle', opts) -- maps tree toggle to "ctrl-t"

-- run lint fix for ts and js on file save 
vim.cmd([[
  let g:ale_fixers = {
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint'],
  \ 'json': ['prettier'],
  \ 'typescriptreact': ['eslint'],
  \ }  
]])

vim.cmd("let g:ale_sign_error = '❌'")
vim.cmd("let g:ale_sign_warning = '⚠️'")
vim.cmd('let g:ale_fix_on_save = 1')
vim.cmd('let g:ale_lint_on_save = 1')

