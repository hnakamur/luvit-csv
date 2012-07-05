local exports = {}

local string = require("string")
local csv = require("../csv")

exports["readOneSimpleRow"] = function (test)
  local reader = csv.Reader:new()
  local fields = {"foo", "bar", "baz"}
  local records = {{"foo", "bar", "baz"}}
  local i = 1
  local j = 1
  reader:on("field", function(data)
    test.equal(data, fields[i])
    i = i + 1
  end)
  reader:on("record", function(data)
    test.equal(data, records[j])
    j = j + 1
  end)
  reader:read("foo,bar,baz")
  reader:end_()
  test.equal(i, #fields + 1)
  test.equal(j, #records + 1)
  test.done()
end

exports["readSimpleRows"] = function (test)
  local reader = csv.Reader:new()
  local fields = {"foo", "bar", "baz", "foo2", "bar2", "baz2"}
  local records = {{"foo", "bar", "baz"}, {"foo2", "bar2", "baz2"}}
  local i = 1
  local j = 1
  reader:on("field", function(data)
    test.equal(data, fields[i])
    i = i + 1
  end)
  reader:on("record", function(data)
    test.equal(data, records[j])
    j = j + 1
  end)
  reader:read("foo,bar,ba")
  reader:read("z\nfoo2,bar2,baz2")
  reader:end_()
  test.equal(i, #fields + 1)
  test.equal(j, #records + 1)
  test.done()
end

return exports
