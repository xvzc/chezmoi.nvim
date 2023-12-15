describe("test", function()
  local a = {}

  require("plenary")

  before_each(function()
    table.insert(a, "ABC")
  end)

  it("Run test", function()
    print("hello")
  end)

  assert(a[1] == "ABC")
end)
