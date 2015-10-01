function setLEDVoltage(obj, voltage)
global mmc
LED=obj.getLED;
[device, voltProp]=obj.getLEDVoltProp(LED);
if ~isempty(voltProp)
    mmc.setProperty(device, voltProp, voltage);
end
end