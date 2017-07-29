wifi_ap_launch=function(a)node.egc.setmode(node.egc.ALWAYS)wifi.setmode(wifi.SOFTAP,false)local b=sjson.decode(readFile(a))b.auth=wifi.WPA2_PSK;b.save=false;b.max=1;wifi.ap.config(b)b=nil end
