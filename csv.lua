local string = require("string")
local table = require("table")
local Emitter = require("core").Emitter
local charset = require("charset")
local HierarchicalStateMachine = require("hsm").HierarchicalStateMachine

local csv = {}

local Reader = HierarchicalStateMachine:extend()
function Reader:initialize()
  self:defineStates{
    Unquoted = {},
    Quoted = {
      SeenQuote = {}
    },
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
  if char == "\r" then return end -- ignore
  if char == '"' then return self.states.Quoted end
  if char == "," or char == "\n" then
    self:_emitField()
    if char == "\n" then
      self:_emitRecord()
    end
  else
    self:_addFieldChar(char)
  end
end

function Reader:_reactQuoted(char)
  if char == "\r" then return end -- ignore
  if char == '"' then return self.states.SeenQuote end
  self:_addFieldChar(char)
end

function Reader:_reactSeenQuote(char)
  if char == '"' then
    self:_addFieldChar(char)
    return self.states.Quoted
  end
  if char == "\r" then return end -- ignore
  if char == "," or char == "\n" then
    self:_emitField()
    if char == "\n" then
      self:_emitRecord()
    end
    return self.states.Unquoted
  else
    self:_emitField()
    self:_transit(self.states.Unquoted)
    return self:react(char)
  end
end

function Reader:_entryEOF()
  if #self.fieldChars > 0 then
    self:_emitField()
    self:_emitRecord()
  end
end

function Reader:_addFieldChar(char)
  table.insert(self.fieldChars, char)
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

local Writer = Emitter:extend()

function Writer:initialize()
  self.fields = {}
end

function Writer:writeField(field)
  local text = self:_isQuoteNeeded(field) and self:_quote(field) or field
  table.insert(self.fields, text)
end

function Writer:flushRecord()
  self:emit("record", table.concat(self.fields, ",") .. "\r\n")
  self.fields = {}
end

local function find(hayStack, needle)
  return string.find(hayStack, needle, 1, true)
end

function Writer:_isQuoteNeeded(field)
  return find(field, ",") or find(field, '"') or find(field, "\n")
end

function Writer:_quote(field)
  return '"' .. string.gsub(field, '"', '""') .. '"'
end

function Writer:writeRecord(fields)
  for _, field in ipairs(fields) do
    self:writeField(field)
  end
  self:flushRecord()
end

csv.Reader = Reader
csv.Writer = Writer
return csv
