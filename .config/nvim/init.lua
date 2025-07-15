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
opt.scrolloff = 5

opt.completeopt = { 'menuone', 'noinsert', 'fuzzy' }

-- Mapping --
local opts = { noremap = true, silent = true }
vim.keymap.set("n",    "<Tab>",         ">>",  opts)
vim.keymap.set("n",    "<S-Tab>",       "<<",  opts)
vim.keymap.set("v",    "<Tab>",         ">gv", opts)
vim.keymap.set("v",    "<S-Tab>",       "<gv", opts)
vim.api.nvim_set_keymap("i", "<Tab>", 'pumvisible() ? "<C-y>" : "<Tab>"', { expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", 'pumvisible() ? "<C-n>" : "<C-d>"', { expr = true })
local map = vim.keymap.set
map('n', 'H', '^')
map('n', 'L', '$')
map('n', 'J', '20j')
map('n', 'K', '20k')
map('i', '<C-h>', '<LEFT>')
map('i', '<C-l>', '<RIGHT>')

map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map("i", "<>", "<><left>", { desc = "Enter into angled brackets" })
map("i", "()", "()<left>", { desc = "Enter into round brackets" })
map("i", "()<CR>", "()<CR>", { desc = "Enter into round brackets" })
map("i", "().", "().", { desc = "Enter into round brackets" })
map("i", "():", "():", { desc = "Enter into round brackets" })
map("i", "{}", "{}<left>", { desc = "Enter into curly brackets" })
map("i", "[]", "[]<left>", { desc = "Enter into square brackets" })
map("i", '""', '""<left>', { desc = "Enter into double quotes" })
map("i", "''", "''<left>", { desc = "Enter into single quotes" })
map("i", "``", "``<left>", { desc = "Enter into backticks" })
map("i", "jk", "<ESC>", { desc = "Enter into backticks" })
map("v", ">", ">gv")
map("v", "<", "<gv")

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

vim.api.nvim_set_keymap('n', '<leader>kk', ':vsplit<CR>:LspGotoDefinition<CR>', { noremap = true, silent = true })

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
vim.api.nvim_set_keymap('n', '<leader>kkk', ':lua FindMe()<CR>', { noremap = true, silent = true })


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
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
call plug#end()
]]
require('mini.statusline').setup()
vim.g.VM_maps = {
    ["Find Under"] = "<C-d>"
}
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })

local dap = require 'dap' 
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


-- todo --
do
local function highlight_lines()
    local buf = 0  -- Current buffer
    local ns_id = vim.api.nvim_create_namespace("TodoHighlight")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)  -- Clear previous highlights

    for i = 1, vim.api.nvim_buf_line_count(buf) do
        local line = vim.fn.getline(i)
        if line:match("^%s*%[x%]") then
            vim.api.nvim_set_hl(0, 'TodoDone', { fg = '#000000', bg = '#B3F6C0', underline = false })
            vim.api.nvim_set_hl(0, 'TodoDone', { fg = '#B3F6C0', underline = false })
            vim.api.nvim_buf_add_highlight(buf, ns_id, 'TodoDone', i - 1, 0, -1)
        end
    end
end

local function toggle_todo()
    local line = vim.fn.getline('.')
    if line:match("^%s*%[%s*%]") then
        line = line:gsub("%[%s*%]", "[x]")
    elseif line:match("^%s*%[x%]") then
        line = line:gsub("%[x%]", "[ ]")
    else
        return
    end
    vim.fn.setline('.', line)

    highlight_lines()
end

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "TODO",
    callback = function()
        opt.spell = false
        map('n', '<space>', toggle_todo)
        highlight_lines()
    end
})
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
