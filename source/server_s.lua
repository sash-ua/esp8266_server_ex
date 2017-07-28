function pageHandler(sck, url, cDrtn)
  local sz, ltype, f = nil, url:sub(url:find("(%.)")+1), file.open(url..".gz","r")
  if f ~= nil then
    sz = file.stat(url..".gz")
    if url=='index.html' or type == 'html' then
      sck:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nCache-Control: max-age='..cDrtn..'\r\nContent-Length:'..sz.size.."\n\n")
    elseif ltype == 'css' then
      sck:send('HTTP/1.1 200 OK\r\nContent-Type: text/css\r\nContent-Encoding: gzip\r\nCache-Control: max-age='..cDrtn..'\r\nContent-Length:'..sz.size.."\n\n")
    elseif ltype == 'js' then
      sck:send('HTTP/1.1 200 OK\r\nContent-Type: application/x-gzip\r\nContent-Encoding: gzip\r\nCache-Control: max-age='..cDrtn..'\r\nContent-Length:'..sz.size.."\n\n")
    elseif ltype == 'ico' then
      sck:send('HTTP/1.1 200 OK\r\nContent-Type: image/x-icon\r\nContent-Encoding: gzip\r\nCache-Control: max-age='..cDrtn..'\r\nContent-Length:'..sz.size.."\n\n")
    end
    sck:send(f.read(sz.size))
    f.close()
    sz = nil
  else
    local e404 = file.open('404.html.gz',"r")
    sz = file.stat('404.html.gz')
    if e404 then
      sck:send('HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Encoding: gzip\r\nCache-Control: max-age='..cDrtn..'\r\nContent-Length:'..sz.size.."\n\n")
      sck:send(e404.read(sz.size))
      e404.close()
    else
      dofile('errors.lua')
      sck:send(e500)
    end
      e404 = nil
  end
  f,type, sz=nil,nil,nil
end