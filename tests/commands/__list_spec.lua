local list_cmd = require("chezmoi.commands.__list")

describe("Test __list.__classify_custom_opts", function()
  local test_results = {}

  it("Should return 'ignore_dirs=true' when --ignore-dirs given", function()
    local input = { "--ignore_dirs" }
    local expected = {
      ignore_dirs = true
    }

    local actual = list_cmd.__classify_custom_opts(input)
    table.insert(test_results, { expected.ignore_dirs, actual.ignore_dirs })
  end)

  it("Should return 'ignore_dirs=false' when --ignore-dirs not given", function()
    local input = {}
    local expected = {
      ignore_dirs = false
    }

    local actual = list_cmd.__classify_custom_opts(input)
    table.insert(test_results, { expected.ignore_dirs, actual.ignore_dirs })
  end)

  it("Should remove '--ignore-dirs' flag when given", function()
    local input = { "--ignore-dirs" }
    local expected = 0
    local _ = list_cmd.__classify_custom_opts(input)
    local actual = #input
    table.insert(test_results, { expected, actual })
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)
