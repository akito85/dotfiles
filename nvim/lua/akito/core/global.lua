-- disabled on init
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- some global config
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- Set maximum file size threshold (3MB)
        local max_size = 3 * 1024 * 1024  -- 3MB in bytes
        local file = vim.fn.expand("%")
        local size = vim.fn.getfsize(file)

        if size > max_size then
            return  -- Skip removing trailing spaces if file is too large
        end

        -- Save cursor position
        local save_cursor = vim.fn.getpos(".")

        -- Remove trailing spaces
        vim.cmd([[%s/\s\+$//e]])

        -- Restore cursor position
        vim.fn.setpos(".", save_cursor)
    end,
})

-- noneckpain
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         vim.cmd("NoNeckPain")
--     end,
-- })

