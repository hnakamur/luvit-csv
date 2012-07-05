local exports = {}

local csv = require("../csv")

exports["writeSimple"] = function (test)
  local writer = csv.Writer:new()
  local records = {
    {"foo", "bar", "baz"},
    {"foo2", "bar2", "baz2"}
  }
  local writtenRecords = {
    "foo,bar,baz\r\n",
    "foo2,bar2,baz2\r\n"
  }
  local j = 1
  writer:on("record", function(data)
    test.equal(data, writtenRecords[j])
    j = j + 1
  end)
  for _, fields in ipairs(records) do
    for _, field in ipairs(fields) do
      writer:writeField(field)
    end
    writer:flushRecord()
  end
  test.equal(j, #writtenRecords + 1)
  test.done()
end

exports["writeSimpleRecord"] = function (test)
  local writer = csv.Writer:new()
  local fields = {"foo", "bar", "baz"}
  local records = {"foo,bar,baz\r\n"}
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
