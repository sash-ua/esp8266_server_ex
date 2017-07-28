function am2320_h()
 am2320.init(5, 6)
 local rh, t = am2320.read()
 return rh, t
end
