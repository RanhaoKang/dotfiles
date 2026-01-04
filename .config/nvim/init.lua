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
vim.api.nvim_create_user_command('Make ui', ':!cat scripts/dev/template/ui.lua >> %', {
    nargs = 1,
})

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

-- Plugins --
vim.pack.add {
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/preservim/nerdtree' },
    { src = 'https://github.com/numToStr/Comment.nvim' },
    { src = 'https://github.com/nvim-zh/colorful-winsep.nvim' },
    { src = 'https://github.com/Vonr/align.nvim' },
    { src = 'https://github.com/mireq/large_file' },
    { src = 'https://github.com/nvim-mini/mini.statusline' },
    { src = 'https://github.com/junegunn/fzf.vim' },
        { src = 'https://github.com/junegunn/fzf' },
    { src = 'https://github.com/sindrets/diffview.nvim' },
    { src = 'https://github.com/blazkowolf/gruber-darker.nvim' },
    { src = 'https://github.com/tpope/vim-surround' },
}
vim.cmd.colorscheme 'gruber-darker'
require('Comment').setup()
require('mini.statusline').setup()
require("large_file").setup()
require("diffview").setup()
require('colorful-winsep').setup {
    hi = { bg = '#16161E', fg = '#B3F6C0' },
    smooth = false,
}

local map = vim.keymap.set

-- custom plugins

require('hotreload').setup()
require('diffviewer').setup()
require('dired')
require('languages.lua')
require('languages.term')

-- we define keymap at the bottom, as we do not want plugins flush our keymap

map("n",    "<Tab>",         ">>",  opts)
map("n",    "<S-Tab>",       "<<",  opts)
map("v",    "<Tab>",         ">gv", opts)
map("v",    "<S-Tab>",       "<gv", opts)
map("n",    "<C-t>",       ":NERDTreeToggle %<CR>", opts)
map("n",    "[",       ":cprev<CR>", opts)
map("n",    "]",       ":cnext<CR>", opts)
map("n",    "<C-S-d>",       "v0yO<ESC>pjly$kgp[`", opts)
vim.api.nvim_set_keymap("i", "<Tab>", 'pumvisible() ? "<C-y>" : "<Tab>"', { expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", 'pumvisible() ? "<C-n>" : "<C-d>"', { expr = true })
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
map('n', '<C-A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
map('n', '<C-A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
map('v', '<C-A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', '<C-A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<A-h>', '<C-w><')
map('n', '<A-l>', '<C-w>>')
map('n', '<A-j>', '<C-w>-')
map('n', '<A-k>', '<C-w>+')

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

map('x', 'aa', function()
    require'align'.align_to_char({
        preview = true,
        length = 1,
    })
end, NS)

vim.g.VM_maps = {
    ["Find Under"] = "<C-d>"
}
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-p>', ':RG<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '::', ':Y ', { noremap = true, silent = true })

-- 在终端模式下按 Esc 回到普通模式
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {noremap = true})

-- 方便在终端和其他窗口间直接跳转
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], {noremap = true})
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], {noremap = true})
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], {noremap = true})
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], {noremap = true})

-- command alias
vim.api.nvim_create_user_command('Y', function(opts)
    vim.notify("args: " .. opts.args)
    if opts.args == 'test' then
        Yua_CreateTest()
    end
end, { nargs = '*' })
