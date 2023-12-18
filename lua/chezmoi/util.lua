local notify = require("chezmoi.notify")
local List = require("plenary.collections.py_list")

local util = {}

-- normalizes every args formatted in "--options=value" to {"--options", "value"}
-- and flatten the result
---@param args string[]
---@return string[]
function util.__normalize_args(args)
  local ret = {}
  for _, v in ipairs(args) do
    local tokens = vim.split(v, "=")
    for _, v in ipairs(tokens) do
      table.insert(ret, v)
    end
  end

  return ret
end

-- find index of given values in an array
---@param values any[]
---@return number|nil
function util.__arr_find_first_one_of(tbl, values)
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
function util.__arr_contains_one_of(tbl, values)
  for i, v in ipairs(values) do
    if vim.tbl_contains(tbl, v) then
      return true
    end
  end

  return false
end

-- this will resolve positional arguments
-- which should be an array of strings
---@param pos_args string|string[]|any
---@return string[]|nil
function util.__resolve_pos_args(pos_args)
  if not pos_args then
    return {}
  end

  if type(pos_args) == "string" then
    return { pos_args }
  end

  if type(pos_args) ~= "table" then
    return nil
  end

  for i, v in ipairs(pos_args) do
    pos_args[i] = tostring(v)
  end

  return pos_args
end

---@param cmd string
---@param pos_args string[]
---@param args string[]
function util.__flatten_args(cmd, pos_args, args)
  return List.concat(
    List.new({ cmd }),
    List.new(pos_args),
    List.new(args)
  )
end

return util
