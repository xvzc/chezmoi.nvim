local chezmoi_commands = require "chezmoi.commands"
local chezmoi_config = require("chezmoi").config
local Job = require "plenary.job"
local notify = require "chezmoi.notify"

local make_entry = require "telescope.make_entry"
local telescope_config = require("telescope.config").values
local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local Path = require "plenary.path"

local find = {}

-- make a list of results with following structure
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
function find.__make_entry_list(target_path, list)
  target_path = Path.new(target_path)

  local results = {}
  for _, v in ipairs(list) do
    local abs_path = Path.joinpath(target_path, Path.new(v))
    table.insert(results, { v, tostring(abs_path) })
  end

  return results
end

function find.execute(opts)
  opts = opts or {}

  local list = chezmoi_commands.list {
    "--path-style",
    "absolute",
    "--include",
    "files",
  }

  pickers
    .new(opts, {
      prompt_title = "Chezmoi files",
      finder = finders.new_table {
        results = list,
        entry_maker = make_entry.gen_from_file(opts),
      },
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          chezmoi_commands.edit(selection.value, {})
        end)
        return true
      end,
      previewer = telescope_config.file_previewer(opts),
      sorter = telescope_config.generic_sorter(opts),
    })
    :find()
end

return find
