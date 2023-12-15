local notify = require("chezmoi.notify")
local Job = require("plenary.job")
local base = require("chezmoi.commands.__base")
local config = require("chezmoi.config").values
local util = require('chezmoi.util')

local apply_cmd = {}

---@ param pos_args string|string[]
---@ param args string[]
function apply_cmd.execute(pos_args, args)
  args = args or {}

  base.execute({
    cmd = "apply",
    pos_args = util.__resolve_pos_args(pos_args),
    args = args,
  })
end

return apply_cmd
