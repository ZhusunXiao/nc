-- Basic editor options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.updatetime = 500
vim.opt.timeoutlen = 500

-- Quality of life
vim.opt.mouse = "a"                  -- mouse support in all modes
vim.opt.clipboard = "unnamedplus"    -- yank/paste ↔ system clipboard
vim.opt.ignorecase = true            -- case-insensitive search…
vim.opt.smartcase = true            -- …unless a capital letter is used
vim.opt.termguicolors = true        -- 24-bit colour
vim.opt.signcolumn = "yes"          -- always show sign column (gitsigns)
vim.opt.cursorline = true           -- highlight current line
vim.opt.splitright = true           -- vertical split opens on the right
vim.opt.splitbelow = true           -- horizontal split opens below
vim.opt.scrolloff = 4               -- keep 4 lines of context when scrolling
vim.opt.sidescrolloff = 8           -- keep 8 cols of context horizontally
vim.opt.wrap = false                -- no soft-wrap by default
vim.opt.swapfile = false            -- no swap files (use undo history instead)
