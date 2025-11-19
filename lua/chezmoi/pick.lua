local M = {}

-- Pick chezmoi files with snacks.picker
-- Copy of the lazyvim function with optional targets and args
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/util/chezmoi.lua
-- Under Apache 2.0 License (https://github.com/LazyVim/LazyVim/blob/main/LICENSE)
---@param targets? string|string[] Optional target files or patterns
---@param args? string[] Optional command arguments
function M.snacks(targets, args)
  local default_args = {
    "--path-style",
    "absolute",
    "--include",
    "files",
    "--exclude",
    "externals",
  }
  args = args or default_args
  local results = require("chezmoi.commands").list {
    targets = targets,
    args = args,
  }
  local items = {}

  for _, czFile in ipairs(results) do
    table.insert(items, {
      text = czFile,
      file = czFile,
    })
  end

  ---@type snacks.picker.Config
  local snacks_opts = {
    items = items,
    confirm = function(picker, item)
      picker:close()
      require("chezmoi.commands").edit {
        targets = { item.text },
        args = { "--watch" },
      }
    end,
  }
  Snacks.picker.pick(snacks_opts)
end

-- Function to pick chezmoi files with mini.pick
---@param targets? string|string[] Optional target files or patterns
---@param args? string[] Optional command arguments
M.mini = function(targets, args)
  local default_args = {
    "--include",
    "files",
    "--exclude",
    "externals",
  }
  args = args or default_args
  local results = require("chezmoi.commands").list {
    targets = targets,
    args = args,
  }

  local function choose_fn(item)
    local source_path = require("chezmoi.commands").source_path({
      targets = { item },
    })[1]
    require("mini.pick").default_choose(source_path)
  end
  require("mini.pick").start {
    source = {
      items = results,
      name = "Chezmoi",
      cwd = vim.fn.expand "~",
      choose = choose_fn,
      show = function(buf_id, items, query)
        return require("mini.pick").default_show(
          buf_id,
          items,
          query,
          { show_icons = true }
        )
      end,
    },
  }
end

-- Pick chezmoi files with fzf-lua
-- Copy of the lazyvim function with optional targets and args
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/util/chezmoi.lua
-- Under Apache 2.0 License (https://github.com/LazyVim/LazyVim/blob/main/LICENSE)
---@param targets? string|string[] Optional target files or patterns
---@param args? string[] Optional command arguments
M.fzf = function(targets, args)
  local default_args = {
    "--include",
    "files,symlinks",
  }
  args = args or default_args

  local fzf_lua = require "fzf-lua"
  local actions = {
    ["enter"] = function(selected)
      fzf_lua.actions.vimcmd_entry("ChezmoiEdit", selected, { cwd = vim.env.HOME })
    end,
  }
  local makestr = function(obj)
    if type(obj) == "table" then
      obj = " " .. table.concat(obj, " ")
    elseif type(obj) == "string" then
      obj = " " .. obj
    elseif obj == nil then
      obj = ""
    end
    return obj
  end
  targets = makestr(targets)
  local args_str = makestr(args)
  fzf_lua.files {
    cmd = "chezmoi managed" .. args_str .. targets,
    actions = actions,
    cwd = vim.env.HOME,
    hidden = false,
  }
end

-- Pick chezmoi files with telescope
-- Wraps the telescope extension to provide a common API with other pickers
---@param targets? string|string[] Optional target files or patterns (passed as opts.targets)
---@param args? string[] Optional command arguments (passed as opts.args)
M.telescope = function(targets, args)
  local opts = {
    targets = targets,
    args = args,
  }
  require("telescope").extensions.chezmoi.find_files(opts)
end


return M
