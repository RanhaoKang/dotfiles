-- Core --
local opt = vim.opt
opt.encoding = 'utf-8'
opt.number = true
if not vim.env.EINK then
    opt.relativenumber = true
end
opt.clipboard = 'unnamedplus'
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

vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
    { src = 'https://github.com/nvim-zh/colorful-winsep.nvim' },
    { src = 'https://github.com/Vonr/align.nvim' },
    { src = 'https://github.com/mireq/large_file' },
    { src = 'https://github.com/sindrets/diffview.nvim' },
    { src = 'https://github.com/blazkowolf/gruber-darker.nvim' },
    { src = 'https://github.com/nvim-mini/mini.surround' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/NeogitOrg/neogit' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
}

if not vim.env.EINK then
    vim.cmd.colorscheme 'gruber-darker'
end
require("mini.surround").setup()
require("large_file").setup()
require("diffview").setup()
require("filelist").setup()
require('oil').setup {
    -- columns = { 'permissions', 'size', 'mtime' },
    columns = { },
    keymaps = {
        ["o"] = "actions.select",
        ["<C-p>"] = false,
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-t>"] = {
            callback = function()
                vim.cmd("q")
            end,
            desc = "Close Oil with :q",
        },
    },
}
require('colorful-winsep').setup {
    hi = { bg = '#16161E', fg = '#B3F6C0' },
    smooth = false,
}

local map = vim.keymap.set

-- custom plugins

require('hotreload').setup()
require('diffviewer').setup()
require('languages.lua')
require('languages.term')

-- we define keymap at the bottom, as we do not want plugins flush our keymap

map("n",    "<Tab>",         ">>",  opts)
map("n",    "<S-Tab>",       "<<",  opts)
map("v",    "<Tab>",         ">gv", opts)
map("v",    "<S-Tab>",       "<gv", opts)
map("n",    "[",       ":cprev<CR>", opts)
map("n",    "]",       ":cnext<CR>", opts)
vim.api.nvim_set_keymap("i", "<Tab>", 'pumvisible() ? "<C-y>" : "<Tab>"', { expr = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", 'pumvisible() ? "<C-n>" : "<C-d>"', { expr = true })
map('n', 'H', '^')
map('n', 'L', '$')
map('n', 'J', '20j')
map('n', 'K', '20k')
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

map('x', 'aa', function()
    require'align'.align_to_char({
        preview = true,
        length = 1,
    })
end, NS)

vim.g.VM_maps = {
    ["Find Under"] = "<C-d>"
}
vim.api.nvim_set_keymap('n', '::', ':Y ', { noremap = true, silent = true })

-- 在终端模式下按 Esc 回到普通模式
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {noremap = true})

-- 方便在终端和其他窗口间直接跳转
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], {noremap = true})
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], {noremap = true})
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], {noremap = true})
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], {noremap = true})
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

local function toggle_bool_or_number(direction)
  local word = vim.fn.expand("<cword>")
  local bool_map = {
    ["true"] = "false",
    ["false"] = "true",
    ["True"] = "False",
    ["False"] = "True",
    ["TRUE"] = "FALSE",
    ["FALSE"] = "TRUE",
  }

  if bool_map[word] then
    -- Using "ciw" to replace the boolean
    vim.cmd("normal! ciw" .. bool_map[word])
  else
    -- Use vim.api.nvim_command to execute the default behavior 
    -- 'count1' ensures it respects numbers like '5<C-a>'
    local count = vim.v.count1
    vim.cmd("normal! " .. count .. direction)
  end
end

-- Keybindings
-- We pass the exact key we want the 'normal' command to execute
vim.keymap.set("n", "<C-a>", function() toggle_bool_or_number("\1") end, { desc = "Increment or toggle" })
vim.keymap.set("n", "<C-x>", function() toggle_bool_or_number("\24") end, { desc = "Decrement or toggle" })-- command alias

vim.api.nvim_create_user_command('Y', function(opts)
    vim.notify("args: " .. opts.args)
    if opts.args == 'test' then
        Yua_CreateTest()
    end
end, { nargs = '*' })

local open_oil_sidebar = function()
  vim.cmd("vsplit")
  vim.cmd("vertical resize 30")
  require("oil").open(nil, { columns = { "icon" } })
end

map("n", "<C-t>", open_oil_sidebar, opts)

vim.cmd([[
  command! W w
  command! Q q
  command! WQ wq
  command! Wq wq
]])


local function fzf_exec(cmd, callback)
    -- 创建一个临时 Buffer
    local buf = vim.api.nvim_create_buf(false, true)
    
    -- 计算窗口大小（居中浮动）
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded'
    })

    -- 选中的结果写入临时文件
    local temp_file = os.tmpname()
    
    -- 运行终端命令
    -- 关键点：fzf 结束后将结果写入临时文件并关闭窗口
    vim.fn.termopen(cmd .. ' > ' .. temp_file, {
        on_exit = function()
            vim.api.nvim_win_close(win, true)
            local f = io.open(temp_file, "r")
            if f then
                local result = f:read("*all"):gsub('\n', '')
                f:close()
                os.remove(temp_file)
                if result ~= "" then
                    callback(result)
                end
            end
        end
    })
    
    -- 进入插入模式（针对终端）
    vim.cmd('startinsert')
end

-- 1. 替换 Files (找文件)
vim.keymap.set('n', '<C-p>', function()
    fzf_exec('fd --type f --hidden --exclude .git | fzf', function(result)
        vim.cmd('edit ' .. result)
    end)
end)

-- 2. 替换 Rg (搜内容)
vim.keymap.set('n', '<C-S-p>', function()
    -- 这里直接进入 fzf，因为 fzf 现在支持实时输入搜索
    local cmd = 'rg --column --line-number --no-heading --color=always --smart-case "" | fzf --ansi'
    fzf_exec(cmd, function(result)
        -- rg 的结果格式是 file:line:col:text，我们需要提取文件名和行号
        local parts = vim.split(result, ":")
        if parts[1] then
            vim.cmd('edit ' .. parts[1])
            if parts[2] then
                vim.api.nvim_win_set_cursor(0, {tonumber(parts[2]), 0})
            end
        end
    end)
end)
