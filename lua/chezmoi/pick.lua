local M = {}

-- Pick chezmoi files with snacks.picker
-- Copy of the lazyvim function with optional opts
---@param opts { targets: string|string[]?, args: string[]? }
function M.snacks(opts)
  opts = opts or {}
  local default_args = {
    "--path-style",
    "absolute",
    "--include",
    "files",
    "--exclude",
    "externals",
  }
  local args = opts.args or default_args
  local results = require("chezmoi.commands").list {
    targets = opts.targets,
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
---@param opts { targets: string|string[]?, args: string[]? }
M.mini = function(opts)
  opts = opts or {}
  local default_args = {
    "--include",
    "files",
    "--exclude",
    "externals",
  }
  local args = opts.args or default_args
  local results = require("chezmoi.commands").list {
    targets = opts.targets,
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
-- Copy of the lazyvim function with optional opts
---@param opts { targets: string|string[]?, args: string[]? }
M.fzf = function(opts)
  opts = opts or {}
  local default_args = {
    "--include",
    "files,symlinks",
  }
  local args = opts.args or default_args
  local targets = opts.targets

  local fzf_lua = require "fzf-lua"
  local actions = {
    ["enter"] = function(selected)
      fzf_lua.actions.vimcmd_entry("ChezmoiEdit", selected, { cwd = vim.env.HOME })
    end,
  }
  local makestr = function(obj)
    if type(obj) == "table" then
      obj = " " .. table.concat(obj, " ")
    elseif type(obj) == "str" then
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



return M
