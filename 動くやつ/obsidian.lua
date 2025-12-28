-- obsidian.nvim
  -- 使うメリットが分からないのでいったんコメントアウト
  --[[
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
  
    opts = {
      workspaces = {
        {
          name = "main",
          path = "C:/Users/kawasaki/Documents/Document/obsidian/org_obsidian",
        },
      },
  
      note_id_func = function(title)
        if title then return title end
        return os.date("%Y-%m-%d-%H%M%S")
      end,
  
      preferred_link_style = "wiki",
      disable_frontmatter = false,
  
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = "templates/daily.md",
      },
    },
  
    -- ★ここが重要：opts を受け取って setup を呼ぶ
    config = function(_, opts)
      require("obsidian").setup(opts)
  
      -- Markdown / Obsidian 用
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "md" },
        callback = function()
          vim.opt_local.conceallevel = 1
        end,
      })
  
      local obsidian_command_items = {
        { label = "Open", cmd = "ObsidianOpen" },
        { label = "New", cmd = "ObsidianNew" },
        { label = "Today", cmd = "ObsidianToday" },
        { label = "Search", cmd = "ObsidianSearch" },
      }
  
      vim.api.nvim_create_user_command("ObsidianCommands", function()
        vim.ui.select(obsidian_command_items, {
          prompt = "Obsidian Commands",
          format_item = function(item) return item.label end,
        }, function(choice)
          if choice then
            -- コマンド存在チェック（失敗時に分かりやすく）
            if vim.fn.exists(":" .. choice.cmd) == 2 then
              vim.cmd(choice.cmd)
            else
              vim.notify(("Command not found: %s"):format(choice.cmd), vim.log.levels.ERROR)
            end
          end
        end)
      end, {})
  
      vim.keymap.set("n", "<leader>O", "<cmd>ObsidianCommands<CR>", { desc = "Obsidian Commands" })
    end,
  }
  --]] 
  -- obsidian.nvimは一旦コメントアウトしておく