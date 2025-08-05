-- Core --
local opt = vim.opt
opt.encoding = 'utf-8'
opt.number = true
opt.relativenumber = true
opt.clipboard = 'unnamedplus'
opt.background = 'dark'
opt.termguicolors = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
-- opt.spell = 
-- opt.spelllang = { 'en' }
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
vim.keymap.set("n",    "<C-t>",       ":NERDTreeToggle %<CR>", opts)
vim.api.nvim_set_keymap("i", "<Tab>", 'pumvisible() ? "<C-y>" : "<Tab>"', { expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", 'pumvisible() ? "<C-n>" : "<C-d>"', { expr = true })
local map = vim.keymap.set
map('n', 'H', '^')
map('n', 'L', '$')
map('n', 'J', '20j')
map('n', 'K', '20k')
map('i', '<C-H>', '<LEFT>')
map('i', '<C-L>', '<RIGHT>')
map('i', '<C-J>', '<DOWN>')
map('i', '<C-K>', '<UP>')
map('i', '<C-S-H>', '<ESC>^i')
map('i', '<C-S-L>', '<ESC>$i')
map('i', '<C-O>', '<ESC>o')
map('i', '<C-S-O>', '<ESC>O')
vim.api.nvim_create_user_command('Make ui', ':!cat scripts/dev/template/ui.lua >> %', {
    nargs = 1,
})

map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')

for _, bracket in ipairs { '()', '<>', '{}', '[]', '""', "''", '``', } do
    map('i', bracket             , bracket .. '<left>'  , opts)
    map('i', bracket .. '<CR>'   , bracket .. '<CR>'    , opts)
    map('i', bracket .. '<Space>', bracket .. '<Space>' , opts)
    map('i', bracket .. '.'      , bracket .. '.'       , opts)
    map('i', bracket .. ':'      , bracket .. ':'       , opts)
    map('i', bracket .. ','      , bracket .. ','       , opts)
end

map("v", ">", ">gv")
map("v", "<", "<gv")
map("n", "<C-/>", "gcc")
map("n", "tc", ":CccPick<CR>")

-- LSP --
vim.lsp.config['luals'] = {
  -- Command and arguments to start the server.
  cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  filetypes = { 'lua', 'txt' },
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
        callSnippet = "None" -- or "Both" or "None"
      }
    }
  },
  capabilities = vim.lsp.protocol.make_client_capabilities()
}

vim.lsp.enable('luals')
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.lua.txt", "*.lua"},
    callback = function()
        vim.opt.filetype = 'lua'
    end
})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.fnl"},
    callback = function()
        vim.opt.filetype = 'lisp'
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

vim.api.nvim_set_keymap('n', 'gg', ':cc<CR>', { noremap = true, silent = true })

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

vim.api.nvim_set_keymap('n', 'gkk', 'lua FindMe()<CR>', { noremap = true, silent = true })


-- Plugins --
-- install vim-plug via: sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
vim.cmd [[
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'jbyuki/one-small-step-for-vimkind'
Plug 'mfussenegger/nvim-dap'
Plug 'echasnovski/mini.statusline'
Plug 'zhoupro/neovim-lua-debug'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'nvim-zh/colorful-winsep.nvim'

Plug 'numToStr/Comment.nvim'
Plug 'sitiom/nvim-numbertoggle'
Plug 'mireq/large_file'
Plug 'ggandor/leap.nvim'
Plug 'eraserhd/parinfer-rust'
Plug 'uga-rosa/ccc.nvim'
call plug#end()
]]
require('ccc').setup {
    highlighter = {
        auto_enable = true,
        lsp = true,
    },
}
-- Exclude whitespace and the middle of alphabetic words from preview:
--   foobar[baaz] = quux
--   ^----^^^--^^-^-^--^
require('leap').opts.preview_filter =
  function (ch0, ch1, ch2)
    return not (
      ch1:match('%s') or
      ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
    )
  end
require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' } 
require('leap.user').set_repeat_keys('<enter>', '<backspace>')
vim.keymap.set({'n', 'x', 'o'}, 'f', '<Plug>(leap)')
vim.keymap.set('n',             'F', '<Plug>(leap-from-window)')

