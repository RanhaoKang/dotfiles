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
    { src = 'https://github.com/jake-stewart/multicursor.nvim' },
    { src = 'https://github.com/folke/zen-mode.nvim' },
    { src = 'https://github.com/ibhagwan/fzf-lua' },
    { src = 'https://github.com/Vigemus/iron.nvim' },
    { src = 'https://github.com/chrisgrieser/nvim-spider' },
}

local map = vim.keymap.set

if not vim.env.EINK then
    vim.cmd.colorscheme 'gruber-darker'
end
require("mini.surround").setup()
require("large_file").setup()
require("diffview").setup()
local mc = require("multicursor-nvim")
mc.setup()
map({'n', 'v'}, '<C-S-j>', function() mc.lineAddCursor(1) end)
mc.addKeymapLayer(function(layerSet)
    -- Select a different cursor as the main one.
    layerSet({"n", "x"}, "<left>", mc.prevCursor)
    layerSet({"n", "x"}, "<right>", mc.nextCursor)

    -- Delete the main cursor.
    layerSet({"n", "x"}, "<leader>x", mc.deleteCursor)

    -- Enable and clear cursors using escape.
    layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        else
            mc.clearCursors()
        end
    end)
end)

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
require('iron.core').setup {
    keymaps = {
        toggle_repl = "<space>rr", -- toggles the repl open and closed.
        -- If repl_open_command is a table as above, then the following keymaps are
        -- available
        -- toggle_repl_with_cmd_1 = "<space>rv",
        -- toggle_repl_with_cmd_2 = "<space>rh",
        restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
        send_motion = "<space>sc",
        visual_send = "<space>sc",
        send_file = "<space>sf",
        send_line = "<space>sl",
        send_paragraph = "<space>sp",
        send_until_cursor = "<space>su",
        send_mark = "<space>sm",
        send_code_block = "<space>sb",
        send_code_block_and_move = "<space>sn",
        mark_motion = "<space>mc",
        mark_visual = "<space>mc",
        remove_mark = "<space>md",
        cr = "<space>s<cr>",
        interrupt = "<space>s<space>",
        exit = "<space>sq",
        clear = "<space>cl",
  },
}

require("spider").setup({
	skipInsignificantPunctuation = true, -- 跳过不重要的标点符号
})

local spider_map = function(key, motion)
    vim.keymap.set({ "n", "o", "x" }, key, function()
        require("spider").motion(motion)
    end, { desc = "Spider Motion " .. motion })
end

spider_map("w", "w")
spider_map("e", "e")
spider_map("b", "b")

vim.keymap.set({ "n", "o", "x" }, "W", "w", { desc = "Native WORD forward" })
vim.keymap.set({ "n", "o", "x" }, "E", "e", { desc = "Native WORD end" })
vim.keymap.set({ "n", "o", "x" }, "B", "b", { desc = "Native WORD backward" })

-- custom plugins

require('hotreload').setup()
require('diffviewer').setup()
require("filelist").setup()
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
  command! Qa qa
]])

map('n', '<C-f>', ':ZenMode<CR>')

-- 1. 替换 Files (找文件)
vim.keymap.set('n', '<C-p>', function()
    require('fzf-lua').files({
        -- 1. 关闭预览界面
        previewer = false,
        
        -- 2. 这里的搜索提示符
        prompt = 'Files> ',
        
        -- 3. 搜索特定类型的文件 (例如只搜 .lua 和 .js)
        -- -g 是 rg (ripgrep) 的 glob 参数，用于匹配文件名
        -- 如果你想搜所有文件但排除某些，也可以在这里配置
        -- rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        -- fd_opts = "--color=always --type f --hidden --follow --exclude .git -e lua -e txt -e cs",
    })
    -- fzf_exec('fd --type f --hidden --exclude .git | fzf', function(result)
    --     vim.cmd('edit ' .. result)
    -- end)
end)

-- 2. 替换 Rg (搜内容)
vim.keymap.set('n', '<C-S-p>', function()
    require('fzf-lua').live_grep()
end)

-- 定义核心函数
local function extract_lua_block()
    local bufnr = vim.api.nvim_get_current_buf()
    local start_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
    local total_lines = vim.api.nvim_buf_line_count(bufnr)

    -- 1. 获取当前文件名（不含路径和后缀），例如 "PlayerManager"
    local file_name = vim.fn.expand("%:t:r"):gsub("%.lua", "")
    
    local current_content = ""
    local lines_to_save = {}
    local is_complete = false

    for i = start_line, total_lines - 1 do
        local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]

        -- 特殊逻辑：如果是起始行，检查是否匹配 "function Manager"
        if i == start_line then
            -- 匹配 "function Manager:..." 或 "function Manager. ..."
            -- %s+ 匹配空格，([:.].+) 捕获后续的方法名部分
            local new_line, count = line:gsub("function%s+Manager([:%.].+)", "function " .. file_name .. "%1")
            if count > 0 then
                line = new_line
            end
        end

        table.insert(lines_to_save, line)
        current_content = table.concat(lines_to_save, "\n")

        -- 使用 load 尝试编译代码块
        -- load 返回 (function, error_message)
        local _, err = load(current_content)

        if not err then
            -- 编译成功，代码块完整
            is_complete = true
            break
        elseif not string.find(err, "<eof>") then
            -- 如果有报错但不是 EOF 报错，说明是语法错误，我们也停止读取
            print("Lua Syntax Error: " .. err)
            return
        end
        -- 如果是 EOF 报错，继续循环读下一行
    end

    if is_complete then
        local filename = "Assets/Application/Scripts/Lua/Application/Utility/HotReload.lua.txt"
        local file = io.open(filename, "a")
        if file then
            file:write('\n ; \n')
            file:write(current_content)
            file:close()
            print("Successfully saved block to " .. filename)
        else
            print("Error: Could not write to " .. filename)
        end
    else
        print("Error: Reached end of file without finding a complete Lua block.")
    end
end

-- 绑定快捷键 <D-h> (macOS 的 Command 键通常对应 D)
-- 如果你在 Linux/Windows 上使用 Super 键，可能需要根据终端模拟器调整
vim.keymap.set('n', '<C-s>', extract_lua_block, { desc = 'Extract Lua block to test.lua' })
