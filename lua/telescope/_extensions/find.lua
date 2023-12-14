local chezmoi_commands = require("chezmoi.commands")
local chezmoi_config = require("chezmoi.config").values
local Job = require("plenary.job")
local notify = require("chezmoi.notify")

local telescope_config = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local args = require("chezmoi.args")
local Path = require("plenary.path")

local find = {}

-- make a list of results that has the following structure
-- list({ target_path, target_abs_path })
-- Example:
-- {
--   {
--     ".zshrc",
--     "/home/username/.zshrc"
--   }, {
--     ".config/nvim/init.lua",
--     "/home/username/.config/nvim/init.lua"
--   }
-- }
local function make_results(target_path, list)
  target_path = Path.new(target_path)

  local results = {}
  for _, v in ipairs(list) do
    local abs_path = Path.joinpath(target_path, Path.new(v))
    if abs_path:is_dir() then
      goto SKIP
    end
    table.insert(results, { v, tostring(abs_path) })
    ::SKIP::
  end

  return results
end

function find.execute(opts)
  local target_path = chezmoi_commands.target_path({}, opts)[1]
  if not target_path then
    return
  end

  local list = chezmoi_commands.list({
    path_style = "relative"
  })
  pickers.new(opts, {
    prompt_title = "Chezmoi files",
    finder = finders.new_table {
      results = make_results(target_path, list),
      entry_maker = function(entry)
        return {
          value = entry,
          ordinal = entry[1],
          display = entry[1],
          abs_path = entry[2]
        }
      end
    },
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        chezmoi_commands.edit(selection.abs_path, {
          watch = chezmoi_config.watch_on_edit
        })
      end)
      return true
    end,
    sorter = telescope_config.generic_sorter(opts),
  }):find()
end

return find
