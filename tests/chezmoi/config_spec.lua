local config = require("chezmoi.config")

describe("Test config.__get_default", function()
  local test_results = {}

  it("Should return default when value is nil", function()
    local input_value = nil
    local input_default = 1

    local expected = input_default
    local actual = config.__get_default(input_value, input_default)

    table.insert(test_results, { expected, actual})
  end)

  it("Should return value when value is not nil", function()
    local input_value = 3
    local input_default = 4

    local expected = input_value
    local actual = config.__get_default(input_value, input_default)

    table.insert(test_results, { expected, actual})
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)
