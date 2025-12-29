local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("FileList", { clear = true })
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "filelist",
        group = group,
        callback = function(ev)
            local function open_in_buffer()
                local filepath = vim.fn.expand("<cfile>")
                if filepath == "" then
                    print("当前行没有检测到文件路径")
                    return
                end

                vim.cmd('edit ' .. filepath)
            end

            -- 设置快捷键 o
            vim.keymap.set("n", "o", open_in_buffer, { buffer = ev.buf, desc = "Open in buffer" })
        end,
    })
end

return M

