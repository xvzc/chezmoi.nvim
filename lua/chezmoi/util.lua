local notify = require("chezmoi.notify")
local List = require("plenary.collections.py_list")

local util = {}

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

  if type(pos_args) == "table" then
    for _, _ in pairs(pos_args) do
      return nil
    end
  end

  if type(pos_args) ~= "table" then
    return nil
  end

  for i, _ in ipairs(pos_args) do
    pos_args[i] = tostring(pos_args)
  end

  return pos_args
end


---@param cmd string
---@param pos_args string[]
---@param args string[]
function util.__flatten(cmd, pos_args, args)
  return List.concat(
    List.new({ cmd }),
    List.new(pos_args),
    List.new(args)
  )
end

return util
