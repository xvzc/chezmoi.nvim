if vim.g.chezmoi_loaded == 1 then
  return
end
vim.g.chezmoi_loaded = 1

vim.api.nvim_create_user_command("Chezmoi", function(opts)
  require("chezmoi.commands.__plugin").load_command(unpack(opts.fargs))
end, {
  nargs = "*",
  complete = function(_, line)
    local plugin = require("chezmoi.commands.__plugin")
    local command_list = vim.tbl_keys(plugin.command_entry)

    local l = vim.split(line, "%s+")
    local n = #l

    if n == 2 and not command_list[l[2]] then
      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[2])
      end, command_list)
    end

    local list_res = require("chezmoi.commands").list({
      "--path-style=relative",
      "--ignore-dirs"
    })

    if n == 3 and l[2] == "edit" and list_res ~= nil then
      return vim.tbl_filter(function(val)
        return vim.startswith(val, l[3])
      end, list_res)
    end
  end,
})
