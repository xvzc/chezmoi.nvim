local Path = require("plenary.path")
local config = require("chezmoi.config").values
local notify = require("chezmoi.notify")
local apply_cmd = require("chezmoi.commands.apply")
local source_path_cmd = require("chezmoi.commands.source_path")

local edit_cmd = {}

local function watch(bufnr, source, target)
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    buffer = bufnr,
    callback = function()
      apply_cmd.execute(target, {})
    end
  })
end

function edit_cmd.execute(target, opts)
  target = Path.new(target)
  if not target:exists() then
    local message = "The file " .. target .. "does not exists.\n"
    message = message .. "Check the values of the list below\n"
    message = message .. " - 'config.chezmoi.destination_path'\n"
    message = message .. " - 'config.chezmoi.source_path'"
    notify.error(message)
    return
  end

  local source_file_path = source_path_cmd.execute(tostring(target), opts)[1]
  local ok, _ = pcall(vim.cmd.edit, source_file_path)
  if ok then
    if config.notification.on_open then
      notify.info("This is a chezmoi managed file")
    end
  else
      notify.error("Failed to open file " .. source_file_path)
  end

  if config.watch_on_edit then
    local bufnr = vim.api.nvim_get_current_buf()
    watch(bufnr, source_file_path, tostring(target))
  end
end

return edit_cmd
