return {
  "tomasiser/vim-code-dark",
  lazy = false, -- 起動時に読み込む
  priority = 1000, -- 色設定系は早めに読み込ませると安全
  config = function()
    -- オプションがあればここで設定
    -- 例: let g:codedark_modern = 1
    vim.g.codedark_modern = 1
    vim.g.codedark_italics = 1
    vim.g.codedark_transparent = 0 -- 背景透明にしたくなければ 0

    -- colorscheme を設定
    vim.cmd([[colorscheme codedark]])
  end,
}
