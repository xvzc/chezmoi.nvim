local telescope = require("telescope")

return telescope.register_extension({
  exports = {
    find = require("telescope._extensions.find").execute
  }
})

