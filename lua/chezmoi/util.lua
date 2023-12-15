local notify = require("chezmoi.notify")

local util = {}

-- this will resolve positional arguments
-- which should be an array of strings
---@param pos_args string|string[]
---@return string[]|nil
function util.__resolve_pos_args(pos_args)
  if not pos_args then
    return {}
  end

  if type(pos_args) == "string" then
    return { pos_args }
  end

  if not type(pos_args) == "table" then
    notify.panic("the type of positioanl argument should be 'string|string[]'")
    return nil
  end

  for _, _ in pairs(pos_args) do
    notify.panic("the type of positioanl argument should be 'string|string[]'")
    return nil
  end

  return pos_args
end

return util
