-- Plugins and dependencies
local use = require('packer').use

-- To Install run :PackerInstall in a neovim instance
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use 'hrsh7th/nvim-compe' -- auto completion plugin
    use 'altercation/vim-colors-solarized' -- Solarized theme for VIM
    use 'jeffkreeftmeijer/vim-numbertoggle' -- toggles the line number display between relative and absolute
    use 'nvim-tree/nvim-web-devicons' -- file icons
    use 'nvim-tree/nvim-tree.lua' -- File explorer tree
    use 'prettier/vim-prettier'
    use 'dense-analysis/ale' -- for linting
    use 'm4xshen/autoclose.nvim' -- for auto closing tags and brackets
    use 'fatih/vim-go' -- go vim utilities
    use 'lewis6991/gitsigns.nvim' -- git status for barbar
    use 'romgrk/barbar.nvim' -- buffer management plugin
    use 'rust-lang/rust.vim' -- rust configuration for vim
    use { 'codota/tabnine-nvim', run = "./dl_binaries.sh" } -- tabnine AI copilot
    use 'Exafunction/windsurf.vim' -- codeium AI copilot
    use 'johnseth97/codex.nvim'
end)

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand


-- Indentation configurations
vim.opt.autoindent = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true

-- auto close tags configurations
require('autoclose').setup {}

-- LSP Configurations
local lsp_config = vim.lsp.config
local util = require 'lspconfig/util'

lsp_config.kotlin_language_server = {}
lsp_config.ts_ls = {}
lsp_config.rust_analyzer = {
  file = {
    excludeDirs = { "redox-exec" }
  }
}

-- codex (GPT AI Copilot)
require('codex').status() -- drop in to your lualine sections
require('codex').setup{
  keys = {
    {
      '<leader>cc', -- Change this to your preferred keybinding
      function() require('codex').toggle() end,
      desc = 'Toggle Codex popup',
    },
  },
  opts = {
    keymaps     = {
      toggle = nil, -- Keybind to toggle Codex window (Disabled by default, watch out for conflicts)
      quit = '<C-q>', -- Keybind to close the Codex window (default: Ctrl + q)
    },         -- Disable internal default keymap (<leader>cc -> :CodexToggle)
    border      = 'rounded',  -- Options: 'single', 'double', or 'rounded'
    width       = 0.8,        -- Width of the floating window (0.0 to 1.0)
    height      = 0.8,        -- Height of the floating window (0.0 to 1.0)
    model       = nil,        -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
    autoinstall = true,       -- Automatically install the Codex CLI if not found
  },
}

-- Define an autocommand to format Rust files on save
-- vim.cmd [[autocmd BufWritePre *.rs RustFmt]]
vim.g.rustfmt_autosave = 1

lsp_config.pyright = {}


lsp_config.gopls = {
  cmd = {"gopls", "serve"},
  filetypes = {"go", "gomod"},
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    editor = {
      tabSize = 2,
      insertSpaces = true
    },
    gopls = {
      analyses = {
	unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- c/c++ lsp
lsp_config.clangd = {
  cmd = {"clangd"},
  root_dir = util.root_pattern(".git"),
}

-- to Install the vue lsp run: npm install -g vue-language-server (This is for vuejs2)
-- lsp_config.vuels.setup {}

-- To install vue3 lsp run: npm install -g @volar/vue-language-server

-- needs some improvement but the gist is that this function searches for the typescript module
-- recursively in all parents. Mainly because in a mono repo, it may not be contained in the first node_modules found
local util = require 'lspconfig.util'
local function get_typescript_server_path(root_dir)
  local found_ts = ''
  local function check_dir(path)
    found_ts =  util.path.join(path, 'node_modules', 'typescript', 'lib')
    if util.path.exists(found_ts) then
      return path
    end
  end

  if util.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    return ''
  end
end

lsp_config.volar = {
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
  end,
}

-- configuration for protobuf lsp
-- to install bufls see: https://github.com/bufbuild/buf-language-server
lsp_configbuf_ls = {}

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
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("NvimTreeToggle")
  end,
})


-- Show Line number
vim.opt.number = true
vim.opt.relativenumber = true

-- (this ensures that the line number is set for any new buffer opened/created)
autocmd('BufEnter', {
  pattern = '',
  command = 'set number'
})

autocmd('BufEnter', {
  pattern = '',
  command = 'set relativenumber'
})


-- remove trailing spaces on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})


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

-- source: https://dev.to/dimaportenko/switching-between-camelcase-and-snakecase-in-neovim-using-lua-3ah7
function switch_case()
  print("triggered")
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local word = vim.fn.expand('<cword>')
  local word_start = vim.fn.matchstrpos(vim.fn.getline('.'), '\\k*\\%' .. (col+1) .. 'c\\k*')[2]

  -- Detect camelCase
  if word:find('[a-z][A-Z]') then
    -- Convert camelCase to snake_case
    local snake_case_word = word:gsub('([a-z])([A-Z])', '%1_%2'):lower()
    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, {snake_case_word})
  -- Detect snake_case
  elseif word:find('_[a-z]') then
    -- Convert snake_case to camelCase
    local camel_case_word = word:gsub('(_)([a-z])', function(_, l) return l:upper() end)
    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, {camel_case_word})
  else
    print("Not a snake_case or camelCase word")
  end
end

-- Bind the completion function to a key mapping
local opts =  { noremap = true, silent = true }
vim.api.nvim_set_keymap('i', '<C-Space>', '<Esc>:lua OnDemandCompletion()<CR>a', opts) -- maps autocomplete to "ctrl-space"
vim.api.nvim_set_keymap('i', '<A-i>', '<Esc>:lua vim.lsp.buf.code_action()<CR>a', opts)
vim.api.nvim_set_keymap('n', 'F', '<Esc>:lua vim.lsp.buf.references()<CR>', opts) -- displays usage of variables, functions, etc..
vim.api.nvim_set_keymap('n', '<C-l>', ':NvimTreeRefresh<CR>', opts) -- maps tree refresh to "ctrl-l"
vim.api.nvim_set_keymap('n', '<A-t>', ':NvimTreeToggle<CR>', opts) -- maps tree toggle to "alt-t"
vim.api.nvim_set_keymap('n', '<C-A-n>', ':lnext<CR>', opts) -- maps getting next error to ctrl-alt-n
vim.api.nvim_set_keymap('n', '<C-A-m>', ':lprev<CR>', opts) -- maps getting previous error to ctrl-alt-m
vim.api.nvim_set_keymap('n', '<', ':bp<CR>', opts) -- maps going to the previous buffer to <
vim.api.nvim_set_keymap('n', '>', ':bn<CR>', opts) -- maps going to the next buffer to >
vim.api.nvim_set_keymap('n', '<C-A-x>', ':bd<CR>', opts) -- maps deleting a buffer to ctrl-alt-x
vim.api.nvim_set_keymap('n', '<C-A-p>', ':tabnew<CR>', opts) -- maps opening new tab to ctrl-alt-p
vim.api.nvim_set_keymap('n', 'q', ':lua switch_case()<CR>', opts) -- switch between camel case and snake case

-- run lint fix for ts and js on file save
vim.cmd([[
  let g:ale_fixers = {
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint'],
  \ 'vue': ['eslint'],
  \ 'json': ['prettier'],
  \ 'typescriptreact': ['eslint'],
  \ }
]])

vim.cmd("let g:ale_sign_error = '❌'")
vim.cmd("let g:ale_sign_warning = '⚠️'")
vim.cmd('let g:ale_fix_on_save = 1')
vim.cmd('let g:ale_lint_on_save = 1')
