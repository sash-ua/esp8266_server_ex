  dofile("updateCache.lua")
  dofile("decode_ws.lua")
  dofile("encode_ws.lua")

local function acceptKey(key)
  return crypto.toBase64(crypto.sha1(key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))
end
local function ssnGen(t)
   return crypto.toHex(crypto.sha1(t.hash..t.time..node.random(100)))
end
local function reloadSSN(sck,t)
  sck:send(encode(sjson.encode({ssn=0, rld=1}), 0x1))
  tmr.alarm(3,t,tmr.ALARM_SINGLE,function()
    node.restart()
  end)
end
function server(conf)
-- Start HTTP web-server
  srv = net.createServer(net.TCP):listen(80,function(conn)
    local extra, payload, opcode, key, bffr, plws
    local buf,delay={},1
    conn:on("receive", function(sck,pl)
-- Start WebSocket (WS) server
      if bffr then
        dofile("errors.lua")
        bffr = bffr .. pl
        while true do
          extra, payload, opcode = decode(bffr)
          if not extra then break end
          bffr = extra
          if payload then plws = sjson.decode(payload) end
		  -- If session hasn't launched
          if not plws.ssn and opcode == 1 then
            local lpass = readFile(conf.pwdc)
            if lpass then
              if tostring(crypto.toHex(crypto.sha1(plws.hash))) == tostring(sjson.decode(lpass).pass) then
                plws.ssn = ssnGen(plws)
                plws.hash = 1
                writeFile(conf.ssnc, plws)
                plws.time = 1
                sck:send(encode(sjson.encode(plws), 0x1))
              else
                dofile("messenger.lua")
                msg(sck, eAuth, 0x1)
              end
            else
              dofile("messenger.lua")
              msg(sck, eiAuth, 0x1)
            end
            lpass=nil
          end
		  -- If WS connection closed by browser
          if opcode == 8 then
            srv = nil
            collectgarbage()
		  -- If session has launched
          elseif plws.ssn then
            local rf = readFile(conf.ssnc)
            if rf then
			  local cssn = sjson.decode(rf)
              if plws.ssn == cssn.ssn and plws.time <= (cssn.time + conf.ssnDrtn*86400000) then
			    if opcode == 1 then
			      -- Client set new Login and Password to authorize to system
                  if plws.newhash then
                    writeFile(conf.pwdc, {pass=crypto.toHex(crypto.sha1(plws.newhash))})
                    writeFile(conf.ssnc, {ssn=0})
                    reloadSSN(sck, 100)
				  -- Client set new Login and Password for AP
                  elseif plws.ssid and plws.pass then
                    writeFile(conf.apc, {ssid=plws.ssid,pwd=plws.pass})
                  else
-- Start custom section. In this section, you can set your own data handlers sent with WS.
                    local tbd = updateCache(conf.c, sD, 'trh', payload)
                    if tbd then
                      sck:send(encode(tbd, 0x1));
                    else
                      dofile("messenger.lua")
                      msg(sck, e2, 0x1)
                    end
                    if not tmr.state(1) then
                      tmr.alarm(1,conf.prd,tmr.ALARM_AUTO,function()
                        if buf.dp ~= sD.dp or buf.rt ~= sD.rt then
                          buf.dp = sD.dp
                          buf.rt = sD.rt
                          tbd = updateCache(conf.c, sD)
                          if tbd then
                            sck:send(encode(tbd, 0x1));
                          else
                            dofile("messenger.lua")
                            msg(sck, e2, 0x1)
                          end
                        end
                      end)
                    end
                  end
-- End section
                --If browser sent ping
				elseif opcode == 9 then
                  dofile("pingpong.lua")
                  pong(sck, payload, 0xA)
                end
              else
                writeFile(conf.ssnc, {ssn=0})
                reloadSSN(sck, 100)
              end
            else
			  writeFile(conf.ssnc, {ssn=0})
              reloadSSN(sck, 100)
            end
          end
        end
        extra, payload, opcode, tbd,rf=nil,nil,nil,nil,nil
      end
-- End WS server
      local e, method, url, name, value
      _, e,method, url = pl:find("([A-Z]+) /([^?]*)%??(.*) HTTP/%d%.%d\r\n")
      if url == "" then
        url = "index.html"
      end
      while e do
        _, e, name, value = pl:find("([^ ]+): *([^\r]+)\r\n", e + 1)
        if not e then break end
        if string.lower(name) == "sec-websocket-key" then
          key = value
        end
      end
	  -- Handshake to set WS connection
      if method == "GET" and key then
        sck:send("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: "..acceptKey(key).."\r\n\r\n")
        bffr=''
      end
	  -- HTTP server giveaway files (index.html etc)
      if url and not key then
        dofile("server_s.lua")
        if delay==1 then
          pageHandler(sck, url, conf.cDrtn)
          delay = delay +1
        else
         delay = delay +1
         tmr.delay(delay*1100)
         pageHandler(sck, url, conf.cDrtn)
        end
      end
    end)
    conn:on("sent",function(sck)
      if not key then
        sck:close()
      end
    end)
  end)
  e500=nil
  node.egc.setmode(node.egc.ALWAYS)
end