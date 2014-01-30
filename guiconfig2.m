global mmc;
global gui;
% global acq;
mmc=gui.getCore;

mmc.loadSystemConfiguration('C:\Micromanager config files\MMConfig_Windows7.cfg');
mmc.setConfig('Channel','DIC');
mmc.setExposure(10);
%clear all previous acquisitions
gui.closeAllAcquisitions();
gui.clearMessageWindow();
mmc.stopSequenceAcquisition;%Will allow acquisition to run if someone has 
%forgotten to stop the 'live' mode from the mm GUI

%Initialisation functions: setting evolve gain and any
%others - setting the initial state of the TTL switch also - set to zero.
%Triggering events for the pump will occur on a falling edge at digital 4 -
%to trigger set to 00010000 (32) then down to zero again

mmc.setShutterDevice('DTOL-Shutter');
mmc.setProperty('Evolve', 'Gain', '2');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
mmc.setProperty('Evolve','MultiplierGain','270');%starting gain
%next 2 lines are specific for QUANT version of scripts
mmc.setProperty('Evolve','PP  4   ENABLED','Yes');%Enable quant view - output in photoelectrons
mmc.setProperty('Evolve','PP  4   (e)','1');%one grey level per pixel

mmc.setProperty('DTOL-Shutter','OnOff', '0');
mmc.setProperty('DTOL-DAC-1','Volts', '4');
mmc.setProperty('TILightPath','Label','2-Left100');%all light should go to the camera
mmc.setAutoShutter(1);
pause on;
gui.refreshGUI
