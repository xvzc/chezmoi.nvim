local base = require "chezmoi.commands.__base"
local util = require "chezmoi.util"

local M = {}

---@param opts Options
function M.execute(opts)
  opts = opts or {}
  opts.targets = vim.iter({ opts.targets or {} }):flatten():totable()
  opts.args = util.__normalize_args(opts.args)

  return base.execute(vim.tbl_deep_extend("keep", { cmd = "status" }, opts))
end

return M
