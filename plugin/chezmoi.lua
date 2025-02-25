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
      args = args,
    })
  end,
  list = function(args_all)
    local targets, args = parse_args(args_all)
    local managed_files = commands.list({
      targets = targets,
      args = args,
    })

    local out = ""
    for _, v in ipairs(managed_files) do
      out = out .. v .. "\n"
    end

    print(out)
  end,
}

local function load_command(cmd, ...)
  local args = { ... }
  command_entry[cmd](args)
end

local function edit_complete(arg_lead, cmd_line, cursor_pos)
  -- This automatically filters arguments
  local completions = vim.fn.getcompletion(arg_lead, "file")

  -- customlist behaviour does not filter args, so we do it here
  local accepted_args = { "--watch", "--force" }
  for _, arg in ipairs(accepted_args) do
    if arg:find(arg_lead, 1, true) then
      table.insert(completions, arg)
    end
  end

  return completions
end

vim.api.nvim_create_user_command("ChezmoiEdit", function(opts)
  load_command("edit", unpack(opts.fargs))
end, {
  nargs = "*",
  complete = edit_complete, -- lua function equivalent to customlist
})

vim.api.nvim_create_user_command("ChezmoiList", function(opts)
  load_command("list", unpack(opts.fargs))
end, {
  nargs = "*",
})
