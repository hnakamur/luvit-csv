local exports = {}

local csv = require("../csv")

exports["writeQuoted"] = function (test)
  local writer = csv.Writer:new()
  local fields = {"foo,bar", "newline\nhere", '"baz"'}
  local records = {'"foo,bar","newline\nhere","""baz"""\r\n'}
  local j = 1
  writer:on("record", function(data)
    test.equal(data, records[j])
    j = j + 1
  end)
  for _, field in ipairs(fields) do
    writer:writeField(field)
  end
  writer:flushRecord()
  test.equal(j, #records + 1)
  test.done()
end

exports["writeQuotedRecord"] = function (test)
  local writer = csv.Writer:new()
  local fields = {"foo,bar", "newline\nhere", '"baz"'}
  local records = {'"foo,bar","newline\nhere","""baz"""\r\n'}
  local j = 1
  writer:on("record", function(data)
    test.equal(data, records[j])
    j = j + 1
  end)
  writer:writeRecord(fields)
  test.equal(j, #records + 1)
  test.done()
end

return exports
