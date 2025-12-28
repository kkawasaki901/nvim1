-- ########################
-- TODO: 共通設定
-- ########################

-- leaderキーをスペースに設定
vim.g.mapleader = " "
vim.cmd("set number")

-- カーソル行を中央に表示する関数（端末バッファやnofileバッファでは実行しない）
-- toggleTermを使ったときの"modifiable is off"エラー対策らしいけど、よくわかってない
local function safe_normal(cmd)
  local bt = vim.bo.buftype
  if bt == "terminal" or bt == "nofile" then
    return
  end
  vim.cmd("normal! " .. cmd)
end
safe_normal("zz")


-- シェルをPowerShellに設定
local sys = vim.loop.os_uname().sysname
if sys == "Windows_NT" then
  vim.o.shell = "powershell"
  vim.o.shellcmdflag = "-NoProfile -Command"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end

-- pane/window move with Ctrl-h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })





-- ########################
-- TODO: パソコンごとに書き換えるかもしれない設定
-- ########################

-- ホームディレクトリのパス取得
local home = vim.fn.expand("~")

-- orgとobsidianのファイルパス設定
local org_path = string.format("%s/org", home)
local obsidian_path = string.format("%s/obsidian/org_obsidian", home)



-- ########################
-- TODO: コンフィグごとに変える設定
-- ########################

-- init.luaのパス
local init_lua_path = vim.fn.stdpath("config") .. "/org-init.lua"

-- これをコンフィグごとに変える
local config_data_folder_name = "org-data"

-- lazy.nvim用のデータ保存フォルダパス
local lazy_data_path = string.format("%s/%s", vim.fn.stdpath("data"), config_data_folder_name)

-- 上記フォルダがなければ自動で作る
if vim.fn.isdirectory(lazy_data_path) == 0 then
  vim.fn.mkdir(lazy_data_path, "p")
end

-- ########################
-- TODO: 気まぐれで定期的に書き換える
-- ########################

-- このファイル名を気まぐれで変更する
local english_file_name = "words1.txt"

-- 英単語ファイルを入れておくフォルダのパス設定
local english_words_folfer = string.format("%s/english_words", vim.fn.stdpath("config"))

-- 上記フォルダがなければ自動で作る
if vim.fn.isdirectory(english_words_folfer) == 0 then
  vim.fn.mkdir(english_words_folfer, "p")
end

-- テキストファイルのパス
local english_words_path = string.format("%s/%s", english_words_folfer, english_file_name)



-- #########################
-- TODO: lazy.nvimのインストール
-- #########################
local lazypath = string.format("%s/lazy/lazy.nvim", lazy_data_path)
local lazyroot = string.format("%s/lazy", lazy_data_path)
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- #########################
-- TODO: lazy.nvimでプラグイン管理
-- #########################

