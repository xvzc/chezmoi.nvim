local M = {}

-- Function to pick chezmoi files with mini.pick
---@param targets? string|string[]
M.pick = function(targets)
  local results = require("chezmoi.commands").list({
    targets = targets,
    args = {
      "--include",
      "files",
      "--exclude",
      "externals",
    },
  })

  local function choose_fn(item)
    local source_path = require("chezmoi.commands").source_path({
      targets = { item },
    })[1]
    require("mini.pick").default_choose(source_path)
  end
  require("mini.pick").start({
    source = {
      items = results,
      name = "Chezmoi",
      cwd = vim.fn.expand("~"),
      choose = choose_fn,
      show = function(buf_id, items, query) return require("mini.pick").default_show(buf_id, items, query, { show_icons = true }) end,
    },
  })
end

return M
