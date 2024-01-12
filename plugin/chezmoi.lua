if vim.g.chezmoi_loaded == 1 then
  return
end
vim.g.chezmoi_loaded = 1

local commands = require "chezmoi.commands"

local function parse_args(args_all)
  local util = require "chezmoi.util"
  local target, args = util.__classify_args(args_all)
  return target, args
end

local command_entry = {
  edit = function(args_all)
    local targets, args = parse_args(args_all)
    commands.edit({
      targets = targets,
      args = args
    })
  end,
  list = function(args_all)
    local targets, args = parse_args(args_all)

    local list_res = commands.list(targets, args)
    local view = ""
    for _, v in ipairs(list_res) do
      view = view .. v .. "\n"
    end

    print(view)
  end,
}

local function load_command(cmd, ...)
  local args = { ... }
  command_entry[cmd](args)
end

vim.api.nvim_create_user_command("ChezmoiEdit", function(opts)
  load_command("edit", unpack(opts.fargs))
end, {
  nargs = "*",
})

vim.api.nvim_create_user_command("ChezmoiList", function(opts)
  load_command("list", unpack(opts.fargs))
end, {
  nargs = "*",
})