require('Comment').setup()
require('mini.statusline').setup()
require("large_file").setup()
vim.g.VM_maps = {
    ["Find Under"] = "<C-d>"
}
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-p>', ':RG<CR>', { noremap = true, silent = true })

require('colorful-winsep').setup {
    hi = { bg = '#16161E', fg = '#B3F6C0' },
    smooth = false,
}

local dap = require 'dap'
dap.configurations.lua = {
    {
        type        = "lua",
        request     = "launch",
        name        = "🐛 EmmyLua Debug Session",
        host        = "localhost",
        port        = 9966,
        sourcePaths = {
                        "${workspaceFolder}"
        },
        ext         = {
                        ".lua",
                        ".lua.txt",
                        ".lua.bytes"
        },
        ideConnectDebugger = true,
    }
}
dap.adapters.lua = function(callback, config)
  callback({ type = 'server', host = config.host or "127.0.0.1", port = config.port or 9966 })
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
            vim.api.nvim_set_hl(0, 'TodoDone', { fg = '#555555', underline = false })
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

local function get_word_before_cursor()
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.')  -- Vim columns are 1-based
    
    -- Find the last word character before cursor (ignore spaces)
    local word_end = col
    while word_end > 1 and line:sub(word_end - 1, word_end - 1):match('%s') do
        word_end = word_end - 1
    end
    
    local word_start = word_end
    while word_start > 1 and line:sub(word_start - 1, word_start - 1):match('%w') do
        word_start = word_start - 1
    end
    
    if word_start <= word_end then
        return line:sub(word_start, word_end - 1), word_start, word_end
    end
    return nil, nil, nil
end

-- For += mapping: converts 'var' to 'var = var + '
local function self_add()
    local variable, start_pos, end_pos = get_word_before_cursor()
    if not variable or #variable == 0 then return end
    
    local line = vim.fn.getline('.')
    local new_line = line:sub(1, start_pos - 1) 
                   .. variable .. ' = ' .. variable .. ' + ' 
                   .. line:sub(end_pos)
    
    vim.fn.setline('.', new_line)
    -- Position cursor after ' + ' (3 characters after variable insertion point)
    vim.fn.cursor(0, start_pos + #variable + 3 + #variable + 3)
end

-- For ::a mapping: converts 'var' to 'var[#var + 1] = '
local function array_add()
    local variable, start_pos, end_pos = get_word_before_cursor()
    if not variable or #variable == 0 then return end
    
    local line = vim.fn.getline('.')
    local new_line = line:sub(1, start_pos - 1) 
                   .. variable .. '[#' .. variable .. ' + 1] = ' 
                   .. line:sub(end_pos)
    
    vim.fn.setline('.', new_line)
    -- Position cursor after ' = ' (13 characters after variable insertion point)
    vim.fn.cursor(0, start_pos + #variable + 11 + #variable + 4)
end

-- Create an autocommand group to prevent stacking duplicate commands
local augroup = vim.api.nvim_create_augroup('LuaConceal', { clear = true })

-- Create the autocommand for Lua files
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'lua',
  callback = function()
    -- Set conceal options for the window
    vim.wo.conceallevel = 2 -- 0:none, 1:conceal in some syntax groups, 2:always
    vim.wo.concealcursor = ''

    -- Rule 2: Conceal the 'function' keyword when followed by '()'
    -- vim.fn.matchadd('Conceal', '\\vfunction\\ze\\s*\\(', 11, -1, { conceal = '' })
    -- Rule 3: Conceal the 'end' keyword when it likely closes a lambda
    -- This heuristic matches 'end' followed by ')', '}', or ','
    -- vim.fn.matchadd('Conceal', '\function.*\v end\\ze\\s*[,})]', 11, -1, { conceal = '' })
    vim.fn.matchadd('Conceal', '\\<return\\>\\s')
    vim.fn.matchadd('Conceal', '\\vfunction\\ze\\s*\\(')
    map('i', '+=', self_add)
    map('i', '::a', array_add)
  end,
})

