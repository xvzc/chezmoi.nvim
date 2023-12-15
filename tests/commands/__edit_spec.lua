local edit = require("chezmoi.commands.__edit")

describe("Test __edit.__resolve_args", function()
  local test_results = {}

  it("Should return 'watch=true' when --watch given", function()
    local input = { "--watch" }
    local expected = {
      watch = true
    }

    local actual = edit.__resolve_args(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return 'watch=false' when --watch not given", function()
    local input = {}
    local expected = {
      watch = false
    }

    local actual = edit.__resolve_args(input)
    table.insert(test_results, { expected, actual })
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)
