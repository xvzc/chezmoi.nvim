local telescope = require("telescope")

return telescope.register_extension({
  exports = {
    find_files= require("telescope._extensions.find_files").execute
  }
})

