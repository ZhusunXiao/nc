-- LSP semantic token highlight groups
-- Granular colouring: every semantic token type gets its own colour.

local colours = {
  -- Types
  type      = "#4EC9B0",  -- class / struct / enum / interface
  enum      = "#4EC9B0",
  interface = "#4EC9B0",
  struct    = "#4EC9B0",
  class     = "#4EC9B0",
  typeParameter = "#4EC9B0",

  -- Functions
  ["function"] = "#DCDCAA",  -- free functions
  method       = "#DCDCAA",  -- member functions

  -- Parameters (the standout request)
  parameter      = "#FF9E64",  -- function parameters — warm orange

  -- Variables
  variable       = "#9CDCFE",  -- local / global variables

  -- Properties & members
  property      = "#9CDCFE",
  member        = "#9CDCFE",
  enumMember    = "#FFA500",  -- distinct from regular vars

  -- Misc
  namespace     = "#C586C0",
  keyword       = "#569CD6",
  modifier      = "#C586C0",
  macro         = "#C586C0",
  operator      = "#D4D4D4",
  string        = "#CE9178",
  number        = "#B5CEA8",
  regexp        = "#D16969",
  comment       = "#6A9955",
  label         = "#9CDCFE",
  decorator     = "#C586C0",
  event         = "#9CDCFE",
}

-- Link modifiers to the base type groups (no extra colours unless you want)
-- e.g. readonly parameter is still orange, just maybe italic

for token, hex in pairs(colours) do
  vim.api.nvim_set_hl(0, "@lsp.type." .. token, { fg = hex })
end

-- Modifier overrides: italic for read-only / static
vim.api.nvim_set_hl(0, "@lsp.mod.readonly",     { italic = true })
vim.api.nvim_set_hl(0, "@lsp.mod.static",       { italic = true })
vim.api.nvim_set_hl(0, "@lsp.mod.defaultLibrary", { fg = "#808080", italic = true })
vim.api.nvim_set_hl(0, "@lsp.mod.deprecated",   { strikethrough = true })
