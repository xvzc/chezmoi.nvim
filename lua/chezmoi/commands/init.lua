local base = require "chezmoi.commands.__base"
local util = require "chezmoi.util"

local commands = {}

---@return string[]
---@param targets string|string[]
---@param args? string[]
function commands.target_path(targets, args)
  return base.execute {
    cmd = "target-path",
    pos_args = util.__resolve_pos_args(targets),
    args = args,
  }
end

---@return string[]
---@param targets string|string[]
---@param args? string[]
function commands.source_path(targets, args)
  return base.execute {
    cmd = "source-path",
    pos_args = util.__resolve_pos_args(targets),
    args = args,
  }
end

---@return string[]
---@param targets string|string[]
---@param args? string[]
function commands.apply(targets, args)
  return base.execute {
    cmd = "apply",
    pos_args = util.__resolve_pos_args(targets),
    args = args,
  }
end

function commands.list(args)
  return base.execute {
    cmd = "list",
    args = args,
  }
end

---@return string[]
commands.edit = require("chezmoi.commands.__edit").execute

return commands
