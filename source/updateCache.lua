function updateCache(cn, sd, key, pl)
  if pl then
    local w = sjson.decode(pl)
    local z=w[key]
    if z then 
      sd[key] = z
      local t = writeFile(cn, sd)
      if t then
        w,t=nil,nil
        return sjson.encode(sd)
      else
        w,t=nil,nil
        return false
      end
      w=nil
      return sjson.encode(sd)
    else
      return sjson.encode(sd)
    end
  else
    return sjson.encode(sd)
  end  
end
