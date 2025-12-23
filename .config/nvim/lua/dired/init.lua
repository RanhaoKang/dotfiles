local M = {}

-- 存储原始文件名的映射，用于对比修改
local original_names = {}

function M.open_ls()
    -- 1. 获取 ls -l 的结果
    local lines = vim.fn.systemlist("ls -l")
    if #lines == 0 then return end

    -- 2. 创建一个临时 Buffer
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, "Quick-Dired")
    vim.api.nvim_buf_set_option(buf, 'buftype', 'acwrite') -- 允许通过 BufWriteCmd 自定义写入

    -- 3. 填充数据并保存原始行以便对比
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    original_names = lines

    -- 4. 设置自动命令：当用户执行 :w 或 :wq 时触发
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        callback = function()
            M.apply_changes(buf)
        end,
    })

    -- 5. 打开窗口
    vim.api.nvim_set_current_buf(buf)
end

function M.apply_changes(buf)
    local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    
    for i, new_line in ipairs(current_lines) do
        local old_line = original_names[i]
        
        if old_line and new_line ~= old_line then
            -- 解析文件名 (简单处理：假设文件名在空格分割的最后一列)
            -- 注意：生产环境建议使用更严谨的正则来处理带空格的文件名
            local old_name = old_line:match(".+%s+(.+)$")
            local new_name = new_line:match(".+%s+(.+)$")

            if old_name and new_name and old_name ~= new_name then
                local success, err = os.rename(old_name, new_name)
                if success then
                    print(string.format("Renamed: %s -> %s", old_name, new_name))
                else
                    vim.notify("Error renaming: " .. (err or ""), vim.log.levels.ERROR)
                end
            end
        end
    end

    -- 写入完成后，将 buffer 标记为未修改，防止退出时报错
    vim.api.nvim_buf_set_option(buf, 'modified', false)
end

-- 绑定快捷键
vim.api.nvim_create_user_command('Dired', M.open_ls, { nargs = 0, desc = '热重载当前 Lua 文件到 Android 设备' })

return M

