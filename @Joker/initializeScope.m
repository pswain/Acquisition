function initializeScope(obj)
%Initializes the Demo microscope by setting required initial properties
global mmc
mmc.setShutterDevice('DTOL-Shutter');
mmc.setProperty('Evolve', 'Gain', '1');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
mmc.setProperty('Evolve','MultiplierGain','270');%starting gain
%next 2 lines are specific for QUANT version of scripts
mmc.setProperty('Evolve','PP  2   ENABLED','Yes');%Enable quant view - output in photoelectrons
mmc.setProperty('Evolve','PP  4   (e)','1');%One gray level per photoelectron
mmc.setProperty('TILightPath','Label','2-Left100');%all light should go to the camera
disp(['Microscope ' obj.Name ' initialized']);
end