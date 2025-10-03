-- Test file for auto re-add functionality
-- Add this to your nvim config to test the feature

-- Setup with auto re-add enabled
require("chezmoi").setup({
  auto_readd = {
    enable = true,
    watch_notification = {
      enable = true,
      msg = "chezmoi: watching %s for re-add",
    },
    notification = {
      enable = true,
      msg = "chezmoi: re-added %s to source",
    },
  },
  -- Optional: also enable the reverse (edit source, apply to target)
  edit = {
    watch = true,
    force = false,
  },
})

-- Test scenarios:
-- 
-- 1. Test with managed file:
--    :edit ~/.bashrc
--    Should show: "chezmoi: watching ~/.bashrc for re-add"
--    Make a change and :w
--    Should show: "chezmoi: re-added ~/.bashrc to source"
--
-- 2. Test with unmanaged file:
--    :edit /tmp/test.txt
--    Should NOT show any chezmoi notifications
--
-- 3. Test with source file:
--    :edit ~/.local/share/chezmoi/dot_bashrc
--    Should NOT set up re-add (already in source)
--    If edit.watch is true, should set up apply instead
--
-- 4. Verify changes are captured:
--    Edit ~/.bashrc, add a comment like "# TEST COMMENT"
--    Save the file
--    Check ~/.local/share/chezmoi/dot_bashrc
--    The comment should appear there too

-- Debug commands for testing
vim.api.nvim_create_user_command("ChezmoiTestManaged", function(opts)
  local file = opts.args ~= "" and opts.args or vim.fn.expand("%:p")
  local auto_readd = require("chezmoi.auto_readd")
  
  if auto_readd.is_managed(file) then
    print(file .. " is managed by chezmoi")
  else
    print(file .. " is NOT managed by chezmoi")
  end
end, { nargs = "?", complete = "file" })

vim.api.nvim_create_user_command("ChezmoiTestReAdd", function(opts)
  local file = opts.args ~= "" and opts.args or vim.fn.expand("%:p")
  local auto_readd = require("chezmoi.auto_readd")
  local config = require("chezmoi").get_config()
  
  if auto_readd.is_managed(file) then
    print("Attempting to re-add " .. file)
    local success = auto_readd.readd_file(file, config)
    if success then
      print("Successfully re-added " .. file)
    else
      print("Failed to re-add " .. file)
    end
  else
    print(file .. " is not managed by chezmoi")
  end
end, { nargs = "?", complete = "file" })

-- Status command to show current watchers
vim.api.nvim_create_user_command("ChezmoiStatus", function()
  local buffers = vim.api.nvim_list_bufs()
  local watching = {}
  
  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      local autocmds = vim.api.nvim_get_autocmds({
        event = "BufWritePost",
        buffer = bufnr,
      })
      
      for _, autocmd in ipairs(autocmds) do
        if autocmd.group_name and autocmd.group_name:match("^chezmoi_auto_readd_") then
          local name = vim.api.nvim_buf_get_name(bufnr)
          if name ~= "" then
            table.insert(watching, name)
          end
        end
      end
    end
  end
  
  if #watching > 0 then
    print("Auto re-add watching:")
    for _, file in ipairs(watching) do
      print("  " .. file)
    end
  else
    print("No files currently being watched for re-add")
  end
end, {})