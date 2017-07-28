function encode(payload, opcode)
  local band = bit.band
  local rshift = bit.rshift
  local bor = bit.bor
  local char = string.char
  opcode = opcode or 2
  assert(type(opcode) == "number", "opcode must be number")
  assert(type(payload) == "string", "payload must be string")
  local len = #payload
  local head = char(
    bor(0x80, opcode),
    len < 126 and len or (len < 0x10000) and 126 or 127
  )
  if len >= 0x10000 then
    head = head .. char(
    0,0,0,0,
    band(rshift(len, 24), 0xff),
    band(rshift(len, 16), 0xff),
    band(rshift(len, 8), 0xff),
    band(len, 0xff)
  )
  elseif len >= 126 then
    head = head .. char(band(rshift(len, 8), 0xff), band(len, 0xff))
  end
  return head .. payload
end
