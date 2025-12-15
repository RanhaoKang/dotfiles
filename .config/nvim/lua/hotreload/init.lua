local M = {}

-- 1. 当 FileType 为 lua 时加载
-- 插件主体逻辑
function M.reload_file()
    -- 确保在正确的 FileType 下运行
    if vim.bo.filetype ~= 'lua' then
        vim.notify("热重载失败：当前文件类型不是 'lua'。", vim.log.levels.WARN, { title = "Neovim Hot-Reload" })
        return
    end

    local current_file = vim.fn.expand('%:p') -- 当前文件的绝对路径
    local current_dir = vim.fn.getcwd()      -- 当前工作目录
    local project_root = current_dir          -- 假设当前工作目录就是项目根目录

    -- 检查加密脚本是否存在
    local encrypt_script = project_root .. '/scripts/ab/encrypt_name.py'
    if vim.fn.filereadable(encrypt_script) == 0 then
        vim.notify("热重载失败：找不到加密脚本：" .. encrypt_script, vim.log.levels.ERROR, { title = "Neovim Hot-Reload" })
        return
    end

    vim.notify("开始热重载: " .. current_file, vim.log.levels.INFO, { title = "Neovim Hot-Reload" })

    -- 步骤 3 (计算 Lua module path)
    local relative_path = current_file:gsub(current_dir .. '[/\\_]?', '') -- 移除工作目录
    local module_path = relative_path
        :gsub('%.lua.txt', '') -- 去除 .lua.txt
        :gsub('%.lua', '')     -- 去除 .lua
        :gsub('^.*Lua/', '')
        :gsub('[/\\]', '.')    --

    -- --- 步骤 4: 调用 encrypt_name.py 脚本获取加密文件名 ---
    local encrypt_cmd = string.format("python3 %s %s", vim.fn.shellescape(encrypt_script), vim.fn.shellescape(module_path))
    local encrypted_filename = string.match(vim.fn.system(encrypt_cmd), "^%s*(.-)%s*$")

    if not encrypted_filename or #encrypted_filename == 0 then
        vim.notify("加密失败，请检查脚本执行权限和输出。", vim.log.levels.ERROR, { title = "Neovim Hot-Reload" })
        vim.notify("命令: " .. encrypt_cmd, vim.log.levels.DEBUG, { title = "Neovim Hot-Reload" })
        return
    end

    vim.notify(("%s to %s"):format(module_path, encrypted_filename))

    local output = vim.fn.system(('python3 %s %s'):format(vim.fn.shellescape(project_root .. '/scripts/ab/crypt.py'), vim.fn.shellescape(current_file)))
    vim.notify(output)

    -- --- 步骤 5: adb push 当前文件到目标路径 ---
    local target_path = "/sdcard/Android/data/com.blina.match2.tt/files/s/" .. encrypted_filename
    local push_cmd = string.format("adb push %s %s", vim.fn.shellescape('Library/hotreload_tmp'), vim.fn.shellescape(target_path))
    local push_output = vim.fn.system(push_cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("文件上传失败，请检查 ADB 连接和设备路径。", vim.log.levels.ERROR, { title = "Neovim Hot-Reload" })
        vim.notify(push_output, vim.log.levels.DEBUG, { title = "Neovim Hot-Reload" })
        return
    end

    -- --- 步骤 6: 调用 adb send Activity 进行热重载 ---
    -- 步骤 3 的 module path 是用于构造热重载 Activity Intent 的参数
    -- 这里我们依赖 encrypt_name.py (步骤 4) 已经将文件路径信息编码进了文件名，
    -- 或者游戏 Activity 只需要知道加密后的文件名即可。
    -- 如果 Activity 需要原始 module path，则需要额外计算：

    local activity_cmd = string.format(
        "adb shell am start -n com.blina.match2/.GameActivity -a android.intent.action.VIEW --es 'reload_module' '%s' --es 'encrypted_file' '%s'",
        vim.fn.shellescape(module_path),
        vim.fn.shellescape(encrypted_filename)
    )

    local activity_output = vim.fn.system(activity_cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("Activity 发送失败，请检查包名和 Activity 名称。", vim.log.levels.ERROR, { title = "Neovim Hot-Reload" })
        vim.notify(activity_output, vim.log.levels.DEBUG, { title = "Neovim Hot-Reload" })
        return
    end

    vim.notify(
        string.format("✅ 热重载成功！\n模块: %s\n文件: %s", module_path, encrypted_filename),
        vim.log.levels.INFO,
        { title = "Neovim Hot-Reload" }
    )
end

-- 2. 新增命令 :reload 或 :r 时触发
-- 将命令定义封装在一个函数中，以便在 FileType 为 lua 时调用
function M.setup()
    -- 在 Lua 文件类型中定义命令
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        group = vim.api.nvim_create_augroup("HotReloadGroup", { clear = true }),
        callback = function()
            vim.api.nvim_create_user_command('Reload', M.reload_file, { nargs = 0, desc = '热重载当前 Lua 文件到 Android 设备' })
            -- 别名 :r
            vim.api.nvim_create_user_command('R', M.reload_file, { nargs = 0, desc = '热重载当前 Lua 文件到 Android 设备 (别名)' })
        end,
    })
end

return M
