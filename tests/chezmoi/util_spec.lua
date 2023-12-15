local util = require("chezmoi.util")

describe("Test util.__resolve_args", function()
  local test_results = {}

  it("Should return empty table, when nil", function()
    local input = nil
    local expected = {}
    local actual = util.__resolve_pos_args(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return table, with a single element when string literal", function()
    local input = "a"
    local expected = { "a" }
    local actual = util.__resolve_pos_args(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return nil, when number", function()
    local input = 1
    local expected = nil
    local actual = util.__resolve_pos_args(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return nil, when boolean", function()
    local input = true
    local expected = nil
    local actual = util.__resolve_pos_args(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return nil, key-value table", function()
    local input = { a = "b", b = "c" }
    local expected = nil
    local actual = util.__resolve_pos_args(input)
    table.insert(test_results, { expected, actual })
  end)

  it("Should return itself, when string array", function()
    local input = { "a", "b", "c" }
    local expected = { "a", "b", "c" }
    local actual = util.__resolve_pos_args(input)
    table.insert(test_results, { expected, actual })
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)

describe("Test util.__flatten", function()
  local test_results = {}

  it("Should return a flatten array", function()
    local input = { "apply", { "~/.zshrc" }, { "--watch" } }
    local expected = { "apply", "~/.zshrc", "--watch" }
    local actual = util.__flatten(input[1], input[2], input[3])
    table.insert(test_results, { expected, actual })
  end)

  for _, v in pairs(test_results) do
    assert(v.expected == v.actual)
  end
end)
