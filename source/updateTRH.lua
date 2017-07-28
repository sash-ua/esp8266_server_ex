function updateCash(cn, sd, pl)
  node.egc.setmode(node.egc.ALWAYS)
  if pl then
    local w = sjson.decode(pl)
    if w.trh then 
      sd.trh = w.trh
      local t = writeFile(cn, pl)
      if t then
        return sjson.encode(sd)
      else
        return false
      end
    else
      return sjson.encode(sd)
    end
  else
    return sjson.encode(sd)
  end
end