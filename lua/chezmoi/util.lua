local notify = require("chezmoi.notify")
local List = require("plenary.collections.py_list")

local M = {}

-- normalizes every args formatted in "--options=value" to {"--options", "value"}
-- and flatten the result
---@param args string[]
---@return string[]
function M.__normalize_args(args)
  args = args or {}
  local ret = {}
  for _, each in ipairs(args) do
    local tokens = vim.split(each, "=")
    for _, v in ipairs(tokens) do
      table.insert(ret, v)
    end
  end

  return ret
end

--- This function splits the input table, which is a list, into two tables.
--- One table consists of positional arguments,
--- while the other consists of option strings separately.
---@param tbl string[]?
---@return string[], string[]
function M.__classify_args(tbl)
  local targets = {}
  local args = {}

  if not tbl or vim.tbl_isempty(tbl) then
    return targets, args
  end

  local args_start_idx = nil
  for i, v in ipairs(tbl) do
    if v ~= "" and string.sub(v, 1, 1) == '-' then
      args_start_idx = i
      break
    end
  end

  if not args_start_idx then
    targets = tbl
    return targets, args
  end

  if args_start_idx  == 1 then
    args = tbl
    return targets, args
  end

  targets = vim.list_slice(tbl, 1, args_start_idx - 1)
  args = vim.list_slice(tbl, args_start_idx, #tbl)

  return targets, args
end

-- find index of given values in an array
---@param values any[]
---@return number|nil
function M.__arr_find_first_one_of(tbl, values)
  for i, v in ipairs(tbl) do
    if vim.tbl_contains(values, v) then
      return i
    end
  end

  return nil
end

-- check if table contains one of values given
---@param values string[]
---@return boolean
function M.__arr_contains_one_of(tbl, values)
  for i, v in ipairs(values) do
    if vim.tbl_contains(tbl, v) then
      return true
    end
  end

  return false
end

--- Check if a filename matches any of the ignore patterns
---@param filename string
---@param patterns string[]
---@return boolean
function M.should_ignore_file(filename, patterns)
  if not patterns or vim.tbl_isempty(patterns) then
    return false
  end

  local basename = vim.fn.fnamemodify(filename, ":t")
  
  for _, pattern in ipairs(patterns) do
    if string.match(basename, pattern) then
      return true
    end
  end
  
  return false
end

return M
