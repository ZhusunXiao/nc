return {
  {
    "utilyre/barbecue.nvim",
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons",
    },
    event = "LspAttach",
    opts = {
      show_modified = true,
      separator = "  ",
      },
  },
}
