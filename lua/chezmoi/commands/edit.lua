local Path = require("plenary.path")
local config = require("chezmoi.config").values
local notify = require("chezmoi.notify")
local apply_cmd = require("chezmoi.commands.apply")
local args = require("chezmoi.args")
local source_path_cmd = require("chezmoi.commands.source_path")

local edit_cmd = {}

-- Since we use builtin neovim functions for chezmoi edit,
-- we don't need to parse the following options
-- - watch
-- - apply
local args_map = {
  watch = { "--watch", args.type.SKIP },
  apply = { "--apply", args.type.SKIP },
}

local function watch(bufnr, source_file_path, opts)
  opts = opts or opts

  -- Use autocmd to make it work as if 'watch' option is given
  local augroup = vim.api.nvim_create_augroup("chezmoi", { clear = false })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = augroup,
    buffer = bufnr,
    callback = function()
      opts.source_path = source_file_path
      apply_cmd.execute(nil, opts)
    end
  })
end

function edit_cmd.execute(target, opts)
  opts = opts or {}

  if type(target) ~= "string" then
    notify.error("'target' should be a 'string' value for edit command.")
    return
  end

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
  if not source_file_path then
    return
  end

  local ok, _ = pcall(vim.cmd.edit, source_file_path)
  if ok then
    if config.notification.on_open then
      notify.info("This is a chezmoi managed file")
    end
  else
    notify.error("Failed to open file " .. source_file_path)
    return
  end

  if opts.watch then
    local bufnr = vim.api.nvim_get_current_buf()
    watch(bufnr, source_file_path, opts)
  end
end

return edit_cmd
