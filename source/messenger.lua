function msg(conn, msg, opcode)
  conn:send(encode("{\"msg\":\""..msg.."\"}", opcode))
end
