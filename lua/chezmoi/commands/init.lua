local commands = {}

---@return string[]
---@param opts { targets: string|string[], args: string[] }
function commands.target_path(opts)
  return require("chezmoi.commands.__target-path").execute(opts)
end

---@return string[]
---@param opts { targets: string|string[], args: string[] }
function commands.source_path(opts)
  return require("chezmoi.commands.__source-path").execute(opts)
end

---@return string[]
---@param opts { targets: string|string[], args: string[] }
function commands.apply(opts)
  return require("chezmoi.commands.__apply").execute(opts)
end

---@return string[]
---@param opts { targets: string|string[]?, args: string[] }
function commands.list(opts)
  return require("chezmoi.commands.__list").execute(opts)
end

---@param opts { targets: string|string[], args: string[] }
function commands.status(opts)
  return require("chezmoi.commands.__status").execute(opts)
end

---@param opts { targets: string|string[], args: string[] }
function commands.edit(opts)
  require("chezmoi.commands.__edit").execute(opts)
end

return commands
