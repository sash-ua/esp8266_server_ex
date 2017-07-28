function writeFile(name, data)
  node.egc.setmode(node.egc.ALWAYS)
  local fw = file.open(name,"w")
  if fw then
    local t = fw:write(sjson.encode(data))
    if t == nil then
      fw:close()
      return false
    end
    fw:close()
    fw,t=nil,nil
  end
  return true
end
function readFile(name)
  node.egc.setmode(node.egc.ALWAYS)
  if file.exists(name) then
    local fr = file.open(name,"r")
    local sz = file.stat(name)
    local x = fr:read(sz.size)
    fr:close()
    fr,sz=nil,nil
    return x
  else
    return nil
  end
end