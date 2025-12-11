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

-- 创建一个名为 GitReview 的自动命令组，防止重复加载
local group = vim.api.nvim_create_augroup("GitReview", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "diff", -- 仅针对文件名为 "diff" 的文件生效
    group = group,
    callback = function(ev)
        -- 设置 buffer 局部变量，用于存储基准版本 (last_ver)
        -- 初始为 nil，第一次按 u 时会询问
        vim.b.git_base_commit = nil

        -- 定义核心函数
        local function show_git_diff()
            -- 1. 获取当前行的文件路径
            local filepath = vim.fn.expand("<cfile>")
            if filepath == "" then
                print("当前行没有检测到文件路径")
                return
            end

            -- 2. 确定对比的版本 (last_ver)
            local base_commit = vim.b.git_base_commit
            if not base_commit then
                vim.ui.input({ prompt = "请输入对比基准 (例如 HEAD~1, master): ", default = "HEAD^" }, function(input)
                    if input and input ~= "" then
                        vim.b.git_base_commit = input
                        -- 递归调用一次，因为 input 是异步的
                        show_git_diff()
                    end
                end)
                return
            end

            -- 3. 执行 Git 命令获取 Diff 内容
            -- 命令格式: git diff <base> -- <filepath>
            local cmd = string.format("git diff %s -- %s", base_commit, filepath)
            local output = vim.fn.systemlist(cmd)

            if vim.v.shell_error ~= 0 then
                print("Git 命令执行失败，请检查路径或版本号")
                return
            end

            if #output == 0 then
                print("没有 Diff 内容 (文件可能未修改)")
                return
            end

            -- 4. 创建浮动窗口展示结果
            local buf = vim.api.nvim_create_buf(false, true) -- 创建 scratch buffer

            -- 计算窗口大小 (居中，占 80%)
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.8)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
                title = " " .. filepath .. " (" .. base_commit .. ") ",
                title_pos = "center"
            })

            -- 填充内容并设置高亮
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
            vim.bo[buf].filetype = "git" -- 关键：利用 git 语法高亮
            vim.bo[buf].modifiable = false

            -- 5. 实现 "任意键返回" (这里映射常用键来关闭窗口)
            -- 修改 close_win 逻辑
            local function confirm_and_delete()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
                -- 回到原窗口删除当前行
                vim.api.nvim_command("normal! dd")
            end

            local close_win = function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end

            vim.keymap.set("n", "D", confirm_and_delete, { buffer = buf })
            -- 映射 q, Esc, Enter, Space 来关闭窗口
            local close_keys = { "q", "<Esc>", "<CR>", "<Space>" }
            for _, key in ipairs(close_keys) do
                vim.keymap.set("n", key, close_win, { buffer = buf, nowait = true })
            end

            -- 注意：为了真正的"任意键"体验，通常不建议拦截所有按键（会无法滚动查看）。
            -- 但如果你真的想要按任意键（包括 j/k）都退出，可以使用 vim.fn.getchar() 逻辑，
            -- 不过推荐保留 j/k 滚动，用 q 退出。
        end

        -- 设置快捷键 o
        vim.keymap.set("n", "o", show_git_diff, { buffer = ev.buf, desc = "Show git diff for file on line" })
    end,
})

