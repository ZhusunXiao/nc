-- LSP via Neovim 0.12+ built-in vim.lsp.config
-- clangd path: walks up from every C/C++ buffer BEFORE LSP starts

-- fallback default
vim.lsp.config["clangd"] = {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { "nc.lua", ".git", "compile_commands.json", "compile_flags.txt" },
}
vim.lsp.enable("clangd")

-- Resolve nc.lua BEFORE FileType triggers LSP start (BufReadPre fires first)
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.cxx", "*.cc", "*.ixx", "*.cppm" },
  callback = function()
    local file = vim.fn.expand("%:p")
    if file == "" then return end

    -- walk up to find nc.lua
    local dir = vim.fn.fnamemodify(file, ":h")
    local last = nil
    while dir ~= "" and dir ~= last do
      local candidate = dir .. "/nc.lua"
      if vim.uv.fs_stat(candidate) then
        local ok, cfg = pcall(dofile, candidate)
        if ok and type(cfg) == "table" and cfg.clangd and cfg.clangd.path then
          vim.lsp.config["clangd"].cmd = { cfg.clangd.path }
          return
        end
        break
      end
      last = dir
      dir = vim.fn.fnamemodify(dir, ":h")
    end

    -- no nc.lua found → fallback to system PATH
    vim.lsp.config["clangd"].cmd = { "clangd" }
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
