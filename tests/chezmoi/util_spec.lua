local util = require("chezmoi.util")

describe("Test util.__resolve_pos_args", function()
  it("Should return empty table, when nil", function()
    local input = nil
    local expected = {}
    local actual = util.__resolve_pos_args(input)

    assert(actual ~= nil)
    assert(#actual == #expected)
  end)

  it("Should return table, with a single element when string literal", function()
    local input = "a"
    local expected = { "a" }
    local actual = util.__resolve_pos_args(input)

    assert(actual ~= nil)
    assert(#actual == 1)
    assert(expected[1] == actual[1])
  end)

  it("Should return nil, when number", function()
    local input = 1
    local expected = nil
    local actual = util.__resolve_pos_args(input)

    assert(actual == expected)
  end)

  it("Should return nil, when boolean", function()
    local input = true
    local expected = nil
    local actual = util.__resolve_pos_args(input)

    assert(actual == expected)
  end)

  it("Should return itself, when string array", function()
    local input = { "a", "b", "c" }
    local expected = { "a", "b", "c" }
    local actual = util.__resolve_pos_args(input)

    assert(actual ~= nil)
    for i, _ in ipairs(actual) do
      assert(actual[i] == expected[i])
    end
  end)
end)

describe("Test util.__flatten_args", function()
  it("Should return a flatten array", function()
    local cmd = "apply"
    local pos_args = { "~/.zshrc" }
    local args = { "--watch" }
    local expected = { "apply", "~/.zshrc", "--watch" }
    local actual = util.__flatten_args(cmd, pos_args, args)

    assert(actual ~= nil)
    for i, v in ipairs(actual) do
      assert(actual[i] == expected[i])
    end
  end)
end)

describe("Test util.__get_or_default", function()
  it("Should return default when value is nil", function()
    local value = nil
    local default = 1
    local expected = default
    local actual = util.__get_or_default(value, default)

    assert(expected, actual)
  end)

  it("Should return value when value is not nil", function()
    local value = 3
    local default = 4
    local expected = value
    local actual = util.__get_or_default(value, default)

    assert(expected, actual)
  end)
end)

describe("Test util.__normalize_args", function()
  it("Should return the same tbl when not contains --options=value", function()
    local args = { "--path-style", "relative", "--hello", "world" }
    local expected = { "--path-style", "relative", "--hello", "world" }
    local actual = util.__normalize_args(args)

    for i, _ in ipairs(actual) do
      assert(actual[i] == expected[i])
    end
  end)

  it("Should return normalized_args tbl when contains --options=value", function()
    local args = { "--path-style=relative", "--hello", "world" }
    local expected = { "--path-style", "relative", "--hello", "world" }
    local actual = util.__normalize_args(args)

    for i, _ in ipairs(actual) do
      assert(actual[i] == expected[i])
    end
  end)
end)

describe("Test util.__arr_find_first_one_of", function()
  it("Should return nil when not found", function()
    local tbl = {"a", "b", "c"}
    local values = {"d", "e", "f"}
    local expected = nil
    local actual = util.__arr_find_first_one_of(tbl, values)

    assert(actual == expected)
  end)

  it("Should return first tbl index when found", function()
    local tbl = {"a", "b", "c"}
    local values = {100, "b", "c"}
    local expected = 2
    local actual = util.__arr_find_first_one_of(tbl, values)

    assert(actual == expected)
  end)
end)

describe("Test util.__arr_contains_one_of", function()
  it("Should return false when values empty", function()
    local tbl = {}
    local values = {}
    local expected = false

    local actual = util.__arr_contains_one_of(tbl, values)
    assert(expected == actual)
  end)

  it("Should return false when tbl not contains values", function()
    local tbl = { "a", "b", "c" }
    local values = { "d", "e", "f" }
    local expected = false

    local actual = util.__arr_contains_one_of(tbl, values)
    assert(expected == actual)
  end)

  it("Should return true when tbl contains one of values", function()
    local tbl = { "a", "b", "c" }
    local values = { "b", "e", "f" }
    local expected = true

    local actual = util.__arr_contains_one_of(tbl, values)
    assert(expected == actual)
  end)
end)
