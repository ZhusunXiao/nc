return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = true,
  event = "VeryLazy",
  opts = {
    ensure_installed = { "c", "cpp" },
    auto_install = true,
    highlight = { enable = true },
  },
}
