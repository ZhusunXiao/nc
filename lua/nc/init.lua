---nc: project-level configuration loader
---
---Walks upward from the current buffer's file path looking for `nc.lua`.
---The directory that contains `nc.lua` becomes the project root.
---If none is found, the file's own directory is used as a fallback root
---and `config()` returns an empty table.
---
---Usage:
---  local nc = require("nc")
---  nc.root()          → project root path (string) or cwd fallback
---  nc.config()        → decoded nc.lua content (table) or {}
---  nc.get("clangd")   → nil-safe access to a config key
---
---Example nc.lua:
---  return {
---    clangd = {
---      path = "C:/LLVM/bin/clangd.exe",
---    },
---  }

local M = {}

-- cached values per project root
local cache = {} -- keys: normalized root path, value: { root = "...", config = {...} }

---Normalize a path for cache keys
local function normalize(path)
  return vim.fn.fnamemodify(path, ":p"):gsub("\\$", "")
end

---Walk upward from `buf_path` looking for `nc.lua`
local function find_nc_root(buf_path)
  local dir = vim.fn.fnamemodify(buf_path, ":p:h")
  local last = nil
  while dir ~= last do
    local candidate = vim.fn.fnamemodify(dir .. "/nc.lua", ":p")
    if vim.uv.fs_stat(candidate) then
      return normalize(dir)
    end
    last = dir
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

---Load the nc.lua file from `root` and return its returned table (or {} on failure)
local function load_nc(root)
  local nc_path = root .. "/nc.lua"
  local ok, result = pcall(dofile, nc_path)
  if ok and type(result) == "table" then
    return result
  end
  return {}
end

---Get (or compute & cache) the project info for the current buffer
local function resolve()
  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == "" then
    -- no file open — fall back to cwd
    buf_path = vim.fn.getcwd() .. "/."
  end

  local nc_root = find_nc_root(buf_path)
  local key

  if nc_root then
    key = nc_root
    if not cache[key] then
      cache[key] = {
        root = nc_root,
        config = load_nc(nc_root),
      }
    end
  else
    -- No nc.lua found — use cwd as fallback root, empty config
    key = "__fallback__"
    if not cache[key] then
      cache[key] = {
        root = vim.fn.getcwd(),
        config = {},
      }
    end
  end

  return cache[key]
end

---Check whether a key exists in the nc.lua config (truthy value).
---@param key string
---@return boolean
function M.has(key)
  return M.get(key) ~= nil
end

---Clear all cached project data (e.g. on DirChanged)
function M.clear()
  cache = {}
end

---Return the project root directory.
---@return string
function M.root()
  return resolve().root
end

---Return the full nc.lua configuration table ({} when none found).
---@return table
function M.config()
  return resolve().config
end

---Return a value from the nc.lua config by dot-separated key.
---Example: nc.get("clangd.path") → "C:/LLVM/bin/clangd.exe" or nil
---@param key string
---@return any|nil
function M.get(key)
  local cfg = resolve().config
  for part in vim.gsplit(key, ".", { plain = true }) do
    if type(cfg) ~= "table" then
      return nil
    end
    cfg = cfg[part]
  end
  return cfg
end

---Show current nc.lua info in a floating window.
function M.info()
  local resolved = resolve()
  local root = resolved.root
  local cfg = resolved.config
  local nc_path = root .. "/nc.lua"
  local has_nc = vim.uv.fs_stat(nc_path) ~= nil

  local lines = {}
  local pad = "  "

  table.insert(lines, "nc.lua  " .. (has_nc and "✓ found" or "✗ not found"))
  table.insert(lines, "")
  table.insert(lines, "Root  " .. root)

  if has_nc then
    table.insert(lines, "File  " .. nc_path)
    table.insert(lines, "")
    table.insert(lines, "── config ──")

    -- flatten config table into indented lines (sorted keys)
    local function flatten(t, indent)
      local keys = vim.tbl_keys(t)
      table.sort(keys)
      for _, k in ipairs(keys) do
        local v = t[k]
        if type(v) == "table" then
          table.insert(lines, indent .. k .. ":")
          flatten(v, indent .. pad)
        else
          table.insert(lines, indent .. k .. " = " .. vim.inspect(v))
        end
      end
    end
    flatten(cfg, pad)
  end

  -- create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "ncinfo")

  local width = 60
  local height = math.min(#lines + 2, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " nc ",
    title_pos = "center",
  })

  -- close on q or <Esc>
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

-- :NcInfo command
vim.api.nvim_create_user_command("NcInfo", function()
  M.info()
end, {})

-- Auto-clear cache when changing directories
vim.api.nvim_create_autocmd("DirChanged", {
  pattern = { "global", "window" },
  callback = M.clear,
})

return M
