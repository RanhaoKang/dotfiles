-- 获取光标前的单词及其位置
local function get_word_before_cursor()
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.')
    
    -- 处理 Terminal 模式下的光标偏移（Terminal 模式下光标通常在字符后）
    local word_end = col
    
    -- 向前查找单词起始点
    local word_start = word_end
    while word_start > 1 and line:sub(word_start - 1, word_start - 1):match('[%w%._]') do
        word_start = word_start - 1
    end

    if word_start < word_end then
        return line:sub(word_start, word_end - 1), word_start, word_end
    end
    return nil, nil, nil
end

-- 核心转换逻辑
local function self_cal_term(sign)
    local variable, _, _ = get_word_before_cursor()
    if not variable or #variable == 0 then 
        -- 如果没找到单词，就输入原始符号
        return sign .. "="
    end

    -- 构造退格键：删除原来的单词
    local backspaces = string.rep("\b", #variable)
    -- 构造新的字符串：var = var + 
    local replacement = string.format("%s = %s %s ", variable, variable, sign)
    
    return backspaces .. replacement
end

-- 绑定 Terminal 模式
-- 注意：terminal 模式下使用 <expr> 需要通过 nvim_replace_termcodes
local function term_map(lhs, sign)
    vim.keymap.set('t', lhs, function()
        local keys = self_cal_term(sign)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', false)
    end, { desc = "Expand " .. sign .. "=" })
end

-- 执行绑定
term_map('+=', '+')
term_map('-=', '-')
term_map('*=', '*')
term_map('/=', '/')
