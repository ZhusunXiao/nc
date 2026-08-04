-- Disable treesitter entirely
vim.g.loaded_treesitter = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- leader MUST be set before lazy.nvim loads so <leader> mappings resolve correctly
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Basic editor options (see lua/options.lua)
require("options")

-- LSP (built-in vim.lsp.config, no plugin needed)
require("lsp")
require("lsp_hl")  -- semantic highlight colours

-- Load plugins from lua/plugins/ directory using import
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
