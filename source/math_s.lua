function dewPoint(data)
  node.egc.setmode(node.egc.ALWAYS)
  local c
  local a, b,temp, rh =17.27, 237.7, data.temp, data.rh/100
  c=((a*temp)/(b+temp))+ln(rh)
  local dp = round((((b*c)/(a-c))*10)/10,2)
  c,a,b,temp,rh=nil,nil,nil,nil,nil
  return dp
end
function round(n, dec)
  node.egc.setmode(node.egc.ALWAYS)
  local m = 10^(dec or 0)
  return math.floor(n * m + 0.5) / m
end
function ln(x) 
  node.egc.setmode(node.egc.ALWAYS)
  local y = (x-1)/(x+1)
  local y2 = y*y
  local r = 0
  for i=33, 0, -2 do 
    r = 1/i + y2 * r
  end
  local ln = 2*y*r
  y,y2,r,i=nil,nil,nil,nil
  return ln
end
