return {
  "lewis6991/gitsigns.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = "│" },
      change       = { text = "│" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },
    signs_staged_enable = true,
    signcolumn = true,
    numhl      = false,
    linehl     = false,
    word_diff  = false,
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 1000,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> — <summary>",
    sign_priority = 6,
    update_debounce = 100,
    max_file_length = 40000,
    preview_config = {
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
      end, "Next Hunk")
      map("n", "[c", function()
        if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
      end, "Prev Hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
      map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
      map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
      map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>hR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>hi", gs.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>hd", gs.diffthis, "Diff This")
      map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff This ~")
      map("n", "<leader>hQ", function() gs.setqflist("all") end, "Quickfix All Hunks")
      map("n", "<leader>hq", gs.setqflist, "Quickfix Hunks")

      -- Toggles
      map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle Line Blame")
      map("n", "<leader>tw", gs.toggle_word_diff, "Toggle Word Diff")

      -- Text object
      map({ "o", "x" }, "ih", gs.select_hunk, "Select Hunk")
    end,
  },
}
