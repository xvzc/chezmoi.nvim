local base = require("chezmoi.commands.__base")
local util = require("chezmoi.util")

local commands = {}

function commands.list(args)
  return base.execute({
    cmd = "list",
    args = args,
  })
end

---@param targets string|string[]
---@param args string[]
function commands.target_path(targets, args)
  return base.execute({
    cmd = "target-path",
    pos_args = util.__resolve_pos_args(targets),
    args = args,
  })
end

---@param targets string|string[]
---@param args string[]
function commands.source_path(targets, args)
  return base.execute({
    cmd = "source-path",
    pos_args = util.__resolve_pos_args(targets),
    args = args,
  })
end

commands.edit = require("chezmoi.commands.__edit").execute
commands.apply = require("chezmoi.commands.__apply").execute

return commands
