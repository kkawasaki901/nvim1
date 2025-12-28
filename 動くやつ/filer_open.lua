-- ########################
-- その他の共通設定
-- ########################

-- <leader>e で netrw (:Explore)
--[[
vim.keymap.set("n", "<leader>e", ":Explore<CR>", {
  noremap = true,
  silent = true,
  desc = "Open netrw (Explore)"
})
--]]
