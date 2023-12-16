local commands = require("chezmoi.commands")
local notify = require("chezmoi.notify")
local Path = require("plenary.path")
local plugin = {}

plugin.command_entry = {
  edit = function(args_all)
    local relative_target = vim.list_slice(args_all, 1, 1)
    local args = vim.list_slice(args_all, 2, #args_all)

    local target_path_res = commands.target_path({}, {})
    local target_root = Path:new(target_path_res[1])
    relative_target = Path:new(relative_target[1])
    commands.edit(tostring(Path.joinpath(target_root, relative_target)), args)
  end,
  list = function(args_all)
    local list_res = commands.list(args_all)
    local view = ""
    for _, v in ipairs(list_res) do
      view = view .. v .. "\n"
    end
    print(view)
  end
}

function plugin.load_command(cmd, ...)
  local args = { ... }
  -- vim.notify(vim.inspect(args))
  plugin.command_entry[cmd](args)
end

return plugin
