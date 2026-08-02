-- LSP semantic tokens: full-spectrum granular highlight
-- Every token type gets its own colour. Colorscheme can override (default=true).
-- Modifiers use typographic styles that compose with the base colour.

local set = vim.api.nvim_set_hl

-- ═══════════════ TYPES (green spectrum) ═══════════════
set(0, "@lsp.type.type",         { fg = "#4EC9B0", default = true })  -- generic type
set(0, "@lsp.type.class",        { fg = "#4EC9B0", default = true })  -- class
set(0, "@lsp.type.struct",       { fg = "#3CB99E", default = true })  -- struct (slightly darker)
set(0, "@lsp.type.enum",         { fg = "#58D68D", default = true })  -- enum (lighter green)
set(0, "@lsp.type.interface",    { fg = "#58D68D", default = true })  -- interface
set(0, "@lsp.type.typeParameter",{ fg = "#A8E6CF", default = true })  -- <T> template param (pale green)

-- ═══════════════ FUNCTIONS (yellow spectrum) ═══════════
set(0, "@lsp.type.function",     { fg = "#DCDCAA", default = true })  -- free function
set(0, "@lsp.type.method",       { fg = "#E8D88A", default = true })  -- member method (slightly lighter)
set(0, "@lsp.type.macro",        { fg = "#C586C0", default = true })  -- macro (purple, not yellow)

-- ═══════════════ PARAMETERS & VARIABLES ═══════════════
set(0, "@lsp.type.parameter",    { fg = "#FF9E64", default = true })  -- ★ function parameter (warm orange)
set(0, "@lsp.type.variable",     { fg = "#9CDCFE", default = true })  -- local / global variable
set(0, "@lsp.type.property",     { fg = "#7DCFFF", default = true })  -- member / property (cooler blue)
set(0, "@lsp.type.enumMember",   { fg = "#FFB347", default = true })  -- enum value (bright orange-gold)
set(0, "@lsp.type.event",        { fg = "#7DCFFF", default = true })  -- event (same as property)

-- ═══════════════ KEYWORDS & MODIFIERS ═══════════════
set(0, "@lsp.type.keyword",      { fg = "#569CD6", default = true })  -- keyword
set(0, "@lsp.type.modifier",     { fg = "#C586C0", default = true })  -- access modifier (purple-pink)
set(0, "@lsp.type.namespace",    { fg = "#C586C0", default = true })  -- namespace
set(0, "@lsp.type.decorator",    { fg = "#C586C0", default = true })  -- decorator / annotation
set(0, "@lsp.type.label",        { fg = "#D7BA7D", default = true })  -- label (gold)

-- ═══════════════ LITERALS ═══════════════
set(0, "@lsp.type.string",       { fg = "#CE9178", default = true })  -- string literal
set(0, "@lsp.type.number",       { fg = "#B5CEA8", default = true })  -- numeric literal
set(0, "@lsp.type.regexp",       { fg = "#D16969", default = true })  -- regex (red-brown)
set(0, "@lsp.type.operator",     { fg = "#D4D4D4", default = true })  -- operator
set(0, "@lsp.type.comment",      { fg = "#6A9955", italic = true, default = true })  -- comment

-- ═══════════════ MODIFIERS (compose with base colour) ═══════════════
-- These only set typographic styles — the base colour from the type above is preserved.
set(0, "@lsp.mod.readonly",       { italic = true,                    default = true })
set(0, "@lsp.mod.static",         { italic = true,                    default = true })
set(0, "@lsp.mod.async",          { italic = true,                    default = true })
set(0, "@lsp.mod.declaration",    { bold = true,                      default = true })
set(0, "@lsp.mod.definition",     { bold = true,                      default = true })
set(0, "@lsp.mod.deprecated",     { strikethrough = true,             default = true })
set(0, "@lsp.mod.modification",   { underline = true,                 default = true })

-- These modifiers override the colour (intentional: grey for standard library, red for unsafe)
set(0, "@lsp.mod.defaultLibrary", { fg = "#808080", italic = true,    default = true })
set(0, "@lsp.mod.unsafe",         { fg = "#FF5555", italic = true,    default = true })
set(0, "@lsp.mod.mutable",        { underline = true,                 default = true })
set(0, "@lsp.mod.abstract",       { italic = true, bold = true,       default = true })
set(0, "@lsp.mod.injected",       { fg = "#808080", italic = true,    default = true })
