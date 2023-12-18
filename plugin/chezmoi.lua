if vim.g.chezmoi_loaded == 1 then
  return
end
vim.g.chezmoi_loaded = 1

vim.api.nvim_create_user_command("ChezmoiEdit", function(opts)
  require("chezmoi.commands.__plugin").load_command("edit", unpack(opts.fargs))
end, {
  nargs = "*"
})

vim.api.nvim_create_user_command("ChezmoiList", function(opts)
  require("chezmoi.commands.__plugin").load_command("list", unpack(opts.fargs))
end, {
  nargs = "*"
})
