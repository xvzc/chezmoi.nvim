local M = {}

local notify = require("chezmoi.notify")
local base = require("chezmoi.commands.__base")

local watched_buffers = {}

function M.is_managed(file_path)
  -- Check if file is managed by chezmoi
  local result = base.execute {
    cmd = "source-path",
    targets = { file_path },
    on_stderr = function() end,
  }
  
  -- If we get a source path back, the file is managed
  return result and not vim.tbl_isempty(result)
end

function M.readd_file(file_path, config)
  -- Execute chezmoi re-add command
  local result = base.execute {
    cmd = "re-add",
    targets = { file_path },
    on_stderr = function(_, data)
      if data then
        local msg = type(data) == "table" and table.concat(data, " ") or data
        if msg and msg ~= "" then
          notify.error("Failed to re-add: " .. msg)
        end
      end
    end,
  }
  
  if result then
    if config.auto_readd.notification.enable then
      local display_path = file_path:gsub("^" .. vim.fn.expand("~"), "~")
      notify.info(
        string.format(config.auto_readd.notification.msg, display_path),
        config.auto_readd.notification.opts
      )
    end
    return true
  end
  
  return false
end

function M.setup_buffer_autocmd(bufnr, file_path, config)
  -- Skip if already watching this buffer
  if watched_buffers[bufnr] then
    return
  end
  
  watched_buffers[bufnr] = true
  
  -- Create autocmd for this specific buffer
  local augroup = vim.api.nvim_create_augroup("chezmoi_auto_readd_" .. bufnr, { clear = true })
  
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      M.readd_file(file_path, config)
    end,
    desc = "Auto re-add file to chezmoi on save"
  })
  
  -- Clean up when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      watched_buffers[bufnr] = nil
      vim.api.nvim_del_augroup_by_id(augroup)
    end,
    desc = "Clean up chezmoi auto re-add"
  })
  
  -- Show notification that we're watching this file
  if config.auto_readd.watch_notification.enable then
    local display_path = file_path:gsub("^" .. vim.fn.expand("~"), "~")
    notify.info(
      string.format(config.auto_readd.watch_notification.msg, display_path),
      config.auto_readd.watch_notification.opts
    )
  end
end

function M.setup(config)
  if not config.auto_readd or not config.auto_readd.enable then
    return
  end
  
  -- Watch for when files are opened
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*",
    group = vim.api.nvim_create_augroup("chezmoi_auto_readd", { clear = true }),
    callback = function(ev)
      local file_path = ev.match
      local bufnr = ev.buf
      
      -- Skip special buffers
      if file_path:match("^%w+://") then
        return
      end
      
      -- Skip if not under home directory
      local home = vim.fn.expand("~")
      local absolute_path = vim.fn.fnamemodify(file_path, ":p")
      if not vim.startswith(absolute_path, home) then
        return
      end
      
      -- Skip if in chezmoi source directory
      local source_dir = config.auto_readd.source_dir or vim.fn.expand("~/.local/share/chezmoi")
      if vim.startswith(absolute_path, source_dir) then
        return
      end
      
      -- Check if file is managed
      if M.is_managed(absolute_path) then
        M.setup_buffer_autocmd(bufnr, absolute_path, config)
      end
    end,
    desc = "Check if file is managed by chezmoi and setup auto re-add"
  })
end

return M