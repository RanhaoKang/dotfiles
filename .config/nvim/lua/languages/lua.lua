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

-- Refined self_cal: Supports +=, -=, *=, /= and now ++, --
local function self_cal(sign)
    return function()
        local variable, start_pos, end_pos = get_word_before_cursor()
        if not variable or #variable == 0 then return end

        local line = vim.fn.getline('.')
        local indent_part = line:sub(1, start_pos - 1)
        local rest_part = line:sub(end_pos)
        
        local new_line
        local final_cursor_col

        if sign == '++' then
            -- Handle ++ (e.g. i++ -> i = i + 1)
            local op = '+'
            local replacement = variable .. ' = ' .. variable .. ' ' .. op .. ' 1'
            new_line = indent_part .. replacement .. rest_part
            final_cursor_col = start_pos + #replacement - 1 -- Cursor at end of line
        else
            -- Handle +=, -=, etc.
            local replacement = variable .. ' = ' .. variable .. (' %s '):format(sign)
            new_line = indent_part .. replacement .. rest_part
            -- Cursor after ' + ' (wait for input)
            final_cursor_col = start_pos + #variable + 3 + #variable + 3
        end

        vim.fn.setline('.', new_line)
        vim.fn.cursor(0, final_cursor_col)
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
    -- Position cursor after ' = '
    vim.fn.cursor(0, start_pos + #variable + 11 + #variable + 4)
end

--[[ 
    Smart Wrapper Logic (FIXED)
    Wraps previous expression in () if specific triggers are typed.
    Handles: "str":, {table}:, {table}[, function() end(
]]
local function smart_wrapper(trigger_char)
    return function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line_text = vim.api.nvim_get_current_line()
        local left_text = line_text:sub(1, col)
        
        -- 1. Check for immediate preceding whitespace to find the "content" end
        local content_end_idx = #left_text
        while content_end_idx > 0 and left_text:sub(content_end_idx, content_end_idx):match('%s') do
            content_end_idx = content_end_idx - 1
        end

        if content_end_idx == 0 then
            vim.api.nvim_put({trigger_char}, 'c', false, true)
            return
        end

        local last_char = left_text:sub(content_end_idx, content_end_idx)
        local start_pos = nil -- {row, col} (0-based col for nvim_buf_set_text)
        
        -- Logic for Strings: "..." or '...' followed by :
        if trigger_char == ':' and (last_char == '"' or last_char == "'") then
            local s_idx = content_end_idx - 1
            while s_idx > 0 do
                if left_text:sub(s_idx, s_idx) == last_char and left_text:sub(s_idx-1, s_idx-1) ~= '\\' then
                    start_pos = {row - 1, s_idx - 1}
                    break
                end
                s_idx = s_idx - 1
            end

        -- Logic for Tables: {...} followed by : or [
        elseif (trigger_char == ':' or trigger_char == '[') and last_char == '}' then
            local view = vim.fn.winsaveview()
            vim.fn.cursor(row, content_end_idx) 
            -- FIX: searchpairpos returns a List {line, col}, need to unpack it
            local pos = vim.fn.searchpairpos('{', '', '}', 'bnW')
            local ln, cl = pos[1], pos[2] 
            
            if ln > 0 then
                start_pos = {ln - 1, cl - 1}
            end
            vim.fn.winrestview(view)

        -- Logic for Functions: function()...end followed by (
        elseif trigger_char == '(' and last_char == 'd' then
            if left_text:sub(content_end_idx - 2, content_end_idx) == 'end' then
                local view = vim.fn.winsaveview()
                vim.fn.cursor(row, content_end_idx)
                -- FIX: searchpairpos returns a List {line, col}
                local pos = vim.fn.searchpairpos('\\<function\\>', '', '\\<end\\>', 'bnW')
                local ln, cl = pos[1], pos[2]
                
                if ln > 0 then
                    start_pos = {ln - 1, cl - 1}
                end
                vim.fn.winrestview(view)
            end
        end

        -- Execute the Wrap if a start position was found
        if start_pos then
            local end_row = row - 1
            local end_col = content_end_idx

            -- Insert closing ')'
            vim.api.nvim_buf_set_text(0, end_row, end_col, end_row, end_col, {')'})
            -- Insert opening '('
            vim.api.nvim_buf_set_text(0, start_pos[1], start_pos[2], start_pos[1], start_pos[2], {'('})
            
            -- Move cursor to end and insert the trigger char
            local final_col = col + 2
            vim.api.nvim_win_set_cursor(0, {row, final_col})
            vim.api.nvim_put({trigger_char}, 'c', false, true)
        else
            -- No match found, just behave normally
            vim.api.nvim_put({trigger_char}, 'c', false, true)
        end
    end
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
        vim.fn.matchadd('Conceal', '\\<return\\>\\s')
        vim.fn.matchadd('Conceal', '\\<function\\>\\s')
        vim.fn.matchadd('Conceal', '\\<function\\>\\ze\\s()')
        vim.fn.matchadd('Conceal', [[\v\)\s*\zs return]], 10, -1, { conceal = '→' })
        vim.fn.matchadd('Conceal', ' end\\ze\\s*,')
    end
    
    -- Calculation maps
    map('i', '+=', self_cal'+')
    map('i', '-=', self_cal'-')
    map('i', '/=', self_cal'/')
    map('i', '*=', self_cal'*')
    
    -- New Increment/Decrement maps
    map('i', '++', self_cal'++')

    -- Array map
    map('i', '::a', array_add)
    
    -- Snippet-like maps
    map('i', '::for', 'for i = 1, n do')
    -- 插入 function() end 并将光标移至中间
    local function insert_lambda()
        -- 插入文本：function() + 两个空格 + end
        vim.api.nvim_put({'function()  end'}, 'c', false, true)
        
        -- 获取插入后的光标位置
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        
        -- 光标回退 4 位 (越过 " end")，停留在括号后的空格处
        vim.api.nvim_win_set_cursor(0, {row, col - 4})
    end

    map('i', '->', insert_lambda)
    map('i', '=>', insert_lambda)

    -- Smart Wrapper maps [New!]
    map('i', ':', smart_wrapper(':'))
    map('i', '[', smart_wrapper('['))
    map('i', '(', smart_wrapper('('))
  end,
})

function Yua_CreateTest()
  local current_file = vim.fn.expand('%:p')
  local new_filename = current_file:gsub('Assets/Application/Scripts/Lua/' , 'scripts/test/')
  local dir_to_create = vim.fn.fnamemodify(new_filename, ':h')
  if vim.fn.isdirectory(dir_to_create) == 0 then
    vim.fn.mkdir(dir_to_create, 'p')
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(new_filename))
end
