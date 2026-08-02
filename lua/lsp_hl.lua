-- LSP semantic tokens: hierarchical, colour + typography per role
-- Priority: L1 (bold+punchy) > L2 (solid) > L3 (distinct) > L4 (literals) > L5 (quiet)
-- Modifiers compose on top: they may change colour OR add typographic effect.

local set = vim.api.nvim_set_hl

-- ═══ L1 · PRIMARY — bold, highest visual weight ═══════════════════════
set(0, "@lsp.type.function",     { fg = "#FFD700", bold = true,    default = true })  -- free function
set(0, "@lsp.type.method",       { fg = "#E8C547", bold = true,    default = true })  -- member function
set(0, "@lsp.type.type",         { fg = "#4EC9B0", bold = true,    default = true })  -- type / class / struct
set(0, "@lsp.type.class",        { fg = "#4EC9B0", bold = true,    default = true })
set(0, "@lsp.type.struct",       { fg = "#3CB99E", bold = true,    default = true })  -- slightly darker green
set(0, "@lsp.type.enum",         { fg = "#58D68D", bold = true,    default = true })
set(0, "@lsp.type.interface",    { fg = "#58D68D", bold = true,    default = true })

-- ═══ L2 · STRUCTURAL — solid colours ══════════════════════════════════
set(0, "@lsp.type.namespace",    { fg = "#D291BC",                  default = true })  -- namespace (pink)
set(0, "@lsp.type.macro",        { fg = "#C586C0",                  default = true })  -- macro (purple)
set(0, "@lsp.type.label",        { fg = "#D7BA7D",                  default = true })  -- label / goto target

-- ═══ L3 · DATA — rich variety, each role visibly different ════════════
-- ★ parameter — italic + warm orange, instant recognition
set(0, "@lsp.type.parameter",    { fg = "#FF9E64", italic = true,   default = true })

-- member / property — underlined cool-blue, "belongs to something"
set(0, "@lsp.type.property",     { fg = "#7DCFFF", underline = true, default = true })

-- local variable — plain light-blue
set(0, "@lsp.type.variable",     { fg = "#9CDCFE",                  default = true })

-- enum member — warm gold-orange, stands apart from parameter orange
set(0, "@lsp.type.enumMember",   { fg = "#FFB347",                  default = true })

-- template parameter — pale mint
set(0, "@lsp.type.typeParameter",{ fg = "#A8E6CF",                  default = true })

-- event — same blue family as property
set(0, "@lsp.type.event",        { fg = "#7DCFFF",                  default = true })

-- ═══ L4 · LITERALS & KEYWORDS ═════════════════════════════════════════
set(0, "@lsp.type.keyword",      { fg = "#569CD6",                  default = true })
set(0, "@lsp.type.modifier",     { fg = "#C586C0", italic = true,   default = true })  -- access modifier
set(0, "@lsp.type.decorator",    { fg = "#C586C0", italic = true,   default = true })  -- annotation / attribute
set(0, "@lsp.type.string",       { fg = "#CE9178",                  default = true })
set(0, "@lsp.type.number",       { fg = "#B5CEA8",                  default = true })
set(0, "@lsp.type.regexp",       { fg = "#D16969",                  default = true })

-- ═══ L5 · QUIET — low contrast, background role ═══════════════════════
set(0, "@lsp.type.comment",      { fg = "#6A9955", italic = true,   default = true })
set(0, "@lsp.type.operator",     { fg = "#808080",                  default = true })

-- ═══════════════ SCOPE MODIFIERS — override colour per scope ══════════
-- These CHANGE the fg so you can tell global vs member vs local at a glance.
-- When clangd sends `variable` + `global`, the global colour wins.
set(0, "@lsp.mod.global",        { fg = "#79D4FF",                  default = true })  -- global var (brighter blue)
set(0, "@lsp.mod.classScope",    { fg = "#7DCFFF", underline = true, default = true })  -- class-scoped (same as property)
set(0, "@lsp.mod.fileScope",     { fg = "#5DB4E0",                  default = true })  -- file-static (muted blue)
set(0, "@lsp.mod.functionScope", { fg = "#9CDCFE",                  default = true })  -- function-local (plain light blue)

-- ═══════════════ PURE TYPOGRAPHIC MODIFIERS — compose with base colour ═
set(0, "@lsp.mod.readonly",      { italic = true,                    default = true })
set(0, "@lsp.mod.static",        { italic = true,                    default = true })
set(0, "@lsp.mod.async",         { italic = true,                    default = true })
set(0, "@lsp.mod.abstract",      { italic = true, bold = true,       default = true })
set(0, "@lsp.mod.declaration",   { bold = true,                      default = true })
set(0, "@lsp.mod.definition",    { bold = true,                      default = true })
set(0, "@lsp.mod.deprecated",    { strikethrough = true,             default = true })
set(0, "@lsp.mod.modification",  { underline = true,                 default = true })
set(0, "@lsp.mod.mutable",       { underline = true,                 default = true })

-- ═══════════════ SEMANTIC OVERRIDE MODIFIERS — override both colour + style ══
set(0, "@lsp.mod.defaultLibrary",{ fg = "#707070", italic = true,    default = true })  -- std lib symbol
set(0, "@lsp.mod.unsafe",        { fg = "#FF5555", italic = true,    default = true })  -- unsafe / volatile
set(0, "@lsp.mod.documentation", { fg = "#608B4E", italic = true,    default = true })  -- doc comment