require("lazy").setup(
{
  -- orgmodeプラグイン
  {
    "nvim-orgmode/orgmode",
    config = function()
      require('orgmode').setup({
        org_agenda_files = string.format('%s/**/*', org_path),
        org_default_notes_file = string.format('%s/refile.org', org_path),
      })
    end,
  },

  -- HACK: catppuccinカラースキームプラグイン
  {
    "catppuccin/nvim",
    name = "catppuccin", -- colorscheme名と一致させる
    priority = 1000,    -- 最優先で読み込ませる（超重要）
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- HACK: org-bullets.nvimプラグイン（箇条書き記号の装飾）
  {
    "akinsho/org-bullets.nvim", config = function()
    require("org-bullets").setup {
      concealcursor = false, -- If false then when the cursor is on a line underlying characters are visible
      symbols = {
        -- list symbol
        list = "•",
        -- headlines can be a list
        headlines = { "◉", "○", "✸", "✿" },
        -- or a function that receives the defaults and returns a list
        headlines = function(default_list)
          table.insert(default_list, "♥")
          return default_list
        end,
        -- or false to disable the symbol. Works for all symbols
        headlines = false,
        -- or a table of tables that provide a name
        -- and (optional) highlight group for each headline level
        headlines = { 
          { "◉", "MyBulletL1" },
          { "○", "MyBulletL2" },
          { "✸", "MyBulletL3" },
          { "✿", "MyBulletL4" },
        },
        checkboxes = {
          half = { "", "@org.checkbox.halfchecked" },
          done = { "✓", "@org.keyword.done" },
          todo = { "˟", "@org.keyword.todo" },
        },
      }
    }
    end
  },

  -- HACK: headlines.nvimプラグイン（見出しの装飾）
  {
    "lukas-reineke/headlines.nvim",
    ft = { "org", "markdown" }, -- 必要なときだけロード

  },

{
  "kkawasaki901/english_word",
  config = function()
    require("english_word").setup({
      path = english_words_path,
    })
  end,
},


  -- HACK: snacks.nvimプラグイン（ダッシュボード）
  {
    "folke/snacks.nvim",
     opts = function()
        -- dashboardに出す行（デフォルト）
     local lines = { "english_word not loaded" }
 
     local ok, ew = pcall(require, "english_word")
     if ok then
       -- pick_lines の戻り値が「文字列1つ」でも「文字列配列」でも吸収する
       local v = ew.pick_lines(english_words_path, 5) -- ← 引数が必要な想定
       if type(v) == "table" then
         lines = v
       elseif v ~= nil then
         lines = { tostring(v) }
       end
     end

    return{
      dashboard = 
      {
        enabled = true,
        sections = {
          -- chafaで画像表示（要chafaインストール）
          -- scoop install chafa でインストール可能
          --[[
          {
          section = "terminal",
          cmd = ("chafa %s/vim.png --format symbols --symbols vhalf --size 44x12")
            :format(vim.fn.stdpath("config")),
          height = 17,
          padding = 1,
          },
          --]]

          -- terminal の例
          -- sleep が必要(おわりましたの邪魔な表示が出るため)
          --[[
          {
            section = "terminal",
            cmd = "echo 'Welcome to Neovim Org-mode Environment!' ; sleep 99999",
            height = 3,
          },
          --]]

          -- PowerShellで日付表示の例 lualineがあるからもういらない
          --[[
          {
            section = "terminal",
            cmd = "Get-Date -Format 'yyyy/MM/dd (ddd)'; sleep 99999",
          },
          --]]
          
        {
          title = lines,
        },

        --[[
          {
            title = require("english_word").pick_lines()
          },
        --]]
          {
            title = "\n────────────────────────────\n",
          },

          -- セッションの設定例 section = の後の単語は小文字スタートな点に注意(例: section = projects)
          --[[
          {
            title = "Projects",
          },
          {
            section = "projects",
          },
          --]]

          { section = "keys"},
          { title = "Comands", pane = 2},
          {
            pane = 2,
            icon = "",
            key = "m",
            desc = "org-mode",
            action = function()
              vim.cmd(string.format("cd %s", org_path))
              vim.cmd("e notes.org")
              vim.cmd("Neotree toggle")
            end,
          },
          {
            pane = 2,
            icon = "",
            key = "o",
            desc = "obsidian",
            action = function()
              vim.cmd(string.format("cd %s", obsidian_path))
              vim.cmd("Neotree toggle")
            end,
          },
          {
            pane = 2,
            icon = "",
            key = "j",
            desc = "json focus log",
            action = function()
              vim.cmd("OpenFocusJsonInVSCode")
            end,
          }
        },
      }
    }
  end,
      config = function(_, opts)
        require("snacks").setup(opts)
    
        vim.keymap.set("n", "<leader>dd", function()
          require("snacks").dashboard()
        end, { desc = "Open Snacks Dashboard" })
      end,
  },

  -- HACK: neo-treeプラグイン（ファイルツリー）
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    config = function()
        vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
        require("neo-tree").setup({
          filesystem = {
            commands = {
              delete = function(state)
                local node = state.tree:get_node()
                local path = node.path
                vim.fn.system({ "trash", path })
              end,
            },
          },
        })
    end,
  },

  -- HACK: auto-saveプラグイン（自動保存）
  {
  	"Pocco81/auto-save.nvim",
  },

  -- HACK: markdown-previewプラグイン
  {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
  keys = {
    { "<leader>dm", "<cmd>MarkdownPreview<CR>", desc = "Markdown Preview", mode = "n" },
  },

  },

  

  -- HACK: lualineプラグイン（ステータスライン）
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        sections = {
          lualine_a = {
            {
              'datetime',
              -- options: default, us, uk, iso, or your own format string ("%H:%M", etc..)
              style = '%m/%d (%a) %H:%M',
            }
          },
        }
      }
    end,
  },


  -- HACK: which-keyプラグイン（キーマッピング補助）
  {
  "folke/which-key.nvim",
    event = "VeryLazy",
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      -- <leader>o 配下を "Org-mode Command" として表示させるなどの設定例
      wk.add({
        { "<leader>o", group = "󱞁 Org-mode Command" },
        { "<leader>d", group = " .md / 󰡃 dashboard" },
        { "<leader>t", group = " Tasks /  Terminal" },
        { "<leader>c", group = " Config" },
      })
    end,
  },

  -- HACK: todo-commentsプラグイン（todoコメント強調表示）
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  
    -- HACK: Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua" , "python" }, -- 使う言語を追加
      highlight = { enable = true },
    },
  },

  -- HACK: LSP 設定
  { 
    "neovim/nvim-lspconfig",
  
    config = function()
      vim.lsp.enable("pyright")
      vim.lsp.enable("lua_ls")
      --[[
      -- deprecated
      -- 新しいやり方は下記に書いてある
      -- https://zenn.dev/vim_jp/articles/migrate-nvim-lspconfig-v0_11
      -- 下記、一言でまとめ
      -- setup関数の引数を返却するファイルを作成します。場所は.config/nvim/after/lsp/language_server_name.luaです。
      require("lspconfig").pyright.setup{}  -- Python LSPサーバ
      require("lspconfig").lua_ls.setup{}  -- Lua LSPサーバ
      --]]
    end,
  },

  -- HACK: LSPサーバ管理
  { "mason-org/mason.nvim" ,
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
      vim.cmd("set signcolumn=no")
    end,
  },

  -- HACK: mason-lspconfig連携プラグイン
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "lua_ls" }, -- 使うLSPサーバを追加
      })
      vim.cmd("set signcolumn=no")
    end,
  },

  -- HACK: toggletermプラグイン（ターミナル切り替え）
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    keys = {
      { "<leader>tl", "<cmd>ToggleTerm size=8<CR>", desc = "Toggle Terminal", mode = "n" },
    },
    config = function()
      require("toggleterm").setup{
        open_mapping = [[<c-\>]],
        direction = 'horizontal',
        size = 15,
      }
    end,
  },

  -- 自作プラグインのお試し
  {
    "kkawasaki901/my-plugin",
    config = function()
      require("my-plugin").setup{}
    end,

  },

  -- HACK: 自作プラグイン: タスク切り替え
  {
    "kkawasaki901/toggle_task",
    --[[
    -- キーマップを変えたいならここで変える。デフォルトは<leader>tt
    opts = {
      keymap = "<leader>tt",
    },
    --]]

    config = function()
      require("toggle_task").setup{}
    end,

  },



}, -- end of plugins table

{
  root = lazyroot, -- directory where plugins will be installed
}
)


