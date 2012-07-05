local table = require("table")
local charset = require("charset")
local HierarchicalStateMachine = require("hsm").HierarchicalStateMachine

local csv = {}

local Reader = HierarchicalStateMachine:extend()
function Reader:initialize()
  self:defineStates{
    Unquoted = {},
    Quoted = {},
    EOF = {}
  }
  self.state = self.states.Unquoted

  self.fieldChars = {}
  self.record = {}
  self.divider = charset.CharDivider:new(charset.utf8)
  self.divider:on("char", function(char)
    self:react(char)
  end)
end

function Reader:_reactUnquoted(char)
  if char == "," or char == "\n" then
    self:_emitField()
    if char == "\n" then
      self:_emitRecord()
    end
  else
    table.insert(self.fieldChars, char)
  end
end

function Reader:_entryEOF()
  if #self.fieldChars > 0 then
    self:_emitField()
    self:_emitRecord()
  end
end

function Reader:_emitField()
  local field = table.concat(self.fieldChars)
  self.fieldChars = {}
  table.insert(self.record, field)
  self:emit("field", field)
end

function Reader:_emitRecord()
  self:emit("record", self.record)
  self.record = {}
end

function Reader:read(data)
  self.divider:feed(data)
end

function Reader:end_()
  self:_transit(self.states.EOF)
end

csv.Reader = Reader
return csv
