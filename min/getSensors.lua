  dofile("math_s.lua")
  dofile("am2320.lua")
  dofile("managerGpio.lua")
  dofile("handlerTRH.lua")
  --dofile("_ds18b20.lua")
--local function ds18b20()
--  return getTemp(7)
--end
function getSensors(cn)
  local data={}
--  rh,t=am2320_h()
--  data.rh, data.temp = rh/10, t/10
  data.rh, data.temp = 51, 26
--  data.rt = ds18b20()
  data.rt = 19.55
  data.ip = wifi.ap.getip()
  data.mac = wifi.ap.getmac()
  data.dp = dewPoint(data)
  data.trh = handlerTRH(cn)
  managerGpio(data)
  return data
end
