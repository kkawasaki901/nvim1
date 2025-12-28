-- #########################
-- TODO: todoの一覧表示プラグインの自作
-- #########################
-- === TodoPane: scan all visible panes (current tabpage), only *.lua ===

local cfg = {
  width = 80
}
local state = {
  win = nil,
  buf = nil,
  items = {}, -- display_line -> {src_buf, lnum}
  ns = vim.api.nvim_create_namespace("todo_pane"),
}
local function is_valid_win(win) return win and vim.api.nvim_win_is_valid(win) end
local function is_valid_buf(buf) return buf and vim.api.nvim_buf_is_valid(buf) end
local function buf_is_lua(buf)
  local name = vim.api.nvim_buf_get_name(buf) or ""
  return name:lower():sub(-4) == ".lua"
end
local function ensure_pane()
  if not is_valid_buf(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(state.buf, "TodoPane")
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].bufhidden = "wipe"
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].filetype = "todopane"
  end
  if not is_valid_win(state.win) then
    vim.cmd("topleft vsplit")
    state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(state.win, cfg.width)
    vim.api.nvim_win_set_buf(state.win, state.buf)
    vim.wo[state.win].number = false
    vim.wo[state.win].relativenumber = false
    vim.wo[state.win].wrap = false
    vim.wo[state.win].signcolumn = "no"
    vim.wo[state.win].cursorline = true
    local function jump_under_cursor()
      local l = vim.api.nvim_win_get_cursor(state.win)[1]
      local it = state.items[l]
      if not it then return end
      if not is_valid_buf(it.src_buf) then return end
      -- 既にどこかのウィンドウで表示されているなら、そこへ移動してジャンプ
      local target_win = nil
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if w ~= state.win and vim.api.nvim_win_get_buf(w) == it.src_buf then
          target_win = w
          break
        end
      end
      if target_win then
        vim.api.nvim_set_current_win(target_win)
        vim.api.nvim_win_set_cursor(target_win, { it.lnum, 0 })
      else
        -- 万一ウィンドウに無ければ、右側のどこかで開く
        -- （基本は “開いているpane” 対象なのでここには来ないはず）
        vim.cmd("wincmd l")
        vim.api.nvim_set_current_buf(it.src_buf)
        vim.api.nvim_win_set_cursor(0, { it.lnum, 0 })
      end
      vim.cmd("normal! zz")
    end
    local opts = { noremap = true, silent = true, buffer = state.buf }
    vim.keymap.set("n", "<CR>", jump_under_cursor, opts)
    vim.keymap.set("n", "o", jump_under_cursor, opts)
    vim.keymap.set("n", "q", function()
      if is_valid_win(state.win) then vim.api.nvim_win_close(state.win, true) end
      state.win = nil
    end, opts)
    vim.keymap.set("n", "r", function() vim.cmd("TodoPaneRefresh") end, opts)
    -- クリックでジャンプ（:normal! <LeftMouse> は使わない）
    vim.keymap.set("n", "<LeftMouse>", function()
      local mp = vim.fn.getmousepos()
      if not state.win or mp.winid ~= state.win then return end
      vim.api.nvim_win_set_cursor(state.win, { mp.line, math.max(mp.column - 1, 0) })
      jump_under_cursor()
    end, opts)
  else
    vim.api.nvim_win_set_buf(state.win, state.buf)
  end
end

-- TodoPane 用ハイライト
vim.api.nvim_set_hl(0, "TodoPaneTODO", {
  fg = "#FF9E64", -- オレンジ系
  bold = true,
})

vim.api.nvim_set_hl(0, "TodoPaneHACK", {
  fg = "#F7768E", -- 赤系
  bold = true,
})

vim.api.nvim_set_hl(0, "TodoPaneComment", {
  fg = "#7AA2F7", -- コメント用（任意）
})


