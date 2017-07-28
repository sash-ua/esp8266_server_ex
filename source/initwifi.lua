wifi_ap_launch = function(apn)
  node.egc.setmode(node.egc.ALWAYS)
  wifi.setmode(wifi.SOFTAP, false )
  local ap_cnfg = sjson.decode(readFile(apn))
  ap_cnfg.auth = wifi.WPA2_PSK
  ap_cnfg.save = false
  wifi.ap.config(ap_cnfg)
  ap_cnfg=nil
end