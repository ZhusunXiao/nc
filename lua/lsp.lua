-- LSP via Neovim 0.12+ built-in vim.lsp.config
-- clangd path: resolved per-project via nc module

local nc = require("nc")

-- Treesitter (parsers installed manually, no plugin needed)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- fallback default
vim.lsp.config["clangd"] = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { "nc.lua", ".git", "compile_commands.json", "compile_flags.txt" },
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

-- Re-resolve nc.lua BEFORE FileType triggers LSP (BufReadPre fires first)
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.cxx", "*.cc", "*.ixx", "*.cppm" },
  callback = function()
    nc.clear() -- force re-walk from the current buffer
    local path = nc.get("clangd.path")
    vim.lsp.config["clangd"].cmd = { path or "clangd" }
  end,
})

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