local function apply_highlights(buf, display_lines)
  vim.api.nvim_buf_clear_namespace(buf, state.ns, 0, -1)

  for i, line in ipairs(display_lines) do
    local l = i - 1

    -- ① コメント全体を先に薄く（最後にやると todo/hack を覆う）
    local cs = line:find("%-%-")
    if cs then
      vim.api.nvim_buf_add_highlight(
        buf,
        state.ns,
        "TodoPaneComment",
        l,
        cs - 1,
        -1
      )
    end

    -- ② todo
    local s, e = line:find("TODO")
    if s then
      vim.api.nvim_buf_add_highlight(
        buf,
        state.ns,
        "TodoPaneTODO",
        l,
        s - 1,
        e
      )
    end

    -- ③ hack
    s, e = line:find("HACK")
    if s then
      vim.api.nvim_buf_add_highlight(
        buf,
        state.ns,
        "TodoPaneHACK",
        l,
        s - 1,
        e
      )
    end
  end
end



local function match_line(text)
  local has_todo = (text:find("TODO", 1, true) ~= nil) or (text:find("HACK", 1, true) ~= nil)
  local is_lua_comment = text:find("-- ", 1, true) ~= nil
  return has_todo and is_lua_comment
end
local function refresh()
  ensure_pane()
  -- 現在のタブの「開いているウィンドウ（pane）」を全部対象にする
  local wins = vim.api.nvim_tabpage_list_wins(0)
  -- 重複除去しつつ、*.lua のバッファだけ集める
  local seen = {}
  local bufs = {}
  for _, w in ipairs(wins) do
    local b = vim.api.nvim_win_get_buf(w)
    if b ~= state.buf and is_valid_buf(b) and not seen[b] and buf_is_lua(b) then
      seen[b] = true
      table.insert(bufs, b)
    end
  end
  local items, display = {}, {}
  for _, b in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(b)
    local short = (name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]")
    local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    for lnum, line in ipairs(lines) do
      if match_line(line) then
        -- 表示: filename:lnum  text
        display[#display + 1] = string.format("%s:%d  %s", short, lnum, line)
        items[#items + 1] = { src_buf = b, lnum = lnum }
      end
    end
  end
  if #display == 0 then
    display = {
      "TodoPane: no matches in visible *.lua panes",
    }
  end
  state.items = items
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, display)
  vim.bo[state.buf].modifiable = false
  apply_highlights(state.buf, display)
end
local function open()
  ensure_pane()
  refresh()
end
local function toggle()
  if is_valid_win(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
  else
    open()
  end
end
vim.api.nvim_create_user_command("TodoPaneOpen", open, {})
vim.api.nvim_create_user_command("TodoPaneToggle", toggle, {})
vim.api.nvim_create_user_command("TodoPaneRefresh", refresh, {})
-- 保存したら自動更新（TodoPaneが開いてる時だけ）
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    if is_valid_win(state.win) then refresh() end
  end,
})
-- 好きなキーに
vim.keymap.set("n", "<leader>tp", "<cmd>TodoPaneToggle<cr>", { desc = "TodoPane (visible lua panes)" })
vim.keymap.set("n", "<leader>tr", "<cmd>TodoPaneRefresh<cr>", { desc = "TodoPane refresh" })

local function open_config_and_todopane()
  -- 設定ファイルを開く（必要に応じてパス変更）
  vim.cmd("edit " .. string.format("%s", init_lua_path))

  -- バッファが切り替わったあとに TodoPane を開く
  -- （即実行だと win/buf 状態が不安定になることがあるため schedule）
  vim.schedule(function()
    local edit_win = vim.api.nvim_get_current_win() -- いまの編集窓を覚える
    vim.cmd("TodoPaneToggle")
    -- TodoPane がフォーカスを奪っても、編集窓に戻してから Aerial
    if vim.api.nvim_win_is_valid(edit_win) then
      vim.api.nvim_set_current_win(edit_win)
    end
    -- やっぱり下記あんまり意味ないからコメントアウト
    -- vim.cmd("AerialToggle!")
  end)
end

-- コマンド化
vim.api.nvim_create_user_command(
  "ConfigWithTodo",
  open_config_and_todopane,
  {}
)

-- キーマップ例
vim.keymap.set(
  "n",
  "<leader>ct",
  open_config_and_todopane,
  { desc = "Open config and TodoPane" }
)
