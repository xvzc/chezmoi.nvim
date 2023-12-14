return {
  list = require("chezmoi.commands.list").execute,
  target_path = require("chezmoi.commands.target_path").execute,
  source_path = require("chezmoi.commands.source_path").execute,
  edit = require("chezmoi.commands.edit").execute,
}
