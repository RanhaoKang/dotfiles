local M = {}

function M.setup()
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
end

return M

