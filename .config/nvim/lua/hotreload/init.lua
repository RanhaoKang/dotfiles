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

    local script_path = vim.fn.getcwd() .. '/scripts/dev/hotreload.py'
    local cmd = string.format("python3 %s %s", vim.fn.shellescape(script_path), vim.fn.shellescape(current_file))

    -- 异步执行防止界面卡顿，并捕获错误
    vim.fn.jobstart(cmd, {
        on_stderr = function(_, data)
            local msg = table.concat(data, "")
            if #msg > 0 then
                vim.notify("Hot-Reload Error: " .. msg, vim.log.levels.ERROR)
            end
        end,
        on_stdout = function(_, data)
            local msg = table.concat(data, "")
            if #msg > 1 then
                vim.notify(msg, vim.log.levels.INFO, { title = "Hot-Reload" })
            end
        end,
    })
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

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = {"*.lua", "*.lua.txt"},
        group = RELOAD_GROUP,
        callback = M.reload_file,
    })
end

return M
