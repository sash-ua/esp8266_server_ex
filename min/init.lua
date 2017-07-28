dofile("controller.lua")
tmr.alarm(6,3000,tmr.ALARM_SINGLE,function()
  controller()
end)
