-- もう使わないが書き方の例として残す
--[[
local items = {
  { label = "Save", cmd = "write" },
  { label = "Quit", cmd = "quit" },
  { label = "Lazy", cmd = "Lazy" },
}

vim.api.nvim_create_user_command("MyCommands", function()
  vim.ui.select(items, {
    prompt = "My Commands",
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice then
      vim.cmd(choice.cmd)
    end
  end)
end, {})

-- 例えば <leader>p で開く
vim.keymap.set("n", "<leader>p", "<cmd>MyCommands<CR>", { desc = "My Commands" })

--]]