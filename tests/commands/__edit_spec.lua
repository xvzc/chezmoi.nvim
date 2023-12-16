local edit_cmd = require("chezmoi.commands.__edit")

describe("Test __edit.__classify_custom_opts", function()
  local test_results = {}

  it("Should return 'watch=true' when --watch given", function()
    local input = { "--watch" }
    local expected = {
      watch = true
    }

    local actual = edit_cmd.__classify_custom_opts(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return 'watch=false' when --watch not given", function()
    local input = {}
    local expected = {
      watch = false
    }

    local actual = edit_cmd.__classify_custom_opts(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should remove '--watch' flag when given", function()
    local input = { "--watch" }
    local expected = 0
    local _ = edit_cmd.__classify_custom_opts(input)
    local actual = #input
    table.insert(test_results, { expected, actual })
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)
