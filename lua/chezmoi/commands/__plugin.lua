local commands = require("chezmoi.commands")
local plugin = {}

plugin.command_entry = {
  edit = function(args_all)
    local target = vim.list_slice(args_all, 1, 1)[1]
    local args = vim.list_slice(args_all, 2, #args_all)

    commands.edit(target, args)
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
  plugin.command_entry[cmd](args)
end

return plugin
