local edit_cmd = require("chezmoi.commands.__edit")
local util = require("chezmoi.util")

describe("Test __edit.__parse_custom_opts", function()
  local test_results = {}

  it("Should return 'watch=true' when --watch given", function()
    local input = { "--watch" }
    local expected = {
      watch = true
    }

    local actual = edit_cmd.__parse_custom_opts(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return 'watch=false' when --watch not given", function()
    local input = {}
    local expected = {
      watch = false
    }

    local actual = edit_cmd.__parse_custom_opts(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should remove '--watch' flag when given", function()
    local input = { "--watch" }
    local expected = 0
    local _ = edit_cmd.__parse_custom_opts(input)
    local actual = #input
    table.insert(test_results, { expected, actual })
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)

-- Add test cases for the ignore patterns functionality

describe("edit command ignore patterns", function()
  local util = require("chezmoi.util")
  
  it("should ignore run_onchange files", function()
    local filename = "/path/to/run_onchange_install_packages.sh"
    local patterns = {"run_onchange_.*"}
    assert.is_true(util.should_ignore_file(filename, patterns))
  end)
  
  it("should ignore .chezmoiignore files", function()
    local filename = "/path/to/.chezmoiignore"
    local patterns = {"%.chezmoiignore"}
    assert.is_true(util.should_ignore_file(filename, patterns))
  end)
  
  it("should not ignore regular files", function()
    local filename = "/path/to/dot_vimrc"
    local patterns = {"run_onchange_.*", "%.chezmoiignore"}
    assert.is_false(util.should_ignore_file(filename, patterns))
  end)
end)
