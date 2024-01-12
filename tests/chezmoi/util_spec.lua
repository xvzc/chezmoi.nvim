local util = require("chezmoi.util")

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
