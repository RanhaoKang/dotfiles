local map = vim.keymap.set

vim.lsp.enable('lua_ls')
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

-- Create the autocommand for Lua files
local augroup = vim.api.nvim_create_augroup('LuaConceal', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = 'lua',
  callback = function()
    -- Set conceal options for the window
    vim.wo.conceallevel = 2 -- 0:none, 1:conceal in some syntax groups, 2:always
    vim.wo.concealcursor = ''

    if not vim.env.EINK then
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
    end
    map('i', '+=', self_cal'+')
    map('i', '-=', self_cal'-')
    map('i', '/=', self_cal'/')
    map('i', '*=', self_cal'*')
    map('i', '::a', array_add)
  end,
})

function Yua_CreateTest()
  -- 1. Expand current file's directory
  local current_file = vim.fn.expand('%:p')
  
  -- 2. Prompt for the new path (pre-filled with current directory)
  local new_filename = current_file:gsub('Assets/Application/Scripts/Lua/' , 'scripts/test/')

  -- 3. Extract directory part and create it if missing (mkdir -p)
  local dir_to_create = vim.fn.fnamemodify(new_filename, ':h')
  if vim.fn.isdirectory(dir_to_create) == 0 then
    vim.fn.mkdir(dir_to_create, 'p')
  end

  -- 4. Open the new file path in the current buffer
  vim.cmd('edit ' .. vim.fn.fnameescape(new_filename))
end

