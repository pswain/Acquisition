%Prepares the microscope for a multidimensional acquisition.
%No input or output arguments but global variables gui, acq and mmc must be
%present
%

global mmc;
global gui;
global acq;
%clear all previous acquisitions
gui.closeAllAcquisitions();
gui.clearMessageWindow();
mmc.stopSequenceAcquisition;%Will allow acquisition to run if someone has 
%forgotten to stop the 'live' mode from the mm GUI

%Initialisation functions: setting evolve gain and any
%others - setting the initial state of the TTL switch also - set to zero.
%Triggering events for the pump will occur on a falling edge at digital 4 -
%to trigger set to 00010000 (32) then down to zero again

mmc.setShutterDevice('TTL Shutter (DT)');
mmc.setProperty('Evolve', 'Gain', '2');
mmc.setProperty('Evolve', 'ClearMode', 'Clear Pre-Sequence');
%set Evolve to read out in photelectrons 
mmc.setProperty('TTL Switch (DT)','State', '0');
mmc.setProperty('LightPath','Label','Left100');%all light should go to the camera
pause on;

%height=mmc.getImageHeight;
%width=mmc.getImageWidth;


end
