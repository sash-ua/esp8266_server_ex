function handlerTRH(cn)
  node.egc.setmode(node.egc.ALWAYS)
  local sv = readFile(cn)
  if sv then
    local r = sjson.decode(sv)
    if r.trh then
      sv=nil
      return r.trh
    else 
      r.trh=50
      writeFile(cn, r)
      return 50
    end
  else
    writeFile(cn, {trh=50})
    return 50
  end
end