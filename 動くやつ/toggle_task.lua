--[[
-- ########################
-- TODO: タスク管理用のキーマッピング
-- 使い方
-- 1. チェックボックス付きの行で実行すると、完了/未完了を切り替え
-- 2. チェックボックス無しの行で実行すると、先頭に未完了チェックボックスを追加
-- ########################
local function toggle_task()
  local line = vim.api.nvim_get_current_line()
  -- ① 未完了 → 完了
  if line:match("%[ %]") then
    line = line:gsub("%[ %]", "[x]", 1)
  -- ② 完了 → 未完了
  elseif line:match("%[[xX]%]") then
    line = line:gsub("%[[xX]%]", "[ ]", 1)
  -- ③ チェックボックスが無い → 先頭に追加
  else
    -- すでに "- " や "* " があればそれを活かす
    if line:match("^%s*[-*]%s+") then
      line = line:gsub("^%s*([-*]%s+)", "%1[ ] ", 1)
    else
      line = "- [ ] " .. line
    end
  end
  vim.api.nvim_set_current_line(line)
end

vim.keymap.set("n", "<leader>tt", toggle_task, { desc = "Toggle / Add task" })

--]]