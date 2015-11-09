function setLEDVoltage(obj, voltage)
global mmc
LED=obj.getLED;
[device, voltProp]=obj.getLEDVoltProp(LED);
if ~isempty(device)
    mmc.setProperty(device, voltProp, voltage);
end
end