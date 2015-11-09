function initializeScope(obj)
%Initializes the Robin microscope by setting required initial properties
global mmc
mmc.setProperty('Myo','ReadoutRate','10MHz 14bit');
mmc.setProperty('Myo','Binning',2);
mmc.setAutoShutter(1);
disp(['Microscope ' obj.Name ' initialized']);
end