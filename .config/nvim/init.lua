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
opt.cursorline = true

opt.completeopt = { 'menuone', 'noinsert', 'fuzzy' }

-- Mapping --
local opts = { noremap = true, silent = true }
vim.keymap.set("n",    "<Tab>",         ">>",  opts)
vim.keymap.set("n",    "<S-Tab>",       "<<",  opts)
vim.keymap.set("v",    "<Tab>",         ">gv", opts)
vim.keymap.set("v",    "<S-Tab>",       "<gv", opts)
vim.keymap.set("n",    "<C-t>",       ":NERDTreeToggle %<CR>", opts)
vim.keymap.set("n",    "[",       ":cprev<CR>", opts)
vim.keymap.set("n",    "]",       ":cnext<CR>", opts)
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
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
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

vim.lsp.enable {
    'lua_ls'
}

vim.lsp.config['pylsp'] = {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    capabilities = vim.lsp.protocol.make_client_capabilities()
}
vim.lsp.enable('pylsp')



vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.lua.txt", "*.lua", '*.script', '*.gui_script', '*.render_script' },
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
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

Plug 'sitiom/nvim-numbertoggle'
Plug 'uga-rosa/ccc.nvim'
call plug#end()
]]

vim.pack.add {
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/preservim/nerdtree' },
    { src = 'https://github.com/numToStr/Comment.nvim' },
    { src = 'https://github.com/nvim-zh/colorful-winsep.nvim' },
    { src = 'https://github.com/Vonr/align.nvim' },
    { src = 'https://github.com/mireq/large_file' },
    { src = 'https://github.com/nvim-mini/mini.statusline' },
    { src = 'https://github.com/junegunn/fzf.vim' },
}

-- Aligns to 1 character
vim.keymap.set(
    'x',
    'aa',
    function()
        require'align'.align_to_char({
            preview = true,
            length = 1,
        })
    end,
    NS
)

require('ccc').setup {
    highlighter = {
        auto_enable = true,
        lsp = true,
    },
}
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

----[[

-- Experiment --

--]]

local function get_word_before_cursor()
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.')  -- Vim columns are 1-based

    -- Find the last word character before cursor (ignore spaces)
    local word_end = col
    while word_end > 1 and line:sub(word_end - 1, word_end - 1):match('%s') do
        word_end = word_end - 1
    end

    local word_start = word_end
    while word_start > 1 and line:sub(word_start - 1, word_start - 1):match('[%w%._]') do
        word_start = word_start - 1
    end

    if word_start <= word_end then
        return line:sub(word_start, word_end - 1), word_start, word_end
    end
    return nil, nil, nil
end

-- For += mapping: converts 'var' to 'var = var + '
local function self_cal(sign)
    return function()
        local variable, start_pos, end_pos = get_word_before_cursor()
        if not variable or #variable == 0 then return end

        local line = vim.fn.getline('.')
        local new_line = line:sub(1, start_pos - 1)
                       .. variable .. ' = ' .. variable .. (' %s '):format(sign)
                       .. line:sub(end_pos)

        vim.fn.setline('.', new_line)
        -- Position cursor after ' + ' (3 characters after variable insertion point)
        vim.fn.cursor(0, start_pos + #variable + 3 + #variable + 3)
    end
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
    vim.fn.matchadd('Conceal', '\\vfunction\\ze\\s*\\(', 11, -1, { conceal = '' })
    -- Rule 3: Conceal the 'end' keyword when it likely closes a lambda
    -- This heuristic matches 'end' followed by ')', '}', or ','
    -- vim.fn.matchadd('Conceal', '\function.*\v end\\ze\\s*[,})]', 11, -1, { conceal = '' })
    vim.fn.matchadd('Conceal', '\\<return\\>\\s')
    vim.fn.matchadd('Conceal', '\\<function\\>\\s')
    vim.fn.matchadd('Conceal', '\\<function\\>\\ze\\s()')
    vim.fn.matchadd('Conceal', [[\v\)\s*\zs return]], 10, -1, { conceal = '→' })
    -- vim.fn.matchadd('Conceal', [[\vend\ze\s*[,})}]], 10, -1, { conceal = '' })
    vim.fn.matchadd('Conceal', ' end\\ze\\s*,')
    map('i', '+=', self_cal'+')
    map('i', '-=', self_cal'-')
    map('i', '/=', self_cal'/')
    map('i', '*=', self_cal'*')
    map('i', '::a', array_add)
  end,
})

-- 仅在开启 diff 模式时生效的快捷键
vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "diff",
    callback = function()
        if vim.v.option_new == "true" then
            local opts = { buffer = true, silent = true }

            -- 1. 取整个 Block (dh = 左, dl = 右)
            -- 在 3-way diff 中，//2 通常是左边，//3 通常是右边
            vim.keymap.set("n", "dh", ":diffget //2<CR>", opts)
            vim.keymap.set("n", "dl", ":diffget //3<CR>", opts)

            -- 2. 取单行 (dih = 左单行, dil = 右单行)
            -- 原理：先用 V 选中当前行，然后对选区执行 diffget
            vim.keymap.set("n", "dih", ":.diffget //2<CR>", opts)
            vim.keymap.set("n", "dil", ":.diffget //3<CR>", opts)
        end
    end
})

require('hotreload').setup()
require('diffviewer').setup()
