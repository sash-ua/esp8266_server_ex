dofile("server.lua")
dofile("getSensors.lua")
dofile("initwifi.lua")
dofile("file_s.lua")
sD = {}
function controller()
  node.egc.setmode(node.egc.ALWAYS)
  -- prd - Sensors collection data interval 
  -- cDrtn - Cache-Control: max-age in seconds
  -- ssnDrtn - Session duration in days
  local conf = {c='cache.cache',ssnc='ssn.cache', pwdc='pass.cache',apc='ap.cache', prd=15000, cDrtn=31536000, ssnDrtn=1}
  --Wi-Fi AP launch
  wifi_ap_launch(conf.apc) 
  local mT = tmr.create()
  mT:register(100, tmr.ALARM_AUTO, function()
    sD = getSensors(conf.c)
  end)
  mT:start()
  tmr.alarm(0,150,tmr.ALARM_SINGLE,function()
  -- Sensors collection data interval 
    mT:interval(conf.prd) 
  end)
  server(conf)
end