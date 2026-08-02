return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = true,
  event = "VeryLazy",
  opts = {
    ensure_installed = { "c", "cpp" },
    auto_install = true,
    highlight = { enable = false },   -- ❌ 不接管着色，你的 lsp_hl 负责
    indent = { enable = false },      -- ❌ 不接管缩进
    incremental_selection = { enable = false },
    textobjects = { enable = false },
  },
}
