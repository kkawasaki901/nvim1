 -- HACK: headlines.nvimプラグイン（見出しの装飾）
  {
    "lukas-reineke/headlines.nvim",
    ft = { "org", "markdown" }, -- 必要なときだけロード
    config = function()
      -- ===== highlight 定義（bg維持 + 文字強調）=====
    
      --[[
      -- Headline1: 赤系背景 + 明るい文字
      vim.api.nvim_set_hl(0, "Headline1", {
        bg = "#FF5F5F",
        fg = "#FFFFFF", -- 白で最大可読性
        bold = true,
      })
    
      -- Headline2: 青系背景 + 明るい文字
      vim.api.nvim_set_hl(0, "Headline2", {
        bg = "#5FAFFF",
        fg = "#FFFFFF", -- 背景が強いので白が安定
        bold = true,
      })
    
      -- CodeBlock: 緑系背景 + 落ち着いた暗文字（眩しさ回避）
      vim.api.nvim_set_hl(0, "CodeBlock", {
        bg = "#5FFF87",
        fg = "#1C1C1C", -- ダーク文字でコードを読みやすく
      })
    
      -- Dash: オレンジ強調（そのまま）
      vim.api.nvim_set_hl(0, "Dash", {
        fg = "#D19A66",
        bold = true,
      })
      --]]
    
    
      -- ===== headlines.nvim 設定 =====
      --[[
      require("headlines").setup({
        org = {
          -- headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4" },
          -- codeblock_highlight = "CodeBlock",
          -- dash_highlight = "Dash",
        },
      })
      --]]
    end,
  },
