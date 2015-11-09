function initializeScope(obj)
%Initializes the Batgirl microscope by setting required initial properties
global mmc
mmc.setProperty('Evolve', 'Gain', '1');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
mmc.setProperty('Evolve','MultiplierGain','270');%starting gain
mmc.setProperty('Evolve','PP  2   ENABLED','Yes');%Enable quant view - output in photoelectrons
mmc.setProperty('Evolve','PP  2   (E)','1');%one grey level per pixel
mmc.setProperty('Evolve','Port','Normal');
mmc.setProperty('TILightPath','Label','2-Left100');%all light should go to the camera
mmc.setAutoShutter(1);
disp(['Microscope ' obj.Name ' initialized']);
end