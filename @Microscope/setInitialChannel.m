function setInitialChannel(obj)
%Sets the microscope to the initial channel defined by the property
%InitialChannel
global mmc;
mmc.setConfig('Channel',obj.InitialChannel);
end