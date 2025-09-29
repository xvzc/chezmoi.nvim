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

describe("util.str_matches_any_of", function()
  local util = require("chezmoi.util")
  
  it("should match run_onchange files", function()
    local filename = "run_onchange_install_packages.sh"
    local patterns = {"run_onchange_.*"}
    assert.is_true(util.str_matches_any_of(filename, patterns))
  end)
  
  it("should match .chezmoiignore files", function()
    local filename = ".chezmoiignore"
    local patterns = {"%.chezmoiignore"}
    assert.is_true(util.str_matches_any_of(filename, patterns))
  end)
  
  it("should not match regular files", function()
    local filename = "dot_vimrc"
    local patterns = {"run_onchange_.*", "%.chezmoiignore"}
    assert.is_false(util.str_matches_any_of(filename, patterns))
  end)
  
  it("should return false with empty patterns", function()
    local filename = "run_onchange_test.sh"
    local patterns = {}
    assert.is_false(util.str_matches_any_of(filename, patterns))
  end)
  
  it("should return false with nil patterns", function()
    local filename = "run_onchange_test.sh"
    assert.is_false(util.str_matches_any_of(filename, nil))
  end)
end)
