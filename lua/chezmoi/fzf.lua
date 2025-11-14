local M = {}

---@param targets string|string[]?
M.pick = function(targets)
  local fzf_lua = require "fzf-lua"
  local actions = {
    ["enter"] = function(selected)
      fzf_lua.actions.vimcmd_entry("ChezmoiEdit", selected, { cwd = vim.env.HOME })
    end,
  }
  if type(targets) == "table" then
    targets = " " .. table.concat(targets, " ")
  elseif type(targets) == "str" then
    targets = " " .. targets
  end
  fzf_lua.files {
    cmd = "chezmoi managed --include=files,symlinks" .. targets ,
    actions = actions,
    cwd = vim.env.HOME,
    hidden = false,
  }
end
return M
