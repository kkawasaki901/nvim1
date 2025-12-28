
  -- json-nvimプラグイン（JSON編集支援）
  -- tree-sitterなど要件が多いのでやっぱり使わない
  --[[
  {
    "VPavliashvili/json-nvim",
    ft = "json",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "json",
        callback = function()
          -- ここに自動で走らせたいコマンドを書く
          vim.cmd("JsonFormatFile")
        end,
      })
    end,
  }
    --]]