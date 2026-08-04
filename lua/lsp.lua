-- LSP via Neovim 0.12+ built-in vim.lsp.config

-- clangd
vim.lsp.config["clangd"] = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
  handlers = {
    ["textDocument/semanticTokens"] = {
      highlight = { priority = 200 },
    },
    ["textDocument/semanticTokens/full"] = {
      highlight = { priority = 200 },
    },
  },
}
vim.lsp.enable("clangd")


-- LSP keymaps (Snacks already handles gd/gD/gr/gi/gy)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("n", "<leader>f", vim.lsp.buf.format, "Format")
  end,
})
