local M = {}
local RELOAD_GROUP = vim.api.nvim_create_augroup("HotReloadGroup", { clear = true })
local PROJECT_ROOT = vim.fn.getcwd() -- 假设当前工作目录就是项目根目录
local SCRIPTS_DIR = PROJECT_ROOT .. '/scripts/ab/'
local PACKAGE_NAME = 'com.blina.match2.tt'
local TARGET_DATA_DIR = ("/sdcard/Android/data/%s/files/s/"):format(PACKAGE_NAME)
local TEMP_FILE = 'Library/hotreload_tmp' -- 暂存文件
local TEMP_DEVICE_PATH = '/data/local/tmp/' -- 新增临时设备路径
local ENABLE = false

--- 核心热重载逻辑

function M.enable_hotreload()
    ENABLE = true
end

function M.reload_file()
    if not ENABLE then
        return
    end
    if vim.bo.filetype ~= 'lua' then
        -- 仅在非自动触发且手动调用时显示警告
        if vim.v.event:find("UserCommand") then
            vim.notify("热重载失败：当前文件类型不是 'lua'。", vim.log.levels.WARN, { title = "Hot-Reload" })
        end
        return
    end

    local current_file = vim.fn.expand('%:p')
    
    -- 检查加密脚本是否存在
    local encrypt_script = SCRIPTS_DIR .. 'encrypt_name.py'
    if vim.fn.filereadable(encrypt_script) == 0 then
        -- vim.notify("热重载失败：找不到加密脚本：" .. encrypt_script, vim.log.levels.ERROR, { title = "Hot-Reload" })
        vim.notify(vim.fn.system('python3 scripts/dev/hotreload.py ' .. vim.fn.shellescape(current_file)))
        return
    end

    -- 计算 Lua module path
    local module_path = current_file
        :gsub(PROJECT_ROOT .. '[/\\_]?', '') 
        :gsub('%.lua.txt', '')
        :gsub('%.lua', '')
        :gsub('^.*Lua/', '')
        :gsub('[/\\]', '.')

    -- 1. 调用 encrypt_name.py 获取加密文件名
    local encrypt_cmd = string.format("python3 %s %s", vim.fn.shellescape(encrypt_script), vim.fn.shellescape(module_path))
    local encrypted_filename = string.match(vim.fn.system(encrypt_cmd), "^%s*(.-)%s*$")

    if not encrypted_filename or #encrypted_filename == 0 then
        vim.notify("加密失败，请检查脚本执行权限和输出。", vim.log.levels.ERROR, { title = "Hot-Reload" })
        return
    end

    -- 2. 调用 crypt.py 加密并生成临时文件
    local crypt_cmd = string.format("python3 %s %s", vim.fn.shellescape(SCRIPTS_DIR .. 'crypt.py'), vim.fn.shellescape(current_file))
    local output = vim.fn.system(crypt_cmd) -- 假设 crypt.py 将加密结果写入 Library/hotreload_tmp

    -- 3. adb push 临时文件到设备上的通用临时目录
    local temp_push_file = TEMP_DEVICE_PATH .. encrypted_filename
    local push_cmd = string.format("adb push %s %s", vim.fn.shellescape(TEMP_FILE), vim.fn.shellescape(temp_push_file))
    local push_output = vim.fn.system(push_cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("文件上传到临时目录失败。", vim.log.levels.ERROR, { title = "Hot-Reload" })
        vim.notify(push_output, vim.log.levels.DEBUG, { title = "Hot-Reload" })
        return
    end

    -- **核心修复步骤：使用 run-as 移动文件**
    -- run-as 以 App 权限执行命令，将文件从 /data/local/tmp 移动到 App 自己的目录。
    -- App 自己的目录是 /data/data/<package_name>/
    local mv_cmd = string.format(
        "adb shell run-as %s mv %s %s",
        vim.fn.shellescape(PACKAGE_NAME),
        vim.fn.shellescape(temp_push_file),
        vim.fn.shellescape(app_target_file) -- 注意：run-as 环境中，路径是相对于 App 自身的 /data/data/<package_name>/
    )
    local mv_output = vim.fn.system(mv_cmd)

    if vim.v.shell_error ~= 0 then
        if not mv_output:find('package not debuggable') then
            vim.notify("文件移动/权限修正失败（run-as 错误）。", vim.log.levels.ERROR, { title = "Hot-Reload" })
            vim.notify(mv_output, vim.log.levels.DEBUG, { title = "Hot-Reload" })
            return
        end

        local target_path = TARGET_DATA_DIR .. encrypted_filename
        local push_cmd = string.format("adb push %s %s", vim.fn.shellescape(TEMP_FILE), vim.fn.shellescape(target_path))
        local push_output = vim.fn.system(push_cmd)

        if vim.v.shell_error ~= 0 then
            vim.notify("文件上传失败，请检查 ADB 连接和设备路径。", vim.log.levels.ERROR, { title = "Hot-Reload" })
            vim.notify(push_output, vim.log.levels.DEBUG, { title = "Hot-Reload" })
            return
        end
    end

    -- 4. 调用 adb send Activity 进行热重载通知
    local activity_cmd = string.format(
        "adb shell am start -n com.blina.match2/.GameActivity -a android.intent.action.VIEW --es 'reload_module' '%s' --es 'encrypted_file' '%s'",
        vim.fn.shellescape(module_path),
        vim.fn.shellescape(encrypted_filename)
    )

    local activity_output = vim.fn.system(activity_cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("Activity 发送失败，请检查包名和 Activity 名称。", vim.log.levels.ERROR, { title = "Hot-Reload" })
        vim.notify(activity_output, vim.log.levels.DEBUG, { title = "Hot-Reload" })
        return
    end
    
    -- 仅在自动触发时静默，手动调用时可以通知
    -- if vim.v.event == nil or vim.v.event:find("UserCommand") then
    --     vim.notify(
    --         string.format("✅ 热重载成功！\n模块: %s\n文件: %s", module_path, encrypted_filename),
    --         vim.log.levels.INFO,
    --         { title = "Hot-Reload" }
    --     )
    -- end
end

--- 设置命令和 Autocmd
function M.setup()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        group = RELOAD_GROUP,
        callback = function()
            vim.api.nvim_create_user_command('Hotreload', M.enable_hotreload, { nargs = 0, desc = '热重载当前 Lua 文件到 Android 设备' })
            vim.api.nvim_create_user_command('Reload', M.reload_file, { nargs = 0, desc = '热重载当前 Lua 文件到 Android 设备' })
            vim.api.nvim_create_user_command('R', M.reload_file, { nargs = 0, desc = '热重载当前 Lua 文件到 Android 设备 (别名)' })
        end,
    })

    -- 实现 OnSave 自动触发
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.lua",
        group = RELOAD_GROUP,
        callback = M.reload_file,
    })
    -- 实现 OnSave 自动触发
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.lua.txt",
        group = RELOAD_GROUP,
        callback = M.reload_file,
    })
end

return M
