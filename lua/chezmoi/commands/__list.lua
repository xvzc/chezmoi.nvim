local notify = require("chezmoi.notify")
local base = require("chezmoi.commands.__base")
local util = require('chezmoi.util')
local Path = require("plenary.path")
local List = require("plenary.collections.py_list")

local list_cmd = {}

function list_cmd.__classify_custom_opts(args)
  local ret = { ignore_dirs = false }

  for i, v in ipairs(args) do
    if v == "--ignore-dirs" then
      ret.ignore_dirs = true
      table.remove(args, i)
    end
  end

  return ret
end

-- return the prefix to push front
---@param args string[]
---@return string|nil
function list_cmd.__find_prefix(args)
  local path_style = util.__arr_find_first_one_of(args, { "-p", "--path-style" })
  if not path_style then
    return nil
  end

  if path_style + 1 > #args then
    return nil
  end

  local value = args[path_style + 1]
  if vim.tbl_contains({ "absolue", "source-absolute" }, value) then
    return nil
  end

  local prefix = nil
  if value == "relative" then
    prefix = base.execute({ cmd = "target-path" })[1]
  end

  if value == "source-relative" then
    prefix = base.execute({ cmd = "source-path" })[1]
  end

  return prefix
end

---@ param args? string[]
function list_cmd.execute(args)
  args = util.__normalize_args(args or {})

  local custom_opts = list_cmd.__classify_custom_opts(args)

  local results = base.execute({
    cmd = "list",
    args = args,
  })

  if not custom_opts.ignore_dirs then
    return results
  end

  local prefix = list_cmd.__find_prefix(args)
  local path_prefix = nil
  if prefix then
    path_prefix = Path:new(prefix)
  end

  local only_files = {}
  for _, v in ipairs(results) do
    local abs_path = Path:new(v)

    if path_prefix then
      abs_path = Path.joinpath(path_prefix, Path:new(v))
    end

    if abs_path:is_dir() then
      goto SKIP
    end

    table.insert(only_files, v)
    ::SKIP::
  end

  return only_files
end

return list_cmd
