-- LSP semantic tokens: granular highlight groups
-- Strategy:
--   1. Link to standard Treesitter groups wherever possible
--      → colorscheme changes are automatically honoured
--   2. Only set explicit colours for tokens that NEED distinction
--      (parameter, enumMember — user's core ask)
--   3. Modifiers use typographic styles (bold / italic / strikethrough)
--      rather than overriding colours
--   4. All groups use `default = true` so a colorscheme can take over

local set = vim.api.nvim_set_hl

-- ── Links (inherit Treesitter colour) ──────────────────────────
local links = {
  -- Types
  ["@lsp.type.type"]         = "@type",
  ["@lsp.type.class"]        = "@type",
  ["@lsp.type.struct"]       = "@type",
  ["@lsp.type.enum"]         = "@type",
  ["@lsp.type.interface"]    = "@type",
  ["@lsp.type.typeParameter"] = "@type",

  -- Functions
  ["@lsp.type.function"]     = "@function",
  ["@lsp.type.method"]       = "@function.method",

  -- Variables / properties
  ["@lsp.type.variable"]     = "@variable",
  ["@lsp.type.property"]     = "@variable.member",

  -- Keywords / modifiers
  ["@lsp.type.keyword"]      = "@keyword",
  ["@lsp.type.modifier"]     = "@keyword.modifier",
  ["@lsp.type.macro"]        = "@constant.macro",
  ["@lsp.type.namespace"]    = "@module",

  -- Literals
  ["@lsp.type.string"]       = "@string",
  ["@lsp.type.number"]       = "@number",
  ["@lsp.type.regexp"]       = "@string.regexp",

  -- Other
  ["@lsp.type.comment"]      = "@comment",
  ["@lsp.type.operator"]     = "@operator",
  ["@lsp.type.decorator"]    = "@attribute",
  ["@lsp.type.label"]        = "@label",
  ["@lsp.type.event"]        = "@type",
}

for lhs, rhs in pairs(links) do
  set(0, lhs, { default = true, link = rhs })
end

-- ── Standalone colours (no Treesitter equivalent, or need distinction) ────
set(0, "@lsp.type.parameter", {
  fg = "#FF9E64",        -- warm orange: function parameters
  default = true,
})

set(0, "@lsp.type.enumMember", {
  fg = "#FFA500",        -- bright orange: distinct from property/variable
  default = true,
})

-- ── Modifiers (typographic only, no colour) ─────────────────────
set(0, "@lsp.mod.readonly",      { italic = true,               default = true })
set(0, "@lsp.mod.static",        { italic = true,               default = true })
set(0, "@lsp.mod.async",         { italic = true,               default = true })
set(0, "@lsp.mod.declaration",   { bold = true,                 default = true })
set(0, "@lsp.mod.definition",    { bold = true,                 default = true })
set(0, "@lsp.mod.deprecated",    { strikethrough = true,        default = true })
set(0, "@lsp.mod.defaultLibrary", { fg = "#808080", italic = true, default = true })
set(0, "@lsp.mod.modification",  { underline = true,            default = true })
