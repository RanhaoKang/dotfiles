-- Core --
local opt = vim.opt
opt.encoding = 'utf-8'
opt.number = true
opt.clipboard = 'unnamedplus'
opt.background = 'dark'
opt.termguicolors = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.spell = true
opt.spelllang = { 'en' }
opt.undofile = true
opt.backup = false
opt.writebackup = false
opt.ignorecase = true
opt.smartcase = true
opt.foldmethod = "indent"
opt.foldlevel = 4
opt.pumheight = 7

opt.completeopt = { 'menuone', 'noinsert', 'fuzzy' }
-- vim.cmd[[set completeopt+=menuone,noselect,popup]]

-- Mapping --
vim.api.nvim_set_keymap('n', 'H', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'L', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<Tab>", 'pumvisible() ? "<C-y>" : "<Tab>"', { expr = true })
local map = vim.keymap.set
map({"n", "v"}, "x", "_x")
map("i", "<>", "<><left>", { desc = "Enter into angled brackets" })
map("i", "()", "()<left>", { desc = "Enter into round brackets" })
map("i", "{}", "{}<left>", { desc = "Enter into curly brackets" })
map("i", "[]", "[]<left>", { desc = "Enter into square brackets" })
map("i", '""', '""<left>', { desc = "Enter into double quotes" })
map("i", "''", "''<left>", { desc = "Enter into single quotes" })
map("i", "``", "``<left>", { desc = "Enter into backticks" })

-- LSP --
vim.lsp.config['luals'] = {
  -- Command and arguments to start the server.
  cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  filetypes = { 'lua' },
  -- Sets the "root directory" to the parent directory of the file in the
  -- current buffer that contains either a ".luarc.json" or a
  -- ".luarc.jsonc" file. Files that share a root directory will reuse
  -- the connection to the same LSP server.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  -- Specific settings to send to the server. The schema for this is
  -- defined by the server. For example the schema for lua-language-server
  -- can be found here https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
  settings = {
    Lua = {
      runtime = {
        version = 'Lua5.3',
      },
      completion = {
        callSnippet = "Replace" -- or "Both" or "None"
      }
    }
  },
  capabilities = vim.lsp.protocol.make_client_capabilities()
}

vim.lsp.enable('luals')
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.lua.txt"},
    callback = function()
        vim.opt.filetype = 'lua'
    end
})
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
        local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
        client.server_capabilities.completionProvider.triggerCharacters = chars
        vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.api.nvim_set_keymap('n', 'KK', ':vsplit<CR>:LspGotoDefinition<CR>', { noremap = true, silent = true })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

function FindMe()
    local command = 'fd --type f ' .. vim.fn.expand('<cword>') .. ' | grep -v meta | grep lua'
    local output = vim.fn.system(command)
    if output ~= '' then
        local files = vim.fn.split(vim.fn.trim(output), '\n')
        for _, file in ipairs(files) do
            vim.cmd('silent! botright vnew ' .. file)
            vim.cmd('silent! setf lua')
        end
    end
end

-- 设置 KKK 键映射
vim.api.nvim_set_keymap('n', 'KKK', ':lua FindMe()<CR>', { noremap = true, silent = true })


-- Plugins --
-- install vim-plug via: sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
vim.cmd [[
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'justinmk/vim-sneak'
Plug 'jbyuki/one-small-step-for-vimkind'
Plug 'mfussenegger/nvim-dap'
Plug 'echasnovski/mini.statusline'
Plug 'zhoupro/neovim-lua-debug'
call plug#end()
]]
require('mini.statusline').setup()
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
local dap = require"dap"
dap.configurations.lua = { 
  { 
    type = 'nlua', 
    request = 'attach',
    name = "Attach to running Neovim instance",
  }
}

dap.adapters.nlua = function(callback, config)
  callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 8086 })
end
----[[

-- Experiment --

--]]
vim.keymap.set('n', '<leader>db', require"dap".toggle_breakpoint, { noremap = true })
vim.keymap.set('n', '<leader>dc', require"dap".continue, { noremap = true })
vim.keymap.set('n', '<leader>do', require"dap".step_over, { noremap = true })
vim.keymap.set('n', '<leader>di', require"dap".step_into, { noremap = true })

vim.keymap.set('n', '<leader>dl', function() 
  require"osv".launch({port = 8086}) 
end, { noremap = true })

vim.keymap.set('n', '<leader>dw', function()
  local widgets = require"dap.ui.widgets"
  widgets.hover()
end)

vim.keymap.set('n', '<leader>df', function()
  local widgets = require"dap.ui.widgets"
  widgets.centered_float(widgets.frames)
end)
