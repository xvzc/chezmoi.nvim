local config = require("chezmoi.config").values
local List = require("plenary.collections.py_list")
local notify = require("chezmoi.notify")
local args = {}

args.type = {
  BOOLEAN = 0,
  STRING = 1,
  LIST = 2,
}

local global_args_map = {
  config = { "--config", args.type.STRING },
  config_format = { "--config-format", args.type.STRING },
  debug = { "--debug", args.type.BOOLEAN },
  destination = { "--destination", args.type.STRING },
  dry_run = { "--dry-run", args.type.BOOLEAN },
  force = { "--force", args.type.BOOLEAN },
  help = { "--help", args.type.BOOLEAN },
  interactive = { "--interactive", args.type.BOOLEAN },
  keep_going = { "--keep-going", args.type.BOOLEAN },
  mode = { "--mode", args.type.STRING },
  no_pager = { "--no-pager", args.type.BOOLEAN },
  no_tty = { "--no-tty", args.type.BOOLEAN },
  output = { "--output", args.type.STRING },
  persistent_state = { "--persistent-state", args.type.STRING },
  progress = { "--progress", args.type.STRING },
  refresh = { "--refresh-externals", args.type.STRING },
  source = { "--source", args.type.STRING },
  source_path = { "--source-path", args.type.STRING },
  use_builtin_age = { "--use-builtin-age", args.type.STRING },
  use_builtin_git = { "--use-builtin-git", args.type.STRING },
  verbose = { "--verbose", args.type.BOOLEAN },
  version = { "--version", args.type.BOOLEAN },
  working_tree = { "--working-tree", args.type.STRING },
}

local function apply_config(opts)
  opts.config = opts.config or config.chezmoi.config
  opts.source = opts.source or config.chezmoi.source
  opts.destination = opts.destination or config.chezmoi.destination
end

local function parse_targets(targets)
  if not targets then
    return {}
  end

  if type(targets) == "string" then
    return { targets }
  end

  if type(targets) == "table" then
    return targets
  end

  notify.error("'targets' parameter should be 'string'|'table'")

  return {}
end

local function parse_with_args_map(map, opts)
  local parsed_args = {}
  for k, v in pairs(opts) do
    if map[k] and map[k][2] == args.type.BOOLEAN then
      table.insert(parsed_args, map[k][1])
    elseif map[k] and map[k][2] == args.type.STRING then
      table.insert(parsed_args, map[k][1])
      table.insert(parsed_args, tostring(v))
    elseif map[k] and map[k][2] == args.type.LIST then
      table.insert(parsed_args, map[k][1])
      table.insert(parsed_args, table.concat(v, ","))
    end
  end

  return parsed_args
end

function args.parse(cmd, targets, map, opts)
  apply_config(opts)
  local cmd_targets = List.new(parse_targets(targets))
  local cmd_args = List.new(parse_with_args_map(map, opts))
  local global_args = List.new(parse_with_args_map(global_args_map, opts))
  return List.concat(List.new({ cmd }), cmd_targets, cmd_args, global_args)
end

return args
