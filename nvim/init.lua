-- Core --
vim.opt.encoding = 'utf-8'
vim.opt.number = true
vim.opt.clipboard = 'unnamed'
vim.opt.background = 'dark'
vim.opt.termguicolors = true

-- Mapping --
vim.api.nvim_set_keymap('n', 'H', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'L', '<C-w>l', { noremap = true, silent = true })

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
      }
    }
  }
}

vim.lsp.enable('luals')

--[[ vim.cmd [[
autocmd BufRead,BufNewFile *.lua.txt set filetype=lua
nnoremap KK :vsplit<CR>:LspGotoDefinition<CR>
nnoremap K :LspHover<CR>
" nnoremap KKK :FindMe<CR>

function! FindMe()
	let command = 'fd --type f ' . expand('<cword>') . '|  grep -v meta | grep lua'
	let output = system(command)
	if !empty(output)
        let files = split(trim(output), '\n')
        for file in files
            execute 'silent! botright vnew ' . file
            execute 'silent! setf lua'
        endfor
	endif
endfunction
nnoremap KKK :call FindMe()<CR>
]]
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.lua.txt"},
    callback = function()
        vim.opt.filetype = 'lua'
    end
})

vim.api.nvim_set_keymap('n', 'KK', ':vsplit<CR>:LspGotoDefinition<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':LspHover<CR>', { noremap = true, silent = true })

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
vim.cmd [[
call plug#begin()
Plug 'lifepillar/gruvbox8'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()
]]
vim.api.nvim_set_keymap('n', '<C-p>', ':Files<CR>', { noremap = true, silent = true })
