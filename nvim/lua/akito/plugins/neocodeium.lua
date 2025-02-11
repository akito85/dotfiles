local neocodeium = require("neocodeium")

neocodeium.setup({
    manual = true, -- recommended to not conflict with nvim-cmp
})
-- create an autocommand which closes cmp when ai completions are displayed
vim.api.nvim_create_autocmd("User", {
  pattern = "NeoCodeiumCompletionDisplayed",
  callback = function() require("cmp").abort() end
})

vim.keymap.set("i", "<A-f>", function()
    require("neocodeium").accept()
end)
vim.keymap.set("i", "<A-w>", function()
    require("neocodeium").accept_word()
end)
vim.keymap.set("i", "<A-a>", function()
    require("neocodeium").accept_line()
end)
vim.keymap.set("i", "<A-e>", function()
    require("neocodeium").cycle_or_complete()
end)
vim.keymap.set("i", "<A-r>", function()
    require("neocodeium").cycle_or_complete(-1)
end)
vim.keymap.set("i", "<A-c>", function()
    require("neocodeium").clear()
end)

-- Accepts the suggestion
neocodeium.accept()

-- Accepts only part of the suggestion if the full suggestion doesn't make sense
neocodeium.accept_word()
neocodeium.accept_line()

-- Clears the current suggestion
neocodeium.clear()

-- Cycles through suggestions by `n` (1 by default) items. Use a negative value to cycle in reverse order
neocodeium.cycle(n)

-- Same as `cycle()`, but also tries to show a suggestion if none is visible.
-- Mostly useful with the enabled `manual` option
neocodeium.cycle_or_complete(n)

-- Checks if a suggestion's virtual text is visible or not (useful for some complex mappings)
neocodeium.visible()
