function loadConfig(obj)
%Uses the path in the obj.Config property to load the micro-manager
%configuration file.
global mmc;
mmc.loadSystemConfiguration(obj.Config);
end