local Job = require("plenary.job")
local args = require("chezmoi.args")
local notify = require("chezmoi.notify")

local source_path_cmd = {}

function source_path_cmd.execute(targets, opts)
  local result = Job:new({
    command = "chezmoi",
    args = args.parse("source-path", targets, {}, opts),
    on_stderr = function(err, data)
      notify.error("source-path command returned non 0 exit code:\n" .. data)
    end,
  }):sync()

  return result
end

return source_path_cmd
