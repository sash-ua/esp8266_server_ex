function managerGpio(data)
  local trh = tonumber(data.trh)
   if (data.rh >= trh) and (data.rt >= data.dp-2) then
    setGpioPin(2,gpio.OUTPUT, gpio.LOW) --NC
   elseif (data.rh >= trh) and (data.rt <= data.dp-2) then
     setGpioPin(2,gpio.OUTPUT, gpio.HIGH) --N0
   elseif  (data.rh < trh-2) then
    setGpioPin(2,gpio.OUTPUT, gpio.HIGH) --N0
  end
  trh,data=nil,nil
  node.egc.setmode(node.egc.ALWAYS)
end
function setGpioPin(pin, mode, lvl)
    gpio.mode(pin, mode)
    gpio.write(pin, lvl)
end